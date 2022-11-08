// Note: AND gate after XOR tree will not give improve in timing.
//       as it can be moved up, but XOR tree is balanced and thus has no place
//       to reduce delay
module top(input a,b,c,d,e, output q);

wire w0 = a ^ b;
wire w1 = c ^ d;
wire w2 = w0 ^ w1;
assign q = w2 & e;

endmodule
