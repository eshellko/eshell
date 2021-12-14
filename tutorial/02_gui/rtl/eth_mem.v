//Design:           Ethernet MAC 10/100 Memory
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
module eth_mem
#( parameter WIDTH = 32'd16,
   AWIDTH = 32'd14,
   DEPTH = 32'd16384
)
(
   input clk, wr,
   input [AWIDTH-1:0] adr_wr, adr_rd,
   input [WIDTH-1:0] din,
   output [WIDTH-1:0] dout
);
   reg [WIDTH-1:0] mem [DEPTH-1:0];
   always@(posedge clk)
   if(wr)
      mem[adr_wr]<=din;
   assign dout = mem[adr_rd];

endmodule
