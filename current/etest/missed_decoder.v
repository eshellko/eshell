module missed_decoder
(
   input [3:0] addr,
   input [127:120] data,
   input [16:15] buffer,
   output q, w
);
   assign q = data[addr]; // Note: always - X result
   assign w = buffer[addr]; // Note: always pass single matched value [15]

endmodule
