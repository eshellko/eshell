//Design:           Ethernet MAC 10/100 MAC
//Revision:         1.0
//Date:             2011-07-29
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -

// make external memory interface for put buffer outside the block

// add synchronization between cfg registers!

// add address information about FREE cells in memory
// full empty flags

module eth_mac
#(
   parameter APPLICATION_DATA_WIDTH = 16, // 16, 32, 64 supported
   TX_BUFFER_SIZE = 16384,
   RX_BUFFER_SIZE = 16384,
   MAC_ADR_0  = 5'h00,
   MAC_ADR_1  = 5'h01,
   MAC_ADR_2  = 5'h02,
   MULT_ADR_0 = 5'h03,
   MULT_ADR_1 = 5'h04,
   MULT_ADR_2 = 5'h05,
   MAXL       = 5'h06,
   MINL       = 5'h07,
   TXAL       = 5'h08,
   CTRL       = 5'h09,
   TXS        = 5'h0A,
   TXDD       = 5'h0B,
   TXDS       = 5'h0C,
   RXFS       = 5'h0D,
   RXC        = 5'h0E,
   RXDT       = 5'h0F,
   RXDWT      = 5'h10,
   RXDC       = 5'h11,
   RXDWC      = 5'h12,
// Regiesters address map
   MC         = 5'h13,
   MCD        = 5'h14,
   MT         = 5'h15,
   MR         = 5'h16,//ro
   MPA        = 5'h17,
   MRA        = 5'h18
)
(
//Global signals
   input clk, res,
//Application interface
   input [4:0] adr,
   input [APPLICATION_DATA_WIDTH-1:0] din,
   input wr,
   output [APPLICATION_DATA_WIDTH-1:0] dout,
//DTE interface
   input tx_clk,
   output [3:0] txd, 
   output tx_en, tx_er,
   input rx_clk, rx_dv, rx_er, col, crs,
   input [3:0] rxd,
//MIIM interface
   output mdc, mdo, mdo_en,
   input mdi,
//interrupt signals
   output int_miim, int_rx,
//DMA interface
   input apl_dma_req, apl_dma_ack,
   output eth_dma_req, eth_dma_ack,
   input [APPLICATION_DATA_WIDTH-1:0] dma_in,
   output [APPLICATION_DATA_WIDTH-1:0] dma_out
);
   localparam TX_ADR_WIDTH =
      TX_BUFFER_SIZE==8192 ? 13 :
      TX_BUFFER_SIZE==16384 ? 14 :
      TX_BUFFER_SIZE==32768 ? 15 :
      TX_BUFFER_SIZE==65536 ? 16 : 16;
   localparam RX_ADR_WIDTH =
      RX_BUFFER_SIZE==8192 ? 13 :
      RX_BUFFER_SIZE==16384 ? 14 :
      RX_BUFFER_SIZE==32768 ? 15 :
      RX_BUFFER_SIZE==65536 ? 16 : 16;
// MIIM registers
   wire [15:0] mtr, mrr, mcdr;
   wire [4:0] mpar, mrar;
   wire [6:0] mcr;
// MII registers
   wire cr;
   wire [1:0] txddr;
   wire [4:0] txalr, txdsr;
   wire [5:0] txsr;
   wire [9:0] minlr;
   wire [12:0] maxlr;
   wire [47:0] mac_adr, multicast_adr;
   wire [7:0] rxdtr, rxdcr;
   wire [11:0] rxcr;
   wire [15:0] rxfsr, rxdwtr, rxdwcr;
//RAM interface
   wire [TX_ADR_WIDTH-1:0] tx_wptr, tx_rptr;
   wire [RX_ADR_WIDTH-1:0] rx_wptr, rx_rptr;
   wire tx_wr, rx_wr;
   wire [APPLICATION_DATA_WIDTH-1:0] tx_wdata, tx_rdata, rx_wdata, rx_rdata;
   reg clk__clear_rx_of;
   wire rx_of, rx_clk__clear_rx_of, clk__rx_clk_clear_rx_of;
   reg rx_clk__clear_rx_of_delay, clear_rx_of_flag;
   wire rx_overflow_clk;
