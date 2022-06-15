//Design:           Ethernet MAC 10/100 Receiver DMA Controller
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
module eth_rx_dma
#( parameter APPLICATION_DATA_WIDTH = 32'd16,
   AWIDTH = 32'd14
)
(
   input clk, res, empty, apl_dma_ack,
   output reg eth_dma_req,
   input [APPLICATION_DATA_WIDTH-1:0] rdata,
   output [APPLICATION_DATA_WIDTH-1:0] dma_out,
   output reg [AWIDTH:0] adr_read_clk,
   input [1:0] pass_to_core,
   output reg[APPLICATION_DATA_WIDTH-1:0] next_packet_size,//nibbles
   input [7:0] rx_dma_timer,
   input [15:0] rx_dma_wait_timer,
   output reg [7:0] rx_dma_cnt,
   output reg [15:0] rx_dma_wait_cnt
);
   reg read_descriptor, apl_dma_ack_delay, eth_dma_req_delay;
   reg [1:0] pass_for_frame;
   reg [APPLICATION_DATA_WIDTH-2:0] word_cnt;
   reg [AWIDTH:0] adr_read_init;
wire lost_ack;
// Prepare to Request: update pass function
   wire start_event;
   assign start_event = ~empty & ~eth_dma_req & ~read_descriptor & ~apl_dma_ack /*if crc dropped*/& ~|rx_dma_wait_cnt & ~|rx_dma_cnt & ~lost_ack;

   
assign lost_ack = eth_dma_req & ~apl_dma_ack & apl_dma_ack_delay;


   always@(posedge clk or negedge res)
   if(!res)
      read_descriptor<=1'b0;
   else if(start_event)
      read_descriptor<=1'b1;
   else if(read_descriptor)
      read_descriptor<=1'b0;

   always@(posedge clk or negedge res)
   if(!res)
      pass_for_frame<=2'h0;
   else if(start_event)
      pass_for_frame<=pass_to_core;
