// Note: AND gate after XOR tree will not give improve in timing.
//       as it can be moved up, but XOR tree is balanced and thus has no place
//       to reduce delay
// A: there is no timing improve possible here, as 'e' can be applied as early as possible to 'abcd' which are already balanced
//    this case points, that balancing not always required, especially in case of balanced xor tree...
//    need to define criteria for such balancing move
module top(input a,b,c,d,e, output q);

wire w0 = a ^ b;
wire w1 = c ^ d;
wire w2 = w0 ^ w1;
// TODO: when duplicated 'a' is in use, it is not optimized even on small 4-cut...
assign q = w2 & a/*e*/;

endmodule