// Sync Software Registers to TX(RX) Clock
   reg write_mac_0, write_mac_1, write_mac_2;
   reg write_mult_0, write_mult_1, write_mult_2;
   reg write_txalr, write_minlr, write_maxlr;
   reg write_cr, write_rxcr, write_txddr;
   reg write_rxdtr, write_rxdwtr;
   wire [47:0] mac_adr_rx_clk, multicast_adr_rx_clk;
   wire [47:0] mac_adr_tx_clk;
   wire [4:0] txalr_tx_clk;
   wire [9:0] minlr_tx_clk, minlr_rx_clk;
   wire [12:0] maxlr_tx_clk, maxlr_rx_clk;
   wire cr_tx_clk, cr_rx_clk;
   wire [11:0] rxcr_rx_clk;
   wire [1:0] txddr_tx_clk;
   wire [7:0] rxdtr_rx_clk;
   wire [15:0] rxdwtr_rx_clk;

   eth_miim miim(
      .clk(clk),
      .res(res),
      .din(din),
      .mdi(mdi),
      .mdo(mdo),
      .mdo_en(mdo_en),
      .mdc(mdc),
      .interrupt(int_miim),
      .write_mcr(adr == MC && wr),
      .write_mtr(adr == MT && wr),
      .write_mpar(adr == MPA && wr),
      .write_mrar(adr == MRA && wr),
      .write_mcdr(adr == MCD && wr),
      .mtr(mtr),
      .mrr(mrr),
      .mcdr(mcdr),
      .mpar(mpar),
      .mrar(mrar),
      .mcr(mcr)
   );

   eth_regs
   #(.WIDTH(APPLICATION_DATA_WIDTH))
   registers(
      .clk(clk),
      .res(res),
      .data(din),
      .write_mac_0(adr == MAC_ADR_0 && wr),
      .write_mac_1(adr == MAC_ADR_1 && wr),
      .write_mac_2(adr == MAC_ADR_2 && wr),
      .write_mult_0(adr == MULT_ADR_0 && wr),
      .write_mult_1(adr == MULT_ADR_1 && wr),
      .write_mult_2(adr == MULT_ADR_2 && wr),
      .write_txalr(adr == TXAL && wr),
      .write_minlr(adr == MINL && wr),
      .write_maxlr(adr == MAXL && wr),
      .write_cr(adr == CTRL && wr),
      .write_rxcr(adr == RXC && wr),
      .write_txddr(adr == TXDD && wr),
      .write_rxdtr(adr == RXDT && wr),
      .write_rxdwtr(adr == RXDWT && wr),
      .mac_adr(mac_adr),
      .multicast_adr(multicast_adr),
      .txalr(txalr),
      .minlr(minlr),
      .maxlr(maxlr),
      .cr(cr),
      .rxcr(rxcr),
      .txddr(txddr),
      .rxdtr(rxdtr),
      .rxdwtr(rxdwtr)
   );

   eth_tx 
   #(.APPLICATION_DATA_WIDTH(APPLICATION_DATA_WIDTH),
     .TX_ADR_WIDTH(TX_ADR_WIDTH))
   tx(
// Ethernet Tx Interface
      .tx_clk(tx_clk),
      .txd(txd),
      .tx_er(tx_er),
      .tx_en(tx_en),
      .col(col),
      .crs(crs),
// Application Interface
      .clk(clk),
      .res(res),
// Application DMA Interface
      .eth_dma_ack(eth_dma_ack),
      .apl_dma_req(apl_dma_req),
      .dma_in(dma_in),
      .tx_dma_descriptor(txddr_tx_clk/*txddr*/),
      .last_dma_tx_frame_status(txdsr),
// Control Registers
      .duplex(cr_tx_clk/*cr*/),
      .mac_adr(mac_adr_tx_clk/*mac_adr*/),
      .tx_attempt_limit(txalr_tx_clk/*txalr*/),
      .tx_status(txsr),
      .max_len(maxlr_tx_clk/*maxlr*/),
      .min_len(minlr_tx_clk/*minlr*/),
//RAM interface
      .wptr(tx_wptr),
      .rptr(tx_rptr),
      .wr(tx_wr),
      .wdata(tx_wdata),
      .rdata(tx_rdata)
   );

   eth_rx
   #(.APPLICATION_DATA_WIDTH(APPLICATION_DATA_WIDTH),
     .RX_ADR_WIDTH(RX_ADR_WIDTH)
   )
   rx(
// Ethernet Rx Interface
      .rxd(rxd),
      .rx_dv(rx_dv),
      .rx_clk(rx_clk),
      .rx_er(rx_er),
// Application Interface
      .clk(clk),
      .res(res),
// Application DMA Interface
      .apl_dma_ack(apl_dma_ack),
      .eth_dma_req(eth_dma_req),
      .dma_out(dma_out),
// Control Registers
      .int_rx(int_rx),
      .mac_adr(mac_adr_rx_clk/*mac_adr*/),
      .mult_adr(multicast_adr_rx_clk/*multicast_adr*/),
      .min_len(minlr_rx_clk/*minlr*/),
      .max_len(maxlr_rx_clk/*maxlr*/),
      .rx_ctrl(rxcr_rx_clk/*rxcr*/),
      .next_packet_size(rxfsr),
      .full_duplex(cr_rx_clk/*cr*/),
      .rx_dma_timer(rxdtr_rx_clk/*rxdtr*/),
      .rx_dma_counter(rxdcr),
      .rx_dma_wait_timer(rxdwtr_rx_clk/*rxdwtr*/),
      .rx_dma_wait_counter(rxdwcr),
      .overflow(rx_of),
      .clear_rx_of_flag(clear_rx_of_flag),
//RAM interface
      .wptr(rx_wptr),
      .rptr(rx_rptr),
      .wr(rx_wr),
      .wdata(rx_wdata),
      .rdata(rx_rdata)
   );

   eth_mem
   #(.WIDTH(APPLICATION_DATA_WIDTH),
     .AWIDTH(TX_ADR_WIDTH),
     .DEPTH(TX_BUFFER_SIZE))
   mem_tx(
      .clk(clk),
      .wr(tx_wr),
      .adr_wr(tx_wptr),
      .adr_rd(tx_rptr),
      .din(tx_wdata),
      .dout(tx_rdata)
   );

   eth_mem
   #(.WIDTH(APPLICATION_DATA_WIDTH),
     .AWIDTH(RX_ADR_WIDTH),
     .DEPTH(RX_BUFFER_SIZE))
   mem_rx(
      .clk(rx_clk),
      .wr(rx_wr),
      .adr_wr(rx_wptr),
      .adr_rd(rx_rptr),
      .din(rx_wdata),
      .dout(rx_rdata)
   );

