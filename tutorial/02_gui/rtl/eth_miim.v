//Design:           Ethernet Media Independent
//                  Interface Management (MIIM)
//Revision:         1.0
//Date:             2011-05-19
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
//Description:      compliant with IEEE 802.3-2005
//                  (Clause 22.2.4.5)
module eth_miim(
   input clk, res,
   input [15:0] din,
   input mdi, output reg mdo, mdo_en,
   output reg mdc,
   output reg interrupt,
   input write_mcr, write_mtr, write_mpar, write_mrar, write_mcdr,
   output reg [15:0] mtr, mrr, mcdr,
   output reg [4:0] mpar, mrar,
   output reg [6:0] mcr
);
//miim control register
   wire start, trx_type, pre_ena;
   wire tx_ie, rx_ie;
   wire txip, rxip;
   reg [15:0] clk_cnt;
   reg [6:0] bit_cnt;
   wire mdc_rise, mdc_fall;
   assign mdc_rise = clk_cnt==mcdr & ~mdc;
   assign mdc_fall = clk_cnt==mcdr & mdc;

   always@(posedge clk or negedge res)
   if(!res)
      mcdr<=16'hFFFF;
//discard writing to mcdr during transfer
   else if(write_mcdr && !(start || rxip || txip))
      mcdr<=din;

   always@(posedge clk or negedge res)
   if(!res)
      mpar<=5'h00;
   else if(write_mpar && !(start || rxip || txip))
      mpar<=din[4:0];

   always@(posedge clk or negedge res)
   if(!res)
      mrar<=5'h00;
   else if(write_mrar && !(start || rxip || txip))
      mrar<=din[4:0];

   always@(posedge clk or negedge res)
   if(!res)
      mtr<=16'h0000;
   else if(write_mtr && !(start || rxip || txip))
      mtr<=din;

   always@(posedge clk or negedge res)
   if(!res)
      mcr[4:0]<=5'h00;
   //disable writing during active transfer
   else if(write_mcr && !(start || rxip || txip))
      mcr[4:0]<=din[4:0];
   else
      mcr[0]<=1'b0;//clear start bit

   always@(posedge clk or negedge res)
   if(!res)
      mcr[5]<=1'h0;
   else if(start && trx_type==1'b0)
      mcr[5]<=1'b1;
   else if(bit_cnt==7'd0)
      mcr[5]<=1'b0;

   always@(posedge clk or negedge res)
   if(!res)
      mcr[6]<=1'h0;
   else if(start && trx_type==1'b1)
      mcr[6]<=1'b1;
   else if(bit_cnt==7'd0)
      mcr[6]<=1'b0;

   assign start = mcr[0];
   assign trx_type = mcr[1]; // 0 - RX, 1 - TX
   assign pre_ena = mcr[2];
   assign rx_ie = mcr[3];
   assign tx_ie = mcr[4];
   assign rxip = mcr[5];
   assign txip = mcr[6];

   always@(posedge clk or negedge res)
   if(!res)
      mrr<=16'h0000;
   else if(rxip && mdc_rise && bit_cnt<7'd17)
      mrr<={mrr[14:0],mdi};

   always@(posedge clk or negedge res)
   if(!res)
      mdo<=1'b1;
   else if(start)
      mdo<=pre_ena;//1-pre, 0-ST
   else if(mdc_fall)
      case(bit_cnt)
         7'd33: mdo<=1'b0;
         7'd32: mdo<=1'b1;
         7'd31: mdo<=rxip;
         7'd30: mdo<=txip;
         7'd29: mdo<=mpar[4];
         7'd28: mdo<=mpar[3];
         7'd27: mdo<=mpar[2];
         7'd26: mdo<=mpar[1];
         7'd25: mdo<=mpar[0];
         7'd24: mdo<=mrar[4];
         7'd23: mdo<=mrar[3];
         7'd22: mdo<=mrar[2];
         7'd21: mdo<=mrar[1];
         7'd20: mdo<=mrar[0];
         7'd19: mdo<=1'b1;
         7'd18: mdo<=1'b0;
         7'd17: mdo<=mtr[15];//data
         7'd16: mdo<=mtr[14];
         7'd15: mdo<=mtr[13];
         7'd14: mdo<=mtr[12];
         7'd13: mdo<=mtr[11];
         7'd12: mdo<=mtr[10];
         7'd11: mdo<=mtr[9];
         7'd10: mdo<=mtr[8];
         7'd9: mdo<=mtr[7];
         7'd8: mdo<=mtr[6];
         7'd7: mdo<=mtr[5];
         7'd6: mdo<=mtr[4];
         7'd5: mdo<=mtr[3];
         7'd4: mdo<=mtr[2];
         7'd3: mdo<=mtr[1];
         7'd2: mdo<=mtr[0];
         default: mdo<=1'b1;//preamble + idle
      endcase

   always@(posedge clk or negedge res)
   if(!res)
      mdo_en<=1'b0;
   else if(start)
      mdo_en<=1'b1;
   else if(rxip && bit_cnt==7'd18 && mdc_rise)
      mdo_en<=1'b0;
   else if(!rxip && !txip)
      mdo_en<=1'b0;

   always@(posedge clk or negedge res)
   if(!res)
      bit_cnt<=7'h00;
   else if(start)
      bit_cnt<= pre_ena ? 7'd64 : 7'd32;
   else if(|bit_cnt && mdc_fall)
      bit_cnt<=bit_cnt-7'h01;

   always@(posedge clk or negedge res)
   if(!res)
      mdc<=1'b0;
   else if((txip || rxip) && clk_cnt == mcdr)
      mdc<=!mdc;
   else if(!txip && !rxip)
      mdc<=1'b0;

   always@(posedge clk or negedge res)
   if(!res)
      clk_cnt<=16'h0000;
   else if(txip || rxip)
   begin
      if(clk_cnt == mcdr)
         clk_cnt<=16'h0000;
      else
         clk_cnt<=clk_cnt+16'h0001;
   end

   always@(posedge clk or negedge res)
   if(!res)
      interrupt<=1'b0;
   else if(bit_cnt==7'd0 && ((txip && tx_ie) || (rxip && rx_ie)))
      interrupt<=1'b1;
   else
      interrupt<=1'b0;

endmodule
