module carry_save_adder
#(
   parameter W = 24
)
(
   input [W-1:0] a, b, c, output [W-1:0] q
);
`ifdef CSA
   wire [W-1:0] ps = a ^ b ^ c;
   wire [W-1:0] sc = (a & b) | (a & c) | (b & c);
   assign q = ps + (sc << 1);
`else
   assign q = a + b + c;
`endif
endmodule
/*
read carry_save_adder.v
build carry_save_adder
opt
opt
report_timing
read -DCSA carry_save_adder.v
build carry_save_adder
opt
opt
report_timing
exit
*/