// Set Request: update frame size, calculate transfer length
   always@(posedge clk or negedge res)
   if(!res)
      next_packet_size<={APPLICATION_DATA_WIDTH{1'b0}};
   else
      next_packet_size<=empty ? {APPLICATION_DATA_WIDTH{1'b0}} : read_descriptor ? rdata : next_packet_size ;

   always@(posedge clk or negedge res)
   if(!res)
      word_cnt<={(APPLICATION_DATA_WIDTH-1){1'b0}};
   else if(read_descriptor)
      word_cnt<=(rdata>>2) + (|rdata[1:0]) + 1/*descriptor*/-2*(!pass_for_frame[0])/*Pass CRC*/-3*(!pass_for_frame[1])/*Pass DA*/;
   else if(eth_dma_req & apl_dma_ack)
      word_cnt<=word_cnt-1'b1;
else if(lost_ack)
word_cnt<=0;

   always@(posedge clk or negedge res)
   if(!res)
      eth_dma_req<=1'b0;
   else if(word_cnt=={{(APPLICATION_DATA_WIDTH-2){1'b0}},1'b1}/*EOF*/ || (rx_dma_cnt==8'h02 && !apl_dma_ack) /*End Of Attempt*/ || lost_ack)
//add carrier lost condition - when apl_dma_req lost - reset and set resend_frame
      eth_dma_req<=1'b0;
   else if(read_descriptor)
      eth_dma_req<=1'b1;
   
   always@(posedge clk or negedge res)
   if(!res)
      adr_read_clk<={(AWIDTH+1){1'b0}};
//reload initial value if ACK wasn't received
   else if(rx_dma_cnt==8'h1 || lost_ack)
      adr_read_clk<=adr_read_init;
//jump over DA
   else if(eth_dma_req && apl_dma_ack && !apl_dma_ack_delay && !pass_for_frame[1])
      adr_read_clk<=adr_read_clk+3'h4;
//jump over CRC
   else if(eth_dma_req_delay && !eth_dma_req && apl_dma_ack && !pass_for_frame[0])
      adr_read_clk<=adr_read_clk+2'h2;
//normal increment
   else if((eth_dma_req & apl_dma_ack) || read_descriptor)
      adr_read_clk<=adr_read_clk+1'h1;

   always@(posedge clk or negedge res)
   if(!res)
      adr_read_init<={(AWIDTH+1){1'b0}};
   else if(word_cnt=={(APPLICATION_DATA_WIDTH-1){1'b0}} && apl_dma_ack && eth_dma_req_delay)
      adr_read_init<=pass_for_frame[0] ? adr_read_clk : adr_read_clk+2'h2;
//Always points to 1-st word of the frame - Descriptor

   always@(posedge clk or negedge res)
   if(!res)
      rx_dma_cnt<=8'h00;
else if(lost_ack)
rx_dma_cnt<=0;
   else if(|rx_dma_cnt && !apl_dma_ack)
      rx_dma_cnt<=rx_dma_cnt-8'h01;
   else if(!eth_dma_req && apl_dma_ack)
      rx_dma_cnt<=8'h00;
   else if(eth_dma_req && !apl_dma_ack)
      rx_dma_cnt<=rx_dma_timer;

   always@(posedge clk or negedge res)
   if(!res)
      apl_dma_ack_delay<=1'h0;
   else
      apl_dma_ack_delay<=apl_dma_ack;

   always@(posedge clk or negedge res)
   if(!res)
      eth_dma_req_delay<=1'h0;
   else
      eth_dma_req_delay<=eth_dma_req;

/////////////////////////////////////////////////
   always@(posedge clk or negedge res)
   if(!res)
      rx_dma_wait_cnt<=16'h0000;
   else if(|rx_dma_wait_cnt)
      rx_dma_wait_cnt<=rx_dma_wait_cnt-16'h0001;
   else if(rx_dma_cnt==1 || lost_ack)
      rx_dma_wait_cnt<=rx_dma_wait_timer;
/////////////////////////////////////////////////
// ##changing this parameters (Pass DA/CRC) during reading can cause device failure
   assign dma_out =
   word_cnt=={{(APPLICATION_DATA_WIDTH-2){1'b0}},1'b1} & next_packet_size[1:0]==2'b00 ? rdata :
// pass 00 inplace of end of not fully bounded packet
   word_cnt=={{(APPLICATION_DATA_WIDTH-2){1'b0}},1'b1} & next_packet_size[1:0]==2'b01 & pass_for_frame[0] ? rdata & 16'h000F :// crc at the LSBs
   word_cnt=={{(APPLICATION_DATA_WIDTH-2){1'b0}},1'b1} & next_packet_size[1:0]==2'b10 & pass_for_frame[0] ? rdata & 16'h00FF :
   word_cnt=={{(APPLICATION_DATA_WIDTH-2){1'b0}},1'b1} & next_packet_size[1:0]==2'b11 & pass_for_frame[0] ? rdata & 16'h0FFF :
   word_cnt=={{(APPLICATION_DATA_WIDTH-2){1'b0}},1'b1} & next_packet_size[1:0]==2'b01 & !pass_for_frame[0] ? {12'h0,rdata[11:8]} ://rdata & 16'h0F00 :// data at the MSBs
   word_cnt=={{(APPLICATION_DATA_WIDTH-2){1'b0}},1'b1} & next_packet_size[1:0]==2'b10 & !pass_for_frame[0] ? {8'h0,rdata[15:8]} ://rdata & 16'hFF00 :
   word_cnt=={{(APPLICATION_DATA_WIDTH-2){1'b0}},1'b1} & next_packet_size[1:0]==2'b11 & !pass_for_frame[0] ? {4'h0,rdata[3:0],rdata[15:8]} ://rdata & 16'hFF0F :
   eth_dma_req & apl_dma_ack ? rdata : 16'h0;

endmodule
