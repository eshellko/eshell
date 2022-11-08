module signed_index
(
   input clk, we,
   input [3:0] din,
   input signed [2:0] ad,
   output [3:0] q
);
   reg [3:0] ram [3:-4];

   always@(posedge clk)
   if(we)
      ram [ad] <= din;

   assign q = ram[ad];

endmodule
