module xor_tree
(
   input a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,
   output q
);
// Note: there are 15 inputs to XOR tree
//       thus 1/8, 1/4, 1/2, and final - 4 level with delay 2 each on balanced tree = 8 gates delay
assign q = a^ b^c^d^e^f^g^h^i^j^k^l^m^n^o;

endmodule
