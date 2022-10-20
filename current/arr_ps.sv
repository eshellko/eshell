module arr_ps(input [2:0] ptr, output [3:0] q);

   wire pack_arr [7:0]; // Note: packed array
   assign q = pack_arr[ptr+:4]; // Error: part-select for array is not valid

endmodule
