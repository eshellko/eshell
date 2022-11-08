module top(input a, b, output q);
// Note: this Liberty cell has internal pin 'TT' that should not be connected in design
   AND2 inst
   (
      .A ( a ),
      .B ( b ),
      .Q ( q )
   );
endmodule
