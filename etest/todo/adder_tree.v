module adder_tree
(
   output [15:0] x,
   input [15:0] a, b, c, d
);
`ifdef CASE1
//---------------------
// Simple chain of additions and subtractions - result is 0
//---------------------
   assign x = a + b + c + d - a - c - d - b;
`elsif CASE2
//---------------------
// Same as above, but additions grouped and moved from top of expression - result 'all ones'
//---------------------
   assign x = ~(a + b + c + d - a - c - (d + b));
`elsif CASE3
//---------------------
// MSB of 'd' provided as is, while other elements should be removed - result should be {d[15],15'h0}
//---------------------
   assign x = ~(a + b + c + d - a - c - (d[14:0] + b));
`elsif CASE4
//---------------------
// Order of short operands that should not impact QoR
// Wider operands should be used first, as their carry is longer?
// 2 cases points this case
//---------------------
// Note: 2nd has smaller delay with same area
   assign x = a[3:0] + b[7:0] + c[5:0];
`elsif CASE5
   assign x = b[7:0] + c[5:0] + a[3:0];
`elsif CASE6
//---------------------
// constant additions grouped together
//---------------------
   assign x = 1 + a + 2; // converted to 'a + 3'
`else
//---------------------
// MSB of a inverted, while others buffered
// additions reordered to propagate valid sum to MSB
//---------------------
   assign x = 16'h3000 + a + 16'h4000 + 16'h1000;
`endif

endmodule
