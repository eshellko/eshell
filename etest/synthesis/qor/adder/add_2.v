module top #(parameter WIDTH=3) (input [WIDTH-1:0] a, b, output [WIDTH-1:0] q);
// Note: design should became a buffer
   assign q = a + b - a;

endmodule
