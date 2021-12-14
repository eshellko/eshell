//Design:           Ethernet MAC 10/100 Receiver
//Revision:         1.1
//Date:             2011-08-24
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: 1.1  2011-08-24  A.Kornukhin
//                  int_rx generation moved from rx_clk to clk


// check preamble content
// abort packet if ifg doesn't meet
/*
assert property (@(posedge rx_clk) (!rx_dv_delay && rx_dv) |-> #[11] rxd==5);

property preamble;
@(posedge rx_clk)
   (!rx_dv_delay && rx_dv) |-> #[11] rxd==5);
endpoperty
assert property (preamble) else $error("Preamble length mismatch.\n");

covergroup addr;
   c0: coverpoint rxd { bins rxd[] = {4=>5=>6} , {7=>8=>9}; }
endgroup
addr cv = new;
always@(posedge rx_clk)
 cv.sample();
*/
module eth_rx
#( parameter APPLICATION_DATA_WIDTH = 32'd16,
   parameter RX_ADR_WIDTH = 32'd14
)
(
   input [3:0] rxd,
   input rx_dv, rx_clk, rx_er,
   clk, res,
   apl_dma_ack,
   output eth_dma_req,
   output [APPLICATION_DATA_WIDTH-1:0] dma_out,
//   output [15:0] dout,
   output reg int_rx,
   input [47:0] mac_adr, mult_adr,
   input [9:0] min_len,
   input [12:0] max_len,
   input [11:0] rx_ctrl,
   output [15:0] next_packet_size,
   input full_duplex,
   input [7:0] rx_dma_timer,
   output [7:0] rx_dma_counter,
   input [15:0] rx_dma_wait_timer,
   output [15:0] rx_dma_wait_counter,
   output overflow,
   input clear_rx_of_flag,
//RAM interface
   output [RX_ADR_WIDTH-1:0] wptr, rptr,
   output wr,
   output [APPLICATION_DATA_WIDTH-1:0] wdata,
   input [APPLICATION_DATA_WIDTH-1:0] rdata
);
   wire empty, full;
   wire update_adr_wr;
   wire [RX_ADR_WIDTH:0] adr_read_clk, adr_write_rx_clk,
   adr_write_clk, adr_read_rx_clk;

   assign rptr = adr_read_clk [RX_ADR_WIDTH-1:0];

   eth_rx_get
   #( .APPLICATION_DATA_WIDTH(APPLICATION_DATA_WIDTH),
      .AWIDTH(RX_ADR_WIDTH)
   )
   rx_get(
      .rxd(rxd),
      .rx_dv(rx_dv),
      .rx_clk(rx_clk),
      .rx_er(rx_er),
      .clk(clk),
      .res(res),
      .mac_adr(mac_adr),
      .mult_adr(mult_adr),
      .min_len(min_len),
      .max_len(max_len),
      .mask_errors(rx_ctrl[9:0]),
      .wptr(wptr),
      .wr(wr),
      .wdata(wdata),
      .update_adr_wr(update_adr_wr),
      .adr_write_rx_clk(adr_write_rx_clk),
      .empty(empty),
      .full(full),
      .full_duplex(full_duplex),
      .overflow(overflow),
      .clear_rx_of_flag(clear_rx_of_flag)
   );

/////////////////////////////////////////
//
//
//
/////////////////////////////////////////
// edge-triggered interrupt request flag
   always@(posedge clk or negedge res)
   if(!res)
      int_rx<=1'b0;
   else if(!eth_dma_req && apl_dma_ack)
//   else if(!rip && rip_delay && (!adr_error && !fcs_error && !min_error && !max_error && !rx_error && !alignment_error))
      int_rx<=1'b1;
   else
      int_rx<=1'b0;

// ADD DMA register for low boundary, after which (adr_wr-adr_rd) DMA
// request asserted
//default >0 (!empty)

// Number of frames(!?)




      
/////////////////////////////////////////
//
// Synchronization for read address.
//
/////////////////////////////////////////
   eth_sync_buffer
   #(.WIDTH(RX_ADR_WIDTH+1))
   sync_wr_adr_to_clk
   (
      .clka(rx_clk),
      .clkb(clk),
      .res(res),
      .ena_buf(update_adr_wr),
//	.ena_buf(!rip_delay && rip_delay2),
      .din(adr_write_rx_clk+3'd2),
      .dout(adr_write_clk)
   );
   assign empty = adr_read_clk==adr_write_clk;

   eth_rx_dma
   #( .APPLICATION_DATA_WIDTH(APPLICATION_DATA_WIDTH),
      .AWIDTH(RX_ADR_WIDTH)
   )
   rx_dma(
      .clk(clk),
      .res(res),
      .empty(empty),
      .apl_dma_ack(apl_dma_ack),
      .eth_dma_req(eth_dma_req),
      .rdata(rdata),
      .dma_out(dma_out),
      .adr_read_clk(adr_read_clk),
      .pass_to_core(rx_ctrl[11:10]),
      .next_packet_size(next_packet_size),
      .rx_dma_timer(rx_dma_timer),
      .rx_dma_cnt(rx_dma_counter),
      .rx_dma_wait_timer(rx_dma_wait_timer),
      .rx_dma_wait_cnt(rx_dma_wait_counter)
   );
/////////////////////////////////////////
//
// Synchronization for write address.
//
/////////////////////////////////////////
   eth_sync_buffer
   #(.WIDTH(RX_ADR_WIDTH+1))
   sync_rd_adr_to_rx_clk
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(!eth_dma_req && apl_dma_ack),
      .din(adr_read_clk),
      .dout(adr_read_rx_clk)
   );
//   assign full = (adr_write_rx_clk[15:0]^(1<</*15*/14/*fifo width+1*/))==adr_read_rx_clk[15:0];
   assign full = ((adr_write_rx_clk+3'd2)^(1<<RX_ADR_WIDTH))==adr_read_rx_clk;

endmodule
