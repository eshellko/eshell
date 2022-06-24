module ternary_adder(
   input  [4:0] a, b, c, 
   output [4:0] q
);
// Note: 4:2 compressor
`ifdef __42__
   integer i;
   reg [4:0] qi;
   reg [4:-1] ci;
   reg [4:-1] ei;
   reg x1;
   always@*
   begin
      ci = 0;
      ei = 0;
      qi = 0;
      for(i=0; i<5; i=i+1)
      begin
	     ei[i] = (a[i] & b[i]) | (a[i] & c[i]) | (b[i] & c[i]);
		 x1 = a[i] ^ b[i] ^ c[i] ^ ci[i-1];
		 qi[i] = x1 ^ ei[i-1];
		 ci[i] = x1 ? ei[i-1] : ci[i-1];
      end
   end

   assign q = qi;
`else
   assign q = a + b + c; // 59 gates, 16 delay
`endif
endmodule
