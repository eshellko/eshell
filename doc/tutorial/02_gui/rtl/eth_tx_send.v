//Design:           Ethernet MAC 10/100 Transmitter MII
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
// IEEE 802.3-5
// 4.2.5
// If, while transmitting the preamble or Start Frame
// Delimiter, the collision detect variable becomes
// true, any remaining preamble and Start Frame Delimiter
// bits shall be sent.

module eth_tx_send
#( parameter APPLICATION_DATA_WIDTH = 32'd16,
   AWIDTH = 32'd14
)
(
   input tx_clk, res, start_event,
   input [APPLICATION_DATA_WIDTH-1:0] rdata,
   output reg tx_en, output tx_er, output reg [3:0] txd,
   output reg [AWIDTH:0] adr_read,
   input [47:0] mac_adr, input tx_en_delay,
   input [3:0] jam_cnt,
   input collision, collision_detected,
   input [4:0] tx_attempt_limit,
   input [4:0] current_attempt,
   input [9:0] min_len,
   output reg update_radr,
   output load_jam
);
   localparam [3:0] SEND_PRE =4'd1,
                   SEND_SFD =4'd2,
                   SEND_DA  =4'd3,
                   SEND_SA  =4'd4,
                   SEND_DATA=4'd5,
                   SEND_PAD =4'd6,
                   SEND_JAM =4'd7,
                   SEND_CRC =4'd8;
   wire shift_crc, send_data_for_crc, send_sa_for_crc,
      send_pad_for_crc, ena_crc;
   wire [3:0] crc, din_for_crc, tx_nibble, mac_nibble;
   wire [APPLICATION_DATA_WIDTH-1:0] current_packet_descriptor;
   wire [31:0] fcs;

   reg current_packet_add_sa;
   reg [3:0] crc_duration, status;
   reg [12:0] current_packet_length_words;
//RFC - //potential critical path - too many COMBOs - tx_nibble_cnt
// from 0 - 4096*2 = 15 bits
   reg [14:0] read_frame_size_in_nibbles, tx_nibble_cnt;
   reg [AWIDTH:0] adr_read_init;
   localparam AWIDTH_INC = AWIDTH + 32'd1;
