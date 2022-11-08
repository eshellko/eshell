module default_x
(
   input [2:0] sel,
   output reg [1:0] q
);

   always@*
   case(sel)
   3'b000: q = 2'b10;
   3'b001: q = 2'b11;
   3'b010: q = 2'b01;
   3'b100: q = 2'b00;
   default: q = 2'bxx;
   endcase

endmoudle
