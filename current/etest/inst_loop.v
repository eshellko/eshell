module top(input [3:0] a, output [3:0] q);
   genvar gen_i;
   for(gen_i=0; gen_i<2; gen_i=gen_i+1)
      pass inst(.a(a[gen_i*2+:2]), .q(q[gen_i*2+:2]));
endmodule

module pass(input [1:0] a, output [1:0] q);
   wire [1:0] t = ~a;
   assign q = {t[1],t[0]};
endmodule