/////////////////////////////////////////
//
// MAC read from memory
//
// When buffer is not empty, transmission started (if there is IDLE Media...).
// Start_event lauch TX signal which starts TX_EN & SEND_PRE
//
/////////////////////////////////////////
   assign load_jam = (collision & tx_en & status!=4'h0 
      & status!=SEND_PRE & status!=SEND_SFD & status!=SEND_JAM)
      || (collision_detected & tx_en & status!=4'h0 &
      status!=SEND_PRE & status!=SEND_JAM);

   always@(posedge tx_clk or negedge res)
   if(!res)
      status<=4'h0;
   else if(jam_cnt==4'h1 || crc_duration==4'h1)
      status<=4'h0;
   else if((collision && tx_en && status!=4'h0 &&
         status!=SEND_PRE && status!=SEND_SFD) ||
         ((collision_detected && tx_en && status!=4'h0 &&
         status!=SEND_PRE)))
      status<=SEND_JAM;
   else if(start_event)
      status<=SEND_PRE;
   else if(tx_nibble_cnt==15'd13)
      status<=SEND_SFD;
   else if(status == SEND_SFD && !collision_detected)
      status<=SEND_DA;
   else if(tx_nibble_cnt==15'd26 && !collision_detected)
      status<=SEND_SA;
   else if(tx_nibble_cnt==15'd38 && !collision_detected)
      status<=SEND_DATA;
   else if(read_frame_size_in_nibbles==15'h0001 &&
          tx_nibble_cnt<({4'h0,min_len[9:0],1'b0}+15'h0006)
          && !collision_detected && status==SEND_DATA)
      status<=SEND_PAD;
   else if(tx_nibble_cnt>=({4'h0,min_len[9:0],1'b0}+15'h0006) &&
          (read_frame_size_in_nibbles==15'h0001 || status == SEND_PAD)
          && !collision_detected)
      status<=SEND_CRC;

   always@(posedge tx_clk or negedge res)
   if(!res)
      tx_en<=1'b0;
   else
      tx_en<=|status;

   always@(posedge tx_clk or negedge res)
   if(!res)
      txd<=4'h0;
   else
      case(status)
         SEND_PRE:  txd<=4'h5;
         SEND_SFD:  txd<=4'hD;
         SEND_JAM:  txd<=4'hA;
         SEND_CRC:  txd<=crc;
         SEND_DATA: txd<=tx_nibble;
         SEND_SA:   txd<=current_packet_add_sa ? mac_nibble : tx_nibble;
         SEND_DA:   txd<=tx_nibble;
         SEND_PAD:  txd<=4'h0;
         default:   txd<=4'h0;
      endcase

   assign shift_crc = status==SEND_CRC;

always@(posedge tx_clk or negedge res)
   if(!res)
      crc_duration<=4'h0;
// Last data nibble
   else if(tx_nibble_cnt>=({4'h0,min_len[9:0],1'b0}+15'h0006)
      && read_frame_size_in_nibbles==15'h0001)
      crc_duration<=4'h8;
// Last PAD nibble
   else if(tx_nibble_cnt==({4'h0,min_len[9:0],1'b0}+15'h0006)
      && read_frame_size_in_nibbles==15'h0000)
      crc_duration<=4'h8;
   else if(|crc_duration)
      crc_duration<=crc_duration-4'h1;

//RFC - drop frame - set tx_er without retransmitting
   assign tx_er=1'b0;

// "add SA" should hold address while send MAC
   always@(posedge tx_clk or negedge res)
   if(!res)
      adr_read<={AWIDTH_INC{1'b0}};
   else if((status == SEND_DATA ||
            status == SEND_SFD/*to push descriptor*/ ||
            status==SEND_DA ||
            (status == SEND_SA && !current_packet_add_sa))
           && tx_nibble_cnt[1:0]==2'b10)
      adr_read<=adr_read+{{AWIDTH{1'b0}},1'b1};
//increase address if half-word transmited
//at the end of the data(before PAD or CRC)
   else if(tx_nibble_cnt[1:0]==2'b00 &&
         read_frame_size_in_nibbles==15'h0001 && tx_en)
      adr_read<=adr_read+{{AWIDTH{1'b0}},1'b1};
   else if(!tx_en && tx_en_delay && collision_detected)
// retransmit frame or...
      adr_read<=(current_attempt+5'h01)!=tx_attempt_limit ? adr_read_init :
//if limit reached - write next frame descriptor pointer here
         adr_read_init + current_packet_length_words;

   always@(posedge tx_clk or negedge res)
   if(!res)
      update_radr<=1'b0;
   else if(((collision_detected && (current_attempt+5'h01)==tx_attempt_limit)
       || !collision_detected) && !tx_en && tx_en_delay)
      update_radr<=1'b1;
   else
      update_radr<=1'b0;

   always@(posedge tx_clk or negedge res)
   if(!res)
      current_packet_length_words<=13'h0000;
//length of the current frame
   else if(start_event)
      current_packet_length_words<=current_packet_descriptor[12:0]+13'h0001;

always@(posedge tx_clk or negedge res)
   if(!res)
      adr_read_init<={AWIDTH_INC{1'b0}};
   else if(|status && !tx_en)
      adr_read_init<=adr_read;

   always@(posedge tx_clk or negedge res)
   if(!res)
      tx_nibble_cnt<=15'd0;
   else if(tx_en)
      tx_nibble_cnt<=tx_nibble_cnt+15'd1;
   else
      tx_nibble_cnt<=15'd0;

   always@(posedge tx_clk or negedge res)
   if(!res)
      current_packet_add_sa<=1'b0;
   else if(|status && !tx_en)
      current_packet_add_sa<=current_packet_descriptor[13];
 
   assign current_packet_descriptor = start_event ? rdata :
      {APPLICATION_DATA_WIDTH{1'b0}};

   always@(posedge tx_clk or negedge res)
   if(!res)
      read_frame_size_in_nibbles<=15'h0000;
   else if(start_event)
      read_frame_size_in_nibbles<=
      {current_packet_descriptor[12:0],2'b00} - 
      {13'h0000,current_packet_descriptor[14],1'b0};
   else if((status == SEND_DATA || status == SEND_DA ||
      (!current_packet_add_sa && status == SEND_SA))
      && |read_frame_size_in_nibbles)
      read_frame_size_in_nibbles<=read_frame_size_in_nibbles-15'h0001;

   assign tx_nibble =
      tx_nibble_cnt[1:0]==2'b10 ? rdata[7:4] :
      tx_nibble_cnt[1:0]==2'b11 ? rdata[11:8] :
      tx_nibble_cnt[1:0]==2'b00 ? rdata[15:12] :
      /*tx_nibble_cnt[1:0]==2'b01 ?*/ rdata[3:0];

   assign mac_nibble =
      tx_nibble_cnt==15'd37 ? mac_adr[3:0] :
      tx_nibble_cnt==15'd38 ? mac_adr[7:4] :
      tx_nibble_cnt==15'd35 ? mac_adr[11:8] :
      tx_nibble_cnt==15'd36 ? mac_adr[15:12] :
      tx_nibble_cnt==15'd33 ? mac_adr[19:16] :
      tx_nibble_cnt==15'd34 ? mac_adr[23:20] :
      tx_nibble_cnt==15'd31 ? mac_adr[27:24] :
      tx_nibble_cnt==15'd32 ? mac_adr[31:28] :
      tx_nibble_cnt==15'd29 ? mac_adr[35:32] :
      tx_nibble_cnt==15'd30 ? mac_adr[39:36] :
      tx_nibble_cnt==15'd27 ? mac_adr[43:40] :
      /*tx_nibble_cnt==15'd28 ?*/ mac_adr[47:44] ;//aka 0x0 for MAC
//////////////////////////////////
//
// CRC
//
// Calculates CRC for transmitted data.
//////////////////////////////////
   assign send_data_for_crc = status == SEND_DATA | status==SEND_DA |
      (status == SEND_SA & !current_packet_add_sa);
   assign send_pad_for_crc = status == SEND_PAD;
   assign send_sa_for_crc = status == SEND_SA & current_packet_add_sa;

   assign crc = status == SEND_CRC ?
      {~fcs[28],~fcs[29],~fcs[30],~fcs[31]} : 4'h0;
   assign din_for_crc =
      send_data_for_crc ? tx_nibble :
      send_sa_for_crc ? mac_nibble :
      4'h0;//pad

   assign ena_crc = send_data_for_crc | send_sa_for_crc |
      send_pad_for_crc;

   eth_crc crc32(
      .clk(tx_clk),
      .res(res),
      .ena(ena_crc),
      .shift(shift_crc),
      .din(din_for_crc),
      .fcs(fcs)
   );

endmodule
