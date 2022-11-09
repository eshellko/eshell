module missed_decoder
(
   input [3:0] addr,
   input [127:120] data,
   input [16:15] buffer,
   output q, w
);
   assign q = data[addr]; // Note: always - X result
   assign w = buffer[addr]; // Note: pass single matched value [15], or 1'bx (1'b0 during synthesis)

endmodule
