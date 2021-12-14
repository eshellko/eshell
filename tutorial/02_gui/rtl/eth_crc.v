//Design:           Ethernet MAC 10/100 CRC-32 Generator/Checker
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -

module eth_crc(
   input clk, res, ena, shift,
   input [3:0] din,
   output reg [31:0] fcs
);
   wire [31:0] crc_false [15:0];

   assign crc_false[0]=32'h00000000;
   assign crc_false[1]=32'h04C11DB7;
   assign crc_false[2]=32'h09823B6E;
   assign crc_false[3]=32'h0D4326D9;
   assign crc_false[4]=32'h130476DC;
   assign crc_false[5]=32'h17C56B6B;
   assign crc_false[6]=32'h1A864DB2;
   assign crc_false[7]=32'h1E475005;
   assign crc_false[8]=32'h2608EDB8;
   assign crc_false[9]=32'h22C9F00F;
   assign crc_false[10]=32'h2F8AD6D6;
   assign crc_false[11]=32'h2B4BCB61;
   assign crc_false[12]=32'h350C9B64;
   assign crc_false[13]=32'h31CD86D3;
   assign crc_false[14]=32'h3C8EA00A;
   assign crc_false[15]=32'h384FBDBD;

   always @(posedge clk or negedge res)
   if(!res)
      fcs<=32'hffffffff;
   else if(ena)
      fcs<={fcs[27:0],4'h0}^crc_false[fcs[31:28]^{din[0],din[1],din[2],din[3]}];
   else if(shift)
      fcs<={fcs[27:0],4'hF};
   else
      fcs<=32'hffffffff;

endmodule
