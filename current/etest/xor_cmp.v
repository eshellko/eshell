module xor_cmp
(
   input [3:0] a, b, output q, w
);
// TODO: check that operands share common logic... FR
   assign q = a > b;
   assign w = a < b;

endmodule

module xor_cmp0
(
   input [3:0] a, b, output q
);

   wire g = a >= b;
   wire nl = !(a < b);
   assign q = g ^ nl; // Note: always 0

endmodule

