//Design:           Ethernet MAC 10/100 Receive controller
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
// check preamble length and contents
module eth_rx_get
#( parameter APPLICATION_DATA_WIDTH = 32'd16,
   AWIDTH = 32'd14
)
(
   input [3:0] rxd,
   input rx_dv, rx_clk, rx_er,
   clk, res,
   input [47:0] mac_adr, mult_adr,
   input [9:0] mask_errors,
   input [9:0] min_len,
   input [12:0] max_len,
//RAM interface
   output [AWIDTH-1:0] wptr,
   output wr,
   output [APPLICATION_DATA_WIDTH-1:0] wdata,
//
   output update_adr_wr,
   output reg [AWIDTH:0] adr_write_rx_clk,
   input empty, full, full_duplex,
   output reg overflow,
   input clear_rx_of_flag
);
   wire ignore_adr_error, ignore_max_error, ignore_min_error,
   ignore_fcs_error, ignore_alignment_error, ignore_rx_error;
   wire fcs_error, adr_error, alignment_error, max_error, min_error, rx_error;
   wire rip;
   wire [1:0] rx_adr;
   wire [5:0] frame_errors, frame_errors_masked;
   wire [AWIDTH+1:0] adr_write_init_add;
   wire [47:0] dest_adr;
   reg rx_dv_d, rx_dv_5, rip_delay, rip_delay2, rip_delay3, full_delay;
   reg [1:0] nibble_position;//almost same as nibble_cnt
   reg [AWIDTH:0] adr_write_init;
   reg [APPLICATION_DATA_WIDTH-1:0] rx_word;
   reg [17:0] nibble_cnt;
   reg [47:0] da;

   assign adr_error = frame_errors_masked[0];
   assign max_error = frame_errors_masked[1];
   assign min_error = frame_errors_masked[2];
   assign fcs_error = frame_errors_masked[3];
   assign alignment_error = frame_errors_masked[4];
   assign rx_error = frame_errors_masked[5];

   assign update_adr_wr = !rip_delay && rip_delay2 && !( max_error || min_error || rx_error || adr_error || fcs_error || alignment_error || full);

   assign ignore_adr_error = mask_errors[0];
   assign ignore_max_error = mask_errors[1];
   assign ignore_min_error = mask_errors[2];
   assign ignore_fcs_error = mask_errors[3];
   assign ignore_alignment_error = mask_errors[4];
   assign ignore_rx_error = mask_errors[5];
