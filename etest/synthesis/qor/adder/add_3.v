// Note: 3 bit optimized with 6-cut (PI)
//       while 4 bit requires 9-cut... generalize cut optimization...
module top #(parameter W = 4)(input [W-1:0] a,b,c, output [W-1:0] q);

assign q = a + b + c - a - c - b;
//assign q = a + b + c[0] -1-(a[2]<<2);

endmodule