module top(input   a,   b,   c,   d, output   q);
`ifdef IMPL1
   assign q = a*c + a*d + b*c + b*d + d;
`elsif IMPL2
   assign q = c*(a+b) + d*(a + b + 1);
`else
   assign q = (a+b)*(c+d) + d;
`endif

endmodule
