module case_10
(
   input [3:0] din,
   output reg q
);
   wire msb = din[0] & !din[0]; // always 0

always @(*) begin
  case ({msb, din[3:1]})
    4'b0110, 4'b0111, 4'b0001, 4'b0100, 4'b0000: q = 1'b1;
    4'b0010, 4'b0101, 4'b0011: q = 1'b0; 
// following are never happen, as 'msb==0' but logic deep enough to not be covered by optimizations
//    4'b1110, 4'b1111, 4'b1001, 4'b1100, 4'b1000: q = 1'b1;
//    4'b1010, 4'b1101, 4'b1011: q = 1'b0; 
  endcase
end

endmodule
