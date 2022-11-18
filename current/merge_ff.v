module top
(
   input clk, reset_n, din, output [3:0] log
);
   reg a1;
   reg a0;
   assign log[3] = a1;
   assign log[2] = a0;
   assign log[1] = a1 & a0;
   assign log[0] = a1 | a0;
// Note: registers have same data input, the only difference is reset value
   always@(posedge clk or negedge reset_n)
   if(!reset_n)
   begin
      a1 <= 1'b1;
      a0 <= 1'b0;
   end
   else
   begin
      a1 <= din;
      a0 <= din;
   end
// flops can't be merged, as their function is different, but...
// they can be combined in a following manner (TODO: report such opportunity, but not to change design, as:)
   // - flops can be implemented to balance output fanout, or clock fanout
   // - logic in reset line can be untolerable
   // - path delay from flop can be critical
// XNOR(reset_n) can be added to the output of 'a0'
//    this gate will drive logic, previously driven by 'a1':
/*
   reg a0;
   wire a1 = a0 ^ !reset_n;
   assign log[3] = a1;
   assign log[2] = a0;
   assign log[1] = a1 & a0;
   assign log[0] = a1 | a0;

   always@(posedge clk or negedge reset_n)
   if(!reset_n)
      a0 <= 1'b0;
   else
      a0 <= din;
*/
// PRO:
// - smaller area (assume that XNOR smaller than DFF)
// CONS:
// - longer runtime to detect such cases
// - logic in reset path
// - worst timing path from FF (as fanout increased, and XOR added)
endmodule
