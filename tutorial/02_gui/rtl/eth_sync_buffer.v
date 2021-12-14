//Design:           Ethernet MAC 10/100 Synchronizer with buffer
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
module eth_sync_buffer
#(parameter WIDTH = 32'd16)
(
   input clka, clkb, res, ena_buf,
   input [WIDTH-1:0] din,
   output reg[WIDTH-1:0] dout
);
// Synchronization of bus from clka to clkb
   reg [WIDTH-1:0] din_buf;
   reg req, req_sync, req_sync2, req_sync3;
   reg ack, ack_sync, ack_sync2, ack_sync3;
//write data to stable buffer
   always@(posedge clka or negedge res)
   if(!res)
      din_buf<={WIDTH{1'b0}};
   else if(ena_buf && !req)
      din_buf<=din;

   always@(posedge clka or negedge res)
   if(!res)
      req<=1'b0;
   else if(ena_buf && !req)
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
      dout<={WIDTH{1'b0}};
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