////////////////////////////////////////////////////////////////
//
// Synchronization: move registers from CLK to RX_CLK/TX_CLK
//
////////////////////////////////////////////////////////////////
   always@(posedge clk or negedge res)
   if(!res)
   begin
      write_mac_0<=1'b0;
      write_mac_1<=1'b0;
      write_mac_2<=1'b0;
      write_mult_0<=1'b0;
      write_mult_1<=1'b0;
      write_mult_2<=1'b0;
      write_txalr<=1'b0;
      write_minlr<=1'b0;
      write_maxlr<=1'b0;
      write_cr<=1'b0;
      write_rxcr<=1'b0;
      write_txddr<=1'b0;
      write_rxdtr<=1'b0;
      write_rxdwtr<=1'b0;
   end
   else
   begin
      write_mac_0<= adr == MAC_ADR_0 && wr;
      write_mac_1<= adr == MAC_ADR_1 && wr;
      write_mac_2<= adr == MAC_ADR_2 && wr;
      write_mult_0<= adr == MULT_ADR_0 && wr;
      write_mult_1<= adr == MULT_ADR_1 && wr;
      write_mult_2<= adr == MULT_ADR_2 && wr;
      write_txalr<= adr == TXAL && wr;
      write_minlr<= adr == MINL && wr;
      write_maxlr<= adr == MAXL && wr;
      write_cr<= adr == CTRL && wr;
      write_rxcr<= adr == RXC && wr;
      write_txddr<= adr == TXDD && wr;
      write_rxdtr<= adr == RXDT && wr;
      write_rxdwtr<= adr == RXDWT && wr;
   end

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h0)) mac_rx_clk0
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_mac_0),
      .din(mac_adr[15:0]),
      .dout(mac_adr_rx_clk[15:0])
   );

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h0)) mac_rx_clk1
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_mac_1),
      .din(mac_adr[31:16]),
      .dout(mac_adr_rx_clk[31:16])
   );

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h0)) mac_rx_clk2
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_mac_2),
      .din(mac_adr[47:32]),
      .dout(mac_adr_rx_clk[47:32])
   );

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h0)) mac_tx_clk0
   (
      .clka(clk),
      .clkb(tx_clk),
      .res(res),
      .ena_buf(write_mac_0),
      .din(mac_adr[15:0]),
      .dout(mac_adr_tx_clk[15:0])
   );

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h0)) mac_tx_clk1
   (
      .clka(clk),
      .clkb(tx_clk),
      .res(res),
      .ena_buf(write_mac_1),
      .din(mac_adr[31:16]),
      .dout(mac_adr_tx_clk[31:16])
   );

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h0)) mac_tx_clk2
   (
      .clka(clk),
      .clkb(tx_clk),
      .res(res),
      .ena_buf(write_mac_2),
      .din(mac_adr[47:32]),
      .dout(mac_adr_tx_clk[47:32])
   );

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h0)) multicast_rx_clk0
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_mult_0),
      .din(multicast_adr[15:0]),
      .dout(multicast_adr_rx_clk[15:0])
   );

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h0)) multicast_rx_clk1
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_mult_1),
      .din(multicast_adr[31:16]),
      .dout(multicast_adr_rx_clk[31:16])
   );

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h0)) multicast_rx_clk2
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_mult_2),
      .din(multicast_adr[47:32]),
      .dout(multicast_adr_rx_clk[47:32])
   );

   eth_sync_buffer_update #(.WIDTH(5),.INIT(5'h10)) txalr_txclk
   (
      .clka(clk),
      .clkb(tx_clk),
      .res(res),
      .ena_buf(write_txalr),
      .din(txalr),
      .dout(txalr_tx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(10),.INIT(10'h40)) minlr_txclk
   (
      .clka(clk),
      .clkb(tx_clk),
      .res(res),
      .ena_buf(write_minlr),
      .din(minlr),
      .dout(minlr_tx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(10),.INIT(10'h40)) minlr_rxclk
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_minlr),
      .din(minlr),
      .dout(minlr_rx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(13),.INIT(13'h5EE)) maxlr_txclk
   (
      .clka(clk),
      .clkb(tx_clk),
      .res(res),
      .ena_buf(write_maxlr),
      .din(maxlr),
      .dout(maxlr_tx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(13),.INIT(13'h5EE)) maxlr_rxclk
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_maxlr),
      .din(maxlr),
      .dout(maxlr_rx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(1),.INIT(1'h0)) cr_txclk
   (
      .clka(clk),
      .clkb(tx_clk),
      .res(res),
      .ena_buf(write_cr),
      .din(cr),
      .dout(cr_tx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(1),.INIT(1'h0)) cr_rxclk
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_cr),
      .din(cr),
      .dout(cr_rx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(12),.INIT(12'h800)) rxcr_rxclk
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_rxcr),
      .din(rxcr),
      .dout(rxcr_rx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(2),.INIT(2'h0)) txddr_txclk
   (
      .clka(clk),
      .clkb(tx_clk),
      .res(res),
      .ena_buf(write_txddr),
      .din(txddr),
      .dout(txddr_tx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(8),.INIT(8'h20)) rxdtr_rxclk
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_rxdtr),
      .din(rxdtr),
      .dout(rxdtr_rx_clk)
   );

   eth_sync_buffer_update #(.WIDTH(16),.INIT(16'h1000)) rxdwtr_rxclk
   (
      .clka(clk),
      .clkb(rx_clk),
      .res(res),
      .ena_buf(write_rxdwtr),
      .din(rxdwtr),
      .dout(rxdwtr_rx_clk)
   );
////////////////////////////////////////////////////////////////

   assign dout = ~wr & adr==MAC_ADR_0 ? mac_adr[15:0] :
   ~wr & adr==MAC_ADR_1 ? mac_adr[31:16] :
   ~wr & adr==MAC_ADR_2 ? mac_adr[47:32] :
   ~wr & adr==MULT_ADR_0 ? multicast_adr[15:0] :
   ~wr & adr==MULT_ADR_1 ? multicast_adr[31:16] :
   ~wr & adr==MULT_ADR_2 ? multicast_adr[47:32] :
   ~wr & adr==TXAL ? {11'h000,txalr} :
   ~wr & adr==MINL ? {6'h00,minlr} :
   ~wr & adr==MAXL ? {3'h0,maxlr} :
   ~wr & adr==CTRL ? {15'h000,cr} :
   ~wr & adr==TXS ? {10'h000,txsr} :
   ~wr & adr==RXC ? {2'h0,rx_overflow_clk,rxcr} :
   ~wr & adr==TXDD ? {14'h0,txddr} :
   ~wr & adr==MPA ? mpar :
   ~wr & adr==MRA ? mrar :
   ~wr & adr==MCD ? mcdr :
   ~wr & adr==MC ? {9'h000,mcr} :
   ~wr & adr==MT ? mtr :
   ~wr & adr==MR ? mrr :
   ~wr & adr==TXDS ? {11'h000,txdsr} :
   ~wr & adr==RXFS ? rxfsr :
   ~wr & adr==RXDT ? {8'h00,rxdtr} :
   ~wr & adr==RXDWT ? rxdwtr :
   ~wr & adr==RXDC ? {8'h00,rxdcr} :
   ~wr & adr==RXDWC ? rxdwcr :
   {APPLICATION_DATA_WIDTH{1'h0}} ;

   always@(posedge clk or negedge res)
   if(!res)
      clk__clear_rx_of<=1'b0;
   else if(adr == RXC && wr && din[12]==1'b1)
      clk__clear_rx_of<=1'b1;
   else if(clk__rx_clk_clear_rx_of)
      clk__clear_rx_of<=1'b0;

   always@(posedge rx_clk or negedge res)
   if(!res)
      rx_clk__clear_rx_of_delay<=1'b0;
   else
      rx_clk__clear_rx_of_delay<=rx_clk__clear_rx_of;

   cdc_sync #(.SYNC_STAGE(2'd2),.WIDTH(1)) sync_1
   (
      .clk(rx_clk),
      .res(res),
      .din(clk__clear_rx_of),
      .dout(rx_clk__clear_rx_of)
   );

   cdc_sync #(.SYNC_STAGE(2'd2),.WIDTH(1)) sync_2
   (
      .clk(clk),
      .res(res),
      .din(rx_clk__clear_rx_of),
      .dout(clk__rx_clk_clear_rx_of)
   );

   always@(posedge rx_clk or negedge res)
   if(!res)
      clear_rx_of_flag<=1'b0;
   else
      clear_rx_of_flag<= !rx_clk__clear_rx_of_delay && rx_clk__clear_rx_of;

   cdc_sync #(.SYNC_STAGE(2'd2),.WIDTH(1)) rx_of_clk
   (.clk(clk),.res(res),.din(rx_of),.dout(rx_overflow_clk));

endmodule
