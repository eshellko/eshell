//Design:           Ethernet MAC 10/100 Synchronizer
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
module eth_sync
#(parameter WIDTH = 32'd16)
(
   input clka, clkb, res, ena_buf,
   input [WIDTH-1:0] din,
   output reg[WIDTH-1:0] dout,
   output reg dout_ena
);
// Synchronization of bus from clka to clkb
   reg req, req_sync, req_sync2, req_sync3;
   reg ack, ack_sync, ack_sync2, ack_sync3;

   always@(posedge clka or negedge res)
   if(!res)
      dout_ena<=1'b1;
   else if(ena_buf)
      dout_ena<=1'b0;
   else if(!ack_sync3 && ack_sync2)
      dout_ena<=1'b1;

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
   else if(!req_sync3 && req_sync2)
      dout<=din/*cross_domain*/;

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
