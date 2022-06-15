//Design:           Ethernet MAC 10/100 Software Registers
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
module eth_regs
#( parameter WIDTH = 32'd16 )
(
   input clk, res,
   input [WIDTH-1:0] data,
   input write_mac_0, write_mac_1, write_mac_2,
   write_mult_0, write_mult_1, write_mult_2,
   write_txalr, write_minlr, write_maxlr,
   write_cr, write_rxcr,
   write_txddr, write_rxdtr, write_rxdwtr,
   output reg [47:0] mac_adr, multicast_adr,
   output reg [4:0] txalr,
   output reg [12:0] maxlr,
   output reg [9:0] minlr,
   output reg cr,
   output reg [11:0] rxcr,
   output reg [1:0] txddr,
   output reg [7:0] rxdtr,
   output reg [15:0] rxdwtr
);
   always@(posedge clk or negedge res)
   if(!res)
      mac_adr<=48'h000000000000;
   else if(write_mac_0)
      mac_adr[15:0]<=data[15:0];
   else if(write_mac_1)
      mac_adr[31:16]<=data[15:0];
   else if(write_mac_2)
      mac_adr[47:32]<=data[15:0];

   always@(posedge clk or negedge res)
   if(!res)
      multicast_adr<=48'h000000000000;
   else if(write_mult_0)
      multicast_adr[15:0]<=data[15:0];
   else if(write_mult_1)
      multicast_adr[31:16]<=data[15:0];
   else if(write_mult_2)
      multicast_adr[47:32]<=data[15:0];

   always@(posedge clk or negedge res)
   if(!res)
      txalr<=5'h10;
   else if(write_txalr)
      txalr<=data[4:0];

   always@(posedge clk or negedge res)
   if(!res)
      minlr<=10'h040;
   else if(write_minlr)
      minlr<=data[9:0];

   always@(posedge clk or negedge res)
   if(!res)
      maxlr<=13'h05EE;
   else if(write_maxlr)
      maxlr<=data[12:0];

   always@(posedge clk or negedge res)
   if(!res)
      cr<=1'h0;
   else if(write_cr)
      cr<=data[0];

   always@(posedge clk or negedge res)
   if(!res)
      rxcr<=12'h800;
   else if(write_rxcr)
      rxcr<={data[11:3],2'b00,data[0]};

   always@(posedge clk or negedge res)
   if(!res)
      txddr<=2'h0;
   else if(write_txddr)
      txddr<=data[1:0];

   always@(posedge clk or negedge res)
   if(!res)
      rxdtr<=8'h20;
   else if(write_rxdtr)
      rxdtr<=data[7:0];

   always@(posedge clk or negedge res)
   if(!res)
      rxdwtr<=16'h1000;
   else if(write_rxdwtr)
      rxdwtr<=data[15:0];

endmodule
