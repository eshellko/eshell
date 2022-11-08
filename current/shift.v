// Note: shift here used to nullify N LSB bits - it should be noted that >>
// uses same argument as further <<, and synthesizer should optimize this case
//--------------------------
// Note: compare how coding style affects QoR for 'exp1'
//--------------------------
module shift_a_impl1(input [1:0] awsize, input [2:0] awaddr, output reg [7:0] exp1);
   always@*
      exp1 = (8'hff << (((awaddr >> awsize) << awsize))) ^
             (8'hff << (((awaddr >> awsize) << awsize) + (8'h1 << awsize)));
endmodule

module shift_a_impl2(input [1:0] awsize, input [2:0] awaddr, output reg [7:0] exp1);
   integer i;
   always@*
   begin
      exp1 = 8'h0;
      for(i=0; i<8; i=i+1)
         if(i >= ((awaddr >> awsize) << awsize))
            if(i < ((awaddr >> awsize ) << awsize) + (1<<awsize))
               exp1 [i] = 1'b1;
   end
endmodule
//--------------------------
//--------------------------
module shift_impl1 ( input [7:0] a, input [2:0] sh, output [7:0] q );
   assign q =
// TODO: when sh==3'd... result is much better 
      (sh == 1) ? {a[7:1], 1'b0} :
      (sh == 2) ? {a[7:2], 2'b0} :
      (sh == 3) ? {a[7:3], 3'b0} :
      (sh == 4) ? {a[7:4], 4'b0} :
      (sh == 5) ? {a[7:5], 5'b0} :
      (sh == 6) ? {a[7:6], 6'b0} :
      (sh == 7) ? {a[7:7], 7'b0} : a;
endmodule

module shift_impl2 ( input [7:0] a, input [2:0] sh, output [7:0] q );
   wire [7:0] mask = (8'd1 << sh) - 1;
   assign q = a & ~mask;
endmodule

module shift_impl3 ( input [7:0] a, input [2:0] sh, output [7:0] q );
   assign q = (a >> sh) << sh; // result should be '?a[7], ?a[6], ?a[5]...'
endmodule
