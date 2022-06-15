//Design:           Ethernet MAC 10/100 Receive Frame Checker
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
module eth_rx_integrity(
   input [3:0] rxd,
   input rx_clk, res, rx_dv, rx_er, rip, rip_delay, rip_delay2,
   rip_delay3,
   input ignore_rx_error, ignore_alignment_error, ignore_adr_error,
   ignore_max_error, ignore_min_error, ignore_fcs_error,
   nibble_position, full_duplex,
   input [47:0] mac_adr, mult_adr, dest_adr,
   input [9:0] min_len,
   input [12:0] max_len,
   input [17:0] nibble_cnt,
   output [5:0] frame_errors, frame_errors_masked,
   output reg [1:0] rx_adr,
   input [3:0] drop_address
);
   reg rx_error, alignment_error, adr_error, max_error, min_error,
   fcs_error;
   wire [47:0] pause_adr;//see 31b.1
   wire [31:0] fcs;

   assign frame_errors = {rx_error, alignment_error,
   fcs_error, min_error, max_error, adr_error};
   assign frame_errors_masked = {rx_error & ~ignore_rx_error,
    alignment_error & ~ignore_alignment_error,
     fcs_error & ~ignore_fcs_error,
      min_error & ~ignore_min_error,//always min_error
       max_error & ~ignore_max_error,//always max_error
        adr_error & ~ignore_adr_error};
/////////////////////////////////////////
//
// Check CRC.
//
// CRC calculation for received packet
/////////////////////////////////////////
   eth_crc crc32(
      .clk(rx_clk),
      .res(res),
      .ena(rip),
      .shift(1'b0),
      .din(rxd),
      .fcs(fcs)
   );

   always@(posedge rx_clk or negedge res)
   if(!res)
      fcs_error<=1'b0;
   else if(fcs!=32'hC704DD7B && !rip && rip_delay)
      fcs_error<=1'b1;
   else if(!rip_delay2 && rip_delay3)
      fcs_error<=1'b0;
/////////////////////////////////////////
//
// Check Length.
//
/////////////////////////////////////////
   always@(posedge rx_clk or negedge res)
   if(!res)
      max_error<=1'b0;
   else if(!rip && rip_delay && nibble_cnt>{4'b0,max_len,1'b0})
      max_error<=1'b1;
   else if(!rip_delay2 && rip_delay3)
      max_error<=1'b0;

   always@(posedge rx_clk or negedge res)
   if(!res)
      min_error<=1'b0;
   else if(!rip && rip_delay && nibble_cnt<{7'b0,min_len,1'b0})
      min_error<=1'b1;
   else if(!rip_delay2 && rip_delay3)
      min_error<=1'b0;
/////////////////////////////////////////
//
// Check Address.
//
// Get Destination Address of the received packet.
// Compare it with one of the 4 valid addresses
// (in Promocious Mode pass without compare).
/////////////////////////////////////////
   assign pause_adr = 48'h0180C2000001;

   always@(posedge rx_clk or negedge res)
   if(!res)
      adr_error<=1'b0;
   else if(!rip && rip_delay &&
   (dest_adr!=mac_adr || drop_address[3]) &&
   (dest_adr!=48'hFFFFFFFFFFFF || drop_address[0]) &&
   (dest_adr!=mult_adr || drop_address[2]) &&
   (dest_adr!=pause_adr || drop_address[1] || !full_duplex))
      adr_error<=1'b1;
   else if(!rip_delay2 && rip_delay3)
      adr_error<=1'b0;

   always@(posedge rx_clk or negedge res)
   if(!res)
      rx_adr<=2'h0;
   else if(dest_adr==mac_adr)
      rx_adr<=2'b00;
   else if(dest_adr==48'hFFFFFFFFFFFF)
      rx_adr<=2'b01;
   else if(dest_adr==mult_adr)
      rx_adr<=2'b10;
   else if(dest_adr==pause_adr)
      rx_adr<=2'b11;
   else
      rx_adr<=2'h0;
/////////////////////////////////////////
//
// Check alignment.
//
/////////////////////////////////////////
   always@(posedge rx_clk or negedge res)
   if(!res)
      alignment_error<=1'b0;
   else if(nibble_position && !rip && rip_delay)
      alignment_error<=1'b1;
   else if(!rip_delay2 && rip_delay3)
      alignment_error<=1'b0;
/////////////////////////////////////////
//
// Check RX_ER.
//
/////////////////////////////////////////
//*E : what if RX_ER asserted during preamble but rip will not asserted - !?
// 0x555(rx_er)5555A----  rx_error will be asserted for next frame
   always@(posedge rx_clk or negedge res)
   if(!res)
      rx_error<=1'b0;
   else if(rx_dv && rx_er)
      rx_error<=1'b1;
   else if(!rip_delay2 && rip_delay3)
      rx_error<=1'b0;

endmodule
