//Design:           Ethernet MAC 10/100 Transmitter DMA Controller
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
// RFC How to drop last Tx frame - if error ocureed during transfer through DMA
module eth_tx_dma
#( parameter APPLICATION_DATA_WIDTH = 32'd16,
   AWIDTH = 32'd14
)
(
   input clk, res, apl_dma_req, full, dma_enable,
   input [APPLICATION_DATA_WIDTH-1:0] dma_in,
   input [1:0] tx_dma_descriptor,
   input [12:0] max_len,
   input empty_clk,
// ADDR with MSB for flag (full) generation
   output reg [AWIDTH:0] adr_write,
   output reg [AWIDTH-1:0] wptr,
   output reg wr,
   output reg [APPLICATION_DATA_WIDTH-1:0] wdata,
   output reg [4:0] last_dma_tx_frame_status,
   output reg eth_dma_ack, update_wadr
);
   wire start_of_dma, end_of_dma, frame_too_small, frame_too_big;
   wire dma_in_progress, add_sa, be, drop_frame;
   wire [AWIDTH+1:0] next_adr_write;
   wire [13:0] max_frame_length_in_bytes;
   reg disable_dma;
   reg [12:0] frame_size;
   reg [/*14*/AWIDTH:0] adr_write_init;
   localparam AWIDTH_INC = AWIDTH + 32'd1;
   localparam APPLICATION_DATA_WIDTH_DEC =
      APPLICATION_DATA_WIDTH - 32'd15;

   assign dma_in_progress = apl_dma_req & eth_dma_ack;
   assign next_adr_write = adr_write + 15'h0001;
// Descriptor fields
   assign add_sa  = tx_dma_descriptor[0];
   assign be      = tx_dma_descriptor[1];
//   assign att_lim = tx_dma_descriptor[2];

// start_of_dma possible only if previous DMA address
// synchronization procedure completes
   assign start_of_dma = apl_dma_req & ~eth_dma_ack & ~full
      & (dma_enable & ~update_wadr);
   assign end_of_dma = ~apl_dma_req & eth_dma_ack;
// = MaxLR - CRC(4) - SA(6)(optionally) - BE//RFC -BE or +BE
// max_frame_length_in_bytes = max_len - 4 + be - (add_sa ? 6 : 0);
   assign max_frame_length_in_bytes = {1'b0,max_len} +
      {13'h0000,be} - (add_sa ? 14'd10 : 14'd4);
   assign frame_too_big = {frame_size[12:0],1'b0} > max_frame_length_in_bytes;
// add be checking and for PAD TX bytes
   assign frame_too_small = add_sa ? frame_size<13'd4 : frame_size<13'd7;
   assign drop_frame = frame_too_small | frame_too_big;
// Stop DMA to avoid buffer overflow
   always@(posedge clk or negedge res)
   if(!res)
      disable_dma<=1'b0;
   else if(dma_in_progress && full)
      disable_dma<=1'b1;
   else if(end_of_dma)
      disable_dma<=1'b0;
   
   always@(posedge clk or negedge res)
   if(!res)
      eth_dma_ack<=1'b0;
// Ethernet send ACK even it can't receive data during overflow
// for final status of DMA - read TxDSR
   else if(apl_dma_req && (dma_enable && !update_wadr))
      eth_dma_ack<=1'b1;
   else if(!apl_dma_req || full)
      eth_dma_ack<=1'b0;

   always@(posedge clk or negedge res)
   if(!res)
      adr_write<={AWIDTH_INC{1'h0}};
   else if(dma_in_progress && !full && !disable_dma)
      adr_write<=next_adr_write[AWIDTH:0];
// Load next free address on SUCCESS
// Load initial address on FAIL
   else if(end_of_dma)
      adr_write<=drop_frame || disable_dma ? adr_write_init :
         next_adr_write[AWIDTH:0];

   always@(posedge clk or negedge res)
   if(!res)
      adr_write_init<={AWIDTH_INC{1'b0}};
   else if(start_of_dma)
      adr_write_init<=adr_write;

   always@(posedge clk or negedge res)
   if(!res)
      frame_size<=13'h0000;
// To prevent this counter from overflow -
// disable writing when MaxLR reached
   else if(dma_in_progress && !frame_too_big)
      frame_size<=frame_size+13'h0001;
   else if(end_of_dma)
      frame_size<=13'h0000;

// 2 - overflow
// 1 - small
// 0 - big
   always@(posedge clk or negedge res)
   if(!res)
      last_dma_tx_frame_status<=5'h08;
   else if(end_of_dma)
      last_dma_tx_frame_status<={full, empty_clk,
         disable_dma, frame_too_small, frame_too_big};
   else
      last_dma_tx_frame_status[4:3]<={full, empty_clk};
        
// Memory Interface
   always@(posedge clk or negedge res)
   if(!res)
      wptr<={AWIDTH{1'b0}};
   else if(dma_in_progress && !full && !disable_dma)
      wptr<=next_adr_write[AWIDTH-1:0];
   else
      wptr<=adr_write_init[AWIDTH-1:0];
   
   always@(posedge clk or negedge res)
   if(!res)
      wr<=1'b0;
   else
      wr<=!full && (dma_in_progress || end_of_dma) && !disable_dma;
   
   always@(posedge clk or negedge res)
   if(!res)
      wdata<={APPLICATION_DATA_WIDTH{1'b0}};
   else if(dma_in_progress)
      wdata<=dma_in;
   else if(end_of_dma)
      wdata<={{APPLICATION_DATA_WIDTH_DEC{1'b0}},
         tx_dma_descriptor[1:0],frame_size[12:0]};

   always@(posedge clk or negedge res)
   if(!res)
      update_wadr<=1'b0;
   else if(end_of_dma && !drop_frame && !disable_dma)
      update_wadr<=1'b1;
   else
      update_wadr<=1'b0;

endmodule
