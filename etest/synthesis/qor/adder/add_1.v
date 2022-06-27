module top (input [2:0] a, b, output [2:0] q);
// Note: a[0] shouldn't be used in logic tree
   assign q = a + b - a[0];

endmodule
