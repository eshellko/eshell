//Design:           Ethernet MAC 10/100 Transmitter
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -

module eth_tx
#(
   parameter APPLICATION_DATA_WIDTH = 32'd16,
   parameter TX_ADR_WIDTH = 32'd14
)
(
// TX ethernet interface
   input tx_clk,
   output [3:0] txd,
   output tx_er,
   output tx_en,
   input col, crs,
   input clk, res,
// DMA
   output eth_dma_ack,
   input apl_dma_req,
   input [APPLICATION_DATA_WIDTH-1:0] dma_in,
   input [1:0] tx_dma_descriptor,
   output [4:0] last_dma_tx_frame_status,//status of the last DMA frame
// CFG
   input duplex,
   input [47:0] mac_adr,
   input [4:0] tx_attempt_limit,
   input [12:0] max_len,
   input [9:0] min_len,
// Status
   output reg [5:0] tx_status,
//   output [15:0] tx_buffer_descriptor,
// RAM interface
   output [TX_ADR_WIDTH-1:0] wptr, rptr,
   output wr,
   output [APPLICATION_DATA_WIDTH-1:0] wdata,
   input [APPLICATION_DATA_WIDTH-1:0] rdata
);
   wire start_event, dma_enable, empty, almost_full,
   update_wadr, empty_clk, update_radr, collision, load_jam;
   wire [TX_ADR_WIDTH:0] adr_read_tx_clk, adr_read_clk;
   wire [TX_ADR_WIDTH:0] adr_write_clk, adr_write_tx_clk;
   wire [3:0] jam_cnt;//32 bits = 8 nibbles
   wire [16:0] jam_pause_cnt;
   reg collision_detected, tx_en_delay;
   reg [4:0] current_attempt, ifg_cnt;
/////////////////////////////////////////
//
// Application write to memory
//
// Three cases when frame droped during write to buffer:
//  1) Frame too big (i.e. > 1514 (1508) bytes)
//     1500 data bytes + 2 Length/Type + 6 Destination Address +
//     6 Source Address (if address transmission enabled)
//  2) Frame too small (i.e. < 8 (14) bytes)
//  3) Buffer full (almost overflow)
// In all cases frame droped.
// Write Pointer (adr_write) roll back to adr_write_init.
// last_dma_tx_frame_status flag sets.
/////////////////////////////////////////
   // DMA Acknowledge:
   // when Request active and...
   // buffer is not full and...
   // previous DMA synchronization complete
   eth_tx_dma
   #(.APPLICATION_DATA_WIDTH(APPLICATION_DATA_WIDTH),
     .AWIDTH(TX_ADR_WIDTH)
   )
   dma_tx(
      .clk(clk),
      .res(res),
      .apl_dma_req(apl_dma_req),
      .full(almost_full),
      .dma_enable(dma_enable),
      .dma_in(dma_in),
      .max_len(max_len),
      .empty_clk(empty_clk),
      .tx_dma_descriptor(tx_dma_descriptor),
      .adr_write(adr_write_clk),
      .wptr(wptr),
      .wr(wr),
      .wdata(wdata),
      .eth_dma_ack(eth_dma_ack),
      .last_dma_tx_frame_status(last_dma_tx_frame_status),
      .update_wadr(update_wadr)
   );

//// Memory Interface
   assign start_event = (jam_pause_cnt==17'h00000 & ifg_cnt==5'h00) &
      (~empty & ~tx_en & ~tx_en_delay) &
      (duplex | ~crs);

   assign rptr = adr_read_tx_clk[TX_ADR_WIDTH-1:0];

// ALL outputs (tx_clk) received correctly
   eth_tx_send
   #( .APPLICATION_DATA_WIDTH(APPLICATION_DATA_WIDTH),
      .AWIDTH(TX_ADR_WIDTH)
   )
   tx_send(
      .tx_clk(tx_clk),
      .res(res),
      .start_event(start_event),
      .tx_en(tx_en),
      .tx_en_delay(tx_en_delay),
      .tx_er(tx_er),
      .txd(txd),
      .rdata(rdata),
      .mac_adr(mac_adr),
      .adr_read(adr_read_tx_clk),
      .min_len(min_len),
      .jam_cnt(jam_cnt),
      .collision(collision),
      .collision_detected(collision_detected),
      .tx_attempt_limit(tx_attempt_limit),
      .current_attempt(current_attempt),
      .update_radr(update_radr),
      .load_jam(load_jam)
   );
