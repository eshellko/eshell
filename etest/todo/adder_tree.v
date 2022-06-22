module adder_tree
(
   output [15:0] x,
   input [15:0] a, b, c, d
);

//   assign x = a + b + c + d - a - c - d - b; // Note: should be 0
   // TODO: check optimization when not at top of expression...
   assign x = ~(a + b + c + d - a - c - (d + b)); // Note: should be 0
//   assign x = ~(a + b + c + d - a - c - (d[14:0] + b)); // Note: should be {d[15],15'h0}


// TODO: register this example...
// Note: 2nd has smaller delay with same area
//   assign x = a[3:0] + b[7:0] + c[5:0];
//   assign x = b[7:0] + c[5:0] + a[3:0];


// TODO: if -b missed, then just buffer from b to x
//assign x = 1 + a + 2; // TODO: convert to 1+2+a
//assign x = 4096 + a + 8192 /*+ b*/ + 32768 + b; // TODO: convert to 1+2+a
//assign x = a + 4096 + 8192 /*+ b*/ + 32768 + b; // TODO: convert to 1+2+a
//assign x = 4096 + 8192 + a + b + 32768; // TODO: convert to 1+2+a
/*
assign x = 16'h3000 + a + 16'h4000 + 16'h1000 ; // Note: MSB inverted while others are passed as is
*/
endmodule