////////////////////////////////////////////////////////
//
// Receive data. Check Integrity
//
// Get data from PHY. Check CRC, Length, Address, Align, Receive errors.
// CHeck Overflow.
////////////////////////////////////////////////////////
   always@(posedge rx_clk or negedge res)
   if(!res)
      rx_dv_5<=1'b0;
   else if(rx_dv && rxd==4'h5)
      rx_dv_5<=1'b1;
   else if(!rx_dv)
      rx_dv_5<=1'b0;

   always@(posedge rx_clk or negedge res)
   if(!res)
      rx_dv_d<=1'b0;
   else if(rx_dv && rxd==4'hd && rx_dv_5)
      rx_dv_d<=1'b1;
   else if(!rx_dv)
      rx_dv_d<=1'b0;

   assign rip = rx_dv_d & rx_dv;
// detect 0x5555555D sync sequence (after RX_DV asserted) - check that 5 flllowed by 5 and only that!! - not implemented yet

//
// Calculate packet length (MAX = 0xFFFF nibbles)
//
   always@(posedge rx_clk or negedge res)
   if(!res)
      nibble_cnt<=18'h0;
   else if(rip && nibble_cnt<={4'b0,max_len,1'b0})
      nibble_cnt<=nibble_cnt+18'h1;
   else if(!rip_delay2 && rip_delay3)
      nibble_cnt<=18'h0;

   always@(posedge rx_clk or negedge res)
   if(!res)
      nibble_position<=2'b0;
   else if(rip)
      nibble_position<=nibble_position+1'b1;
   else
      nibble_position<=2'b0;

   always@(posedge rx_clk or negedge res)
   if(!res)
      {rip_delay3,rip_delay2,rip_delay}<=3'h0;
   else
      {rip_delay3,rip_delay2,rip_delay}<=
      {rip_delay2,rip_delay,rip};

   always@(posedge rx_clk or negedge res)
   if(!res)
      adr_write_init<={(AWIDTH+1){1'b0}};
//Save initial address before Rx starts
   else if(rip && !rip_delay)
      adr_write_init<=adr_write_rx_clk;

   always@(posedge rx_clk or negedge res)
   if(!res)
      adr_write_rx_clk<={(AWIDTH+1){1'b0}};
//Increment address during reception
   else if(rip && nibble_position==2'h3 && !full)
      adr_write_rx_clk<=adr_write_rx_clk+1'h1;
//Load initial value for droped frame
   else if(!rip_delay && rip_delay2 &&
   ( max_error || min_error || rx_error || adr_error || fcs_error || alignment_error || full) )
      adr_write_rx_clk<=adr_write_init;
// !?? to correct adr_write_init before next frame written
   else if(!rip_delay && rip_delay2 &&
   !( max_error || min_error || rx_error || adr_error || fcs_error || alignment_error || full) )
      adr_write_rx_clk<=adr_write_rx_clk+2'h2;
//Increment address to write incomplete byte at the end of the reception
   else if(nibble_position!=2'h0 && !rip && rip_delay && !full)
      adr_write_rx_clk<=adr_write_rx_clk+1'h1;

   always@(posedge rx_clk or negedge res)
   if(!res)
      overflow<=1'b0;
   else if(clear_rx_of_flag)//highest priority - 1 cycle - do I really need it?
      overflow<=1'b0;
   else if(full)
      overflow<=1'b1;
//To reset this flag - you should write 0 to this SW bit
//but what will happended if clearing this bit will made during another FULL
// flag will (or not) set again!
/////////////////////////////////////////
//
// Memory interface.
//
/////////////////////////////////////////
   assign adr_write_init_add = adr_write_init+1'h1;

   assign wptr =
// write length of the packet
   ~rip_delay & rip_delay2 ? adr_write_init[AWIDTH-1:0] :
// write control
   ~rip_delay2 & rip_delay3 ? adr_write_init_add[AWIDTH-1:0] :
// write frame data
    adr_write_rx_clk[AWIDTH-1:0]+2'h2;

   always@(posedge rx_clk or negedge res)
   if(!res)
      full_delay<=1'b0;
   else
      full_delay<=full;
//stop writing if max_len error as it can cause an overwriting
   assign wr =
   (~full & ~full_delay) & //I add this _delay because without full resets and "control" written
   (
// write frame
   (nibble_position==3 && rip) | 
// write not fully bounded word
   (nibble_position!=0 && !rip && rip_delay) |
// write length
   (!rip_delay && rip_delay2) |
// write control
   (!rip_delay2 && rip_delay3) );

   assign wdata =
// write length
   wr & !rip_delay & rip_delay2 ? nibble_cnt[APPLICATION_DATA_WIDTH-1:0] :
// write control = adr_error, max_error, min_error, fcs_error, alignment_error, rx_error
   wr & !rip_delay2 & rip_delay3 ? { {(APPLICATION_DATA_WIDTH-8){1'b0}}, rx_adr, frame_errors} :
// write not fully bounded word
   wr & nibble_position!=0 & ~rip & rip_delay ? rx_word :/*OPT: 15-12 bits will be zeroes all the time at this point*/
// write data
   wr ? {rx_word[7:4],rx_word[11:8],rxd,rx_word[3:0]/*Make scalable*/} : {APPLICATION_DATA_WIDTH{1'b0}};

   always@(posedge rx_clk or negedge res)//4 bits will be unused
   if(!res)
      rx_word<={APPLICATION_DATA_WIDTH{1'b0}};
   else if(rip)
      rx_word<= wr ? {APPLICATION_DATA_WIDTH{1'b0}} : {rx_word[11:0],rxd}/*Make scalable*/;
/////////////////////////////////////////
//
// Check Address.
//
// Get Destination Address of the received packet.
// Compare it with one of the 4 valid addresses
// (in Promocious Mode pass without compare).
/////////////////////////////////////////
   always@(posedge rx_clk or negedge res)
   if(!res)
      da<=48'h0;
   else if(rip && nibble_cnt<16'hC)
      da<={da[43:0],rxd};

   assign dest_adr = {da[43:40],da[47:44],da[35:32],da[39:36],da[27:24],
      da[31:28],da[19:16],da[23:20],da[11:8],da[15:12],da[3:0],da[7:4]};

   eth_rx_integrity integrity(
      .rxd(rxd),
      .rx_clk(rx_clk),
      .res(res),
      .rx_dv(rx_dv),
      .rx_er(rx_er),
      .rip(rip),
      .rip_delay(rip_delay),
      .rip_delay2(rip_delay2),
      .rip_delay3(rip_delay3),
      .ignore_rx_error(ignore_rx_error),
      .ignore_alignment_error(ignore_alignment_error),
      .ignore_adr_error(ignore_adr_error),
      .ignore_max_error(ignore_max_error),
      .ignore_min_error(ignore_min_error),
      .ignore_fcs_error(ignore_fcs_error),
      .nibble_position(nibble_position[0]),
      .full_duplex(full_duplex),
      .mac_adr(mac_adr),
      .mult_adr(mult_adr),
      .dest_adr(dest_adr),
      .max_len(max_len),
      .min_len(min_len),
      .nibble_cnt(nibble_cnt),
      .frame_errors(frame_errors),
      .frame_errors_masked(frame_errors_masked),
      .rx_adr(rx_adr),
      .drop_address(mask_errors[9:6])
   );

endmodule