///////////////////////////////////////////
////
//// Full flag generation
////
//// Read address synchronized with TX_CLK
//// When this address equal to adr_write
//// but late for 1 cycle - full flag generated and
//// overflow signal asserted!
///////////////////////////////////////////
   eth_sync_buffer
      #(.WIDTH(TX_ADR_WIDTH+1))
   sync_read_adr_to_clk
   (
      .clka(tx_clk),
      .clkb(clk),
      .res(res),
      .ena_buf(update_radr),/*new address comes!?*/
      .din(adr_read_tx_clk),
      .dout(adr_read_clk)
   );

//   assign full = (adr_read_clk[TX_ADR_WIDTH:0]^(1<<TX_ADR_WIDTH))==
//      adr_write_clk[TX_ADR_WIDTH:0];
   assign almost_full =
      (adr_read_clk[TX_ADR_WIDTH:0]^({1'b1,{TX_ADR_WIDTH{1'b0}}}))-{{TX_ADR_WIDTH{1'b0}},1'b1}
      ==adr_write_clk[TX_ADR_WIDTH:0];
///////////////////////////////////////////
//
// Clock Domain Crossing information
//
// When DMA request completes succesfully synchronization
// procedure occurs.
// Rejects any outstanding DMA requests until procedure in progress.
// Synchronize Write Pointer (adr_write) to TX_CLK.
// -- Without buffer as it stable (false_path during sythesis)
// Synchronized Write Pointer compares with adr_read to decide
// empty buffer or not.
// If buffer not empty transmission through Ethernet starts
// (if there is no IFG or ...).
// After Synchronization complete another DMA can be started.
///////////////////////////////////////////
   eth_sync
   #(.WIDTH(TX_ADR_WIDTH+1))
   sync_wr_adr_to_tx_clk
   (
      .clka(clk),
      .clkb(tx_clk),
      .res(res),
      .ena_buf(update_wadr),
      .din(adr_write_clk),
      .dout(adr_write_tx_clk),
      .dout_ena(dma_enable)
   );
   assign empty = adr_read_tx_clk[TX_ADR_WIDTH:0]==
     adr_write_tx_clk[TX_ADR_WIDTH:0];
   assign empty_clk = adr_read_clk[TX_ADR_WIDTH:0]==
     adr_write_clk[TX_ADR_WIDTH:0];
////////////////////////////////////////////
////
//// Interframe Gap
////
//// Starts counting interframe interval after medium become IDLE.
////////////////////////////////////////////
   always@(posedge tx_clk or negedge res)
   if(!res)
      ifg_cnt<=5'h00;
   else if(!tx_en && tx_en_delay && !duplex)
      ifg_cnt<=5'h18;//96 bits = 24 nibbles
   else if(|ifg_cnt)
      ifg_cnt<=ifg_cnt-5'h01;
///////////////////////////////////////////////////
////
//// Collision detection and JAM
////
//// If collision detected, JAM inserted into frame.
//// JAM pause counter loading with "random" value
//// and retransmission enabled after counter resets.
///////////////////////////////////////////////////
   always@(posedge tx_clk or negedge res)
   if(!res)
      tx_en_delay<=1'b0;
   else
      tx_en_delay<=tx_en;
// remove  &tx_en as it is not necessary to transmit to get collision
   assign collision = duplex ? 1'b0 : col;

   always@(posedge tx_clk or negedge res)
   if(!res)
      collision_detected<=1'b0;
   else if(tx_en && collision)
      collision_detected<=1'b1;
   else if(!tx_en)
      collision_detected<=1'b0;

   always@(posedge tx_clk or negedge res)
   if(!res)
      current_attempt<=5'h00;
   else if(!tx_en && tx_en_delay)
      current_attempt<= collision_detected ?
       ((current_attempt+5'h01)==tx_attempt_limit ? 5'h00 :
       current_attempt + 5'h01) : 5'h00;

   eth_tx_jam jam_counter(
      .tx_clk(tx_clk),
      .res(res),
      .tx_en(tx_en),
      .tx_en_delay(tx_en_delay),
      .load_jam(load_jam),
      .duplex(duplex),
      .current_attempt(current_attempt),
      .jam_cnt(jam_cnt),
      .jam_pause_cnt(jam_pause_cnt)
   );

   always@(posedge tx_clk or negedge res)
   if(!res)
      tx_status<=6'h00;
   else if(!tx_en && tx_en_delay)
   begin
      tx_status[5]<=collision_detected;
      tx_status[4:0]<=current_attempt;
   end

endmodule
