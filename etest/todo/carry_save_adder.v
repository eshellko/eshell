module carry_save_adder
#(
   parameter W = 24
)
(
   input [W-1:0] a, b, c, output [W:0] q
);
`ifdef CSA
   wire [W-1:0] ps;
   wire [W-1:0] sc;
   genvar gen_i;
   for(gen_i = 0; gen_i < W; gen_i = gen_i + 1)
   begin
      assign ps[gen_i] = a[gen_i] ^ b[gen_i] ^ c[gen_i];
      assign sc[gen_i] = (a[gen_i] & b[gen_i]) | (a[gen_i] & c[gen_i]) | (b[gen_i] & c[gen_i]);
   end

   wire [W:0] s0 = {sc, 1'b0};
   wire [W:0] s1 = {1'b0, ps};

   assign q = s0 + s1;

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
