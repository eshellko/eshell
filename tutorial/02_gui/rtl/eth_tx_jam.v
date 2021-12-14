//Design:           Ethernet MAC 10/100 Transmitter Collision Interface
//Revision:         1.0
//Date:             2011-07-28
//Company:          Eshell
//Designer:         A.Kornukhin
//Last modified by: -
module eth_tx_jam(
   input tx_clk, res, tx_en, tx_en_delay, load_jam, duplex,
   input [4:0] current_attempt, output reg [3:0] jam_cnt,
   output reg [16:0] jam_pause_cnt
);
//bits [10:9] unused for counter but used for random value calculation
   wire [9:0] cnta_next;
   reg [8:0] rnd;
   reg [10:0] cnta, cntb;

   always@(posedge tx_clk or negedge res)
   if(!res)
      jam_cnt<=4'h0;
   else if(load_jam)
      jam_cnt<=4'h8;
   else if(|jam_cnt)
      jam_cnt<=jam_cnt - 4'h1;

   always@(posedge tx_clk or negedge res)
   if(!res)
   begin
      cnta<=11'h798;
      cntb<=11'h555;
   end
   else if(!duplex && tx_en && !tx_en_delay)
   begin
      cnta<={cnta[9:0],cnta[10]|cntb[0]};
      cntb<={cntb[0],cntb[10:1]};
   end

   assign cnta_next = cnta[8:0] + 9'h001;

   always@(posedge tx_clk or negedge res)
   if(!res)
      rnd<=9'h000;
   else if(load_jam)
      case(current_attempt)
         5'd0: rnd<=9'h001;
         5'd1: rnd<=cnta_next[8:0] & 9'h001;
         5'd2: rnd<=cnta_next[8:0] & 9'h003;
         5'd3: rnd<=cnta_next[8:0] & 9'h007;
         5'd4: rnd<=cnta_next[8:0] & 9'h00F;
         5'd5: rnd<=cnta_next[8:0] & 9'h01F;
         5'd6: rnd<=cnta_next[8:0] & 9'h03F;
         5'd7: rnd<=cnta_next[8:0] & 9'h07F;
         5'd8: rnd<=cnta_next[8:0] & 9'h0FF;
         5'd9: rnd<=cnta_next[8:0] & 9'h1FF;
         default: rnd<=cnta_next[8:0];
      endcase
//pause = integer number of slotTimes (1 slotTime = 512 BitTimes)
   always@(posedge tx_clk or negedge res)
   if(!res)
      jam_pause_cnt<=17'h00000;
   else if(jam_cnt==17'h00001)
      jam_pause_cnt<={rnd[8:0],1'b1,7'b0000000};//aka *128
   else if(|jam_pause_cnt)
      jam_pause_cnt<=jam_pause_cnt-17'h00001;

endmodule
