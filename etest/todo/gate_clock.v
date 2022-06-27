module gate_clock
(
input clk,
input addr,
ready,
output reg wr
);

// reorder events of mux to allow default value to be last one:
always@(posedge clk)
   if(addr) wr <=1'b1;
   else if (!ready) wr <= wr;
   else wr <= 1'b0;

// wr = addr ? 1'b1 : !ready ? wr : 1'b0;
// wr = addr ? 1'b1 : !(!ready) ? 1'b0 : wr;
// thus 'wr' can be used as clock gated register

endmodule
