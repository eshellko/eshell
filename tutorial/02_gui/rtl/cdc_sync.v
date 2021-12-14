//Design:           Cross Domain Clocking (CDC) Synchronizer
//Revision:         1.0
//Date:             2011-06-23
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
module cdc_sync
#( parameter SYNC_STAGE = 2'd0,
             WIDTH      = 32'd3)
(  input clk, res,
   input  [WIDTH-1:0] din,
   output [WIDTH-1:0] dout);

generate
//begin: synchronization
   if(SYNC_STAGE==2'd0)
   begin
      assign dout = din;
   end
   else if(SYNC_STAGE==2'd1)
   begin
      reg [WIDTH-1:0] sync_1d;
      always@(posedge clk or negedge res)
      if(!res)
         sync_1d<={(WIDTH){1'b0}};
      else
         sync_1d<=din;

      assign dout = sync_1d;
   end
   else if(SYNC_STAGE==2'd2)
   begin
      reg [WIDTH-1:0] sync_1d, sync_2d;
      always@(posedge clk or negedge res)
      if(!res)
      begin
         sync_1d<={(WIDTH){1'b0}};
         sync_2d<={(WIDTH){1'b0}};
      end
      else
         {sync_2d,sync_1d}<={sync_1d,din};

      assign dout = sync_2d;
   end
   else if(SYNC_STAGE==2'd3)
   begin
      reg [WIDTH-1:0] sync_1d, sync_2d, sync_3d;
      always@(posedge clk or negedge res)
      if(!res)
      begin
         sync_1d<={(WIDTH){1'b0}};
         sync_2d<={(WIDTH){1'b0}};
         sync_3d<={(WIDTH){1'b0}};
      end
      else
         {sync_3d,sync_2d,sync_1d}<={sync_2d,sync_1d,din};

      assign dout = sync_3d;
   end
//end
endgenerate

endmodule
