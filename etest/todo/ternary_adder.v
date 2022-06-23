// TODO: implement such adders detection and implementation inside tool...
module ternary_adder(
   input  [4:0] a, b, c, 
   output [4:0] q
);
// Note: 3:2 compressor should be used
//       as adder uses only 3 of 4 values at every stage, and 3:2 compressor allows to use logic fully (w/o don't cares)
`ifdef __32__
   integer i;
   reg [4:0] qi;
   reg [4:-1] ci;
   reg [4:-2] c2; // carry through position - when some position has sum=4, its' carry must be propagated through 2 positions
   always@*
   begin
      ci = 0;
      c2 = 0;
      qi = 0;
      for(i=0; i<5; i=i+1)
      begin
         c2[i] = a[i] & b[i] & c[i] & ci[i-1];
         qi[i] = a[i] ^ b[i] ^ c[i] ^ ci[i-1] ^ c2[i-2];
//         ci[i] = (a[i] & b[i]) | (a[i] & c[i]) | (a[i] & ci[i-1]) | (b[i] & c[i]) | (b[i] & ci[i-1]) | (c[i] & ci[i-1]); // 60 gates, 20 delay
//         ci[i] = (a[i] & b[i]) | (a[i] & c[i]) | (b[i] & c[i]) | (a[i] & ci[i-1]) | (b[i] & ci[i-1]) | (c[i] & ci[i-1]); // 63 gates, 17 delay
// TODO: check if this carry will not be asserted when 'c2' is
//         ci[i] = (a[i] & b[i]) | (a[i] & c[i]) | (b[i] & c[i]) | (ci[i-1] & (a[i] | b[i] | c[i])); // 57 gates, 11 delay
         ci[i] = (c[i] & (a[i] | b[i])) | (b[i] & a[i]) | (ci[i-1] & (a[i] | b[i] | c[i])); // 57 gates, 11 delay
      end
   end

   assign q = qi + (c2 << 1);
`else
   assign q = a + b + c; // 59 gates, 16 delay
`endif
endmodule
