module top
(
   output [2:0] am_ctrl
);
// Note: pins of BB are not taken into account during resources calculation (opt), but calculated into resources
   instanc bb_inst
   (
      .am_ctrl
   );

endmodule
