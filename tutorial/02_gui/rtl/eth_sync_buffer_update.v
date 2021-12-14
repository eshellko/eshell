//Design:           Ethernet MAC 10/100 Synchronizer with buffer
//                  and update signal (if DIN changed during sync)
//Revision:         1.0
//Date:             2011-07-29
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
module eth_sync_buffer_update
#(parameter WIDTH = 32'd16,
  parameter [WIDTH-1:0] INIT = 0)
(
   input clka, clkb, res, ena_buf,
   input [WIDTH-1:0] din,
   output reg[WIDTH-1:0] dout
);
// Synchronization of bus from clka to clkb
   reg [WIDTH-1:0] din_buf;
   reg req, req_sync, req_sync2, req_sync3;
   reg ack, ack_sync, ack_sync2, ack_sync3;
   reg update, set_update;
   always@(posedge clka or negedge res)
   if(!res)
      update<=1'b0;
   else if(ena_buf && req)
      update<=1'b1;
   else if(set_update)
      update<=1'b0;
   always@(posedge clka or negedge res)
   if(!res)
      set_update<=1'b0;
   else
      set_update<=update && !req && !ack_sync3;
//write data to stable buffer
   always@(posedge clka or negedge res)
   if(!res)
      din_buf<={WIDTH{1'b0}};
   else if((ena_buf && !req) || (update && !req && !ack_sync3))
      din_buf<=din;

   always@(posedge clka or negedge res)
   if(!res)
      req<=1'b0;
   else if((ena_buf && !req) || (update && !req && !ack_sync3))
      req<=1'b1;
   else if(!ack_sync3 && ack_sync2)
      req<=1'b0;

   always@(posedge clkb or negedge res)
   if(!res)
      {req_sync3,req_sync2,req_sync}<=3'b000;
   else
      {req_sync3,req_sync2,req_sync}<={req_sync2,req_sync,req/*cross-domain*/};
      
   always@(posedge clkb or negedge res)
   if(!res)
      dout<=INIT;//{WIDTH{1'b0}};
// Writing to 'din_buf' disabled to this point
// so it can be safely passed through domain
   else if(!req_sync3 && req_sync2)
      dout<=din_buf/*cross_domain stable*/;

   always@(posedge clkb or negedge res)
   if(!res)
      ack<=1'b0;
   else if(!req_sync3 && req_sync2)
      ack<=1'b1;
   else if(req_sync3 && !req_sync2)
      ack<=1'b0;

   always@(posedge clka or negedge res)
   if(!res)
      {ack_sync3,ack_sync2,ack_sync}<=3'b000;
   else
      {ack_sync3,ack_sync2,ack_sync}<={ack_sync2,ack_sync,ack/*cross-domain*/};

endmodule
/*
// Testbench for module eth_sync_buffer_update
module tb;
   reg clka, clkb, res, ena_buf;
   reg [15:0] din;
   wire [15:0] dout;
   always #3 clka=!clka;
   always #7 clkb=!clkb;

   eth_sync_buffer_update #(16) dut
   ( clka, clkb, res, ena_buf, din, dout );

   initial
   begin
      #0 res=0; din=0; clka=0; clkb=0; ena_buf=0;
      #3 res=1;
      #7 din=4; ena_buf=1;
      #6 ena_buf=0;
      #40 din=76; ena_buf=1;
      #6 ena_buf=0;
      #100 din=176; ena_buf=1;
      #6 din=124; ena_buf=1;
      #6 din=33; ena_buf=1;
      #6 ena_buf=0;
      #60 din=315; ena_buf=1;
      #6 ena_buf=0;
      #200 $finish;
   end

endmodule
*/