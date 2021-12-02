// Design:           SDRAM controller
// Revision:         2.1
// Date:             2015-08-27
// Company:          Eshell
// Designer:         A.Kornukhin (kornukhin@mail.ru)
// Last modified by: 1.0 2015-04-13 A.Kornukhin Initial release
//                   1.1 2015-07-09 A.Kornukhin dynamic refresh configuration capability added
//                   2.0 2015-08-17 A.Kornukhin pipeline strategy completely rewritten
//                                  was: ACTIVE-READ or WRITE-PRECHARGE
//                                  now: if(ACTIVE) PRECHARGE if required
//                                       ACTIVE if required
//                                       READ or WRITE with AUTO-PRECHARGE if REFRESH required
//                   2.1 2015-08-27 A.Kornukhin 8x AUTO-REFRESH instead of 2x to support more devices during initialization
//                                              100 us initial delay is now 200 us to support additional devices(like HYB 39S128400/800/160CT(L))
// Description:      Controller for Micron SDRAM MT48LC32M8A2 ... 8M32 ...

module ehl_sdram
#(
   parameter DATA_WIDTH = 32,
   SDRAM_WIDTH = 8,
   ROW_ADDR_WIDTH = 13, // 8K
   COL_ADDR_WIDTH = 10, // 1K
   BANK_ADDR_WIDTH = 2, // Note: only 4 banks supported, if less required -> 2 'addr' MSB should be tied low
   CS_ADDR_BITS = 0,
   CLOCK_FREQUENCY_MHZ = 100,
   parameter [12:0] MODE_REGISTER = 13'h0222, // value to store into Mode Register
// Timing parameters, which should be extracted from datasheet for selected memory
   parameter PRECHARGE_COMMAND_PERIOD_NS = 20,
   AUTO_REFRESH_PERIOD_NS = 66,
   ACTIVE_TO_READ_OR_WRITE_DELAY_NS = 20,
   WRITE_RECOVERY_TIME_NS = 15,
   LOAD_MODE_REGISTER_TO_ACTIVE_OR_REFRESH_CYCLES = 2,
   AUTO_REFRESH_CYCLE_NS = 7810,
// Fault tolerance enable
   parameter FT_ENA = 0
   , MC_LENGTH = 8 // number of multi-cycles on RS Decoder for correction. Detection requires 1 cycle.
   , DYNAMIC_REFRESH = 0 // Note: 1 - get refresh period from 'refresh_period', 0 - statically defined by parameters
)
(
   input sdram_clk,
   res,
   input [ROW_ADDR_WIDTH+COL_ADDR_WIDTH+BANK_ADDR_WIDTH+CS_ADDR_BITS-1:0] addr,
   input [DATA_WIDTH-1:0] data_in,
   input [(DATA_WIDTH>>3)-1:0] be,
   input wr,
   rd,
   output [DATA_WIDTH-1:0] data_out,
   output ready, // Note: R/W commands while this signal is low will be ignored
// SDRAM interface
   output reg [2**CS_ADDR_BITS-1:0] sdram_cke,
   output [2**CS_ADDR_BITS-1:0] sdram_cs,
   output sdram_cas,
   output sdram_ras,
   output sdram_we,
   output reg [(SDRAM_WIDTH>>3)-1 : 0] sdram_dqm, // a.k.a. BE   todo: they have different width in non-ft mode...
   output reg [BANK_ADDR_WIDTH-1:0] sdram_ba,
   output reg [(ROW_ADDR_WIDTH > COL_ADDR_WIDTH ? ROW_ADDR_WIDTH : COL_ADDR_WIDTH)-1 : 0] sdram_a, // Note: should be at least 13, to support LOAD_MODE_REG
   output output_enable,
   output [SDRAM_WIDTH-1 + (FT_ENA ? DATA_WIDTH/2 : 0) : 0] sdram_dq_out,
   input [SDRAM_WIDTH-1 + (FT_ENA ? DATA_WIDTH/2 : 0) : 0] sdram_dq_in,
//
   output reg recoverable_error,
   unrecoverable_error,
//
   input [31:0] refresh_period,
   input ft_bypass
);
// Note: following parameters can't be redefined in current release
   localparam FT_RS_SYMBOL_WIDTH = 8;
   localparam FT_RS_DATA_SYMBOLS = 8;
   localparam FT_RS_ERROR_FIXED  = 2;

   localparam CS_CNT = 1 << CS_ADDR_BITS;
`ifndef SYNTHESIS
   integer fld;
   initial
   begin
      if(FT_ENA)
      begin
         fld = $fopen("ehl_sdram.sdc","w");
         if(fld == -1)
         begin
            $display("   Error: can't create 'ehl_sdram.sdc' file.");
            $finish;
         end
         $fdisplay(fld, "# Note: %0d MHz clock", CLOCK_FREQUENCY_MHZ);
         $fdisplay(fld, "create_clock -name clk -period %0.4f sdram_clk", 1000.0 / CLOCK_FREQUENCY_MHZ);
         $fdisplay(fld, "set_clock_uncertainty 0.1 clk");
         $fdisplay(fld, "set_input_delay 0.3 -clock clk { res addr* data_in* be* wr rd }");
         $fdisplay(fld, "set_output_delay 0.3 -clock clk { data_out* ready sdram_cke sdram_cs sdram_cas sdram_ras sdram_we sdram_dqm* sdram_ba* sdram_a* recoverable_error unrecoverable_error }");
         $fdisplay(fld, "set_input_delay 0.3 -clock clk { sdram_dq[* }");
         $fdisplay(fld, "set_output_delay 0.3 -clock clk -add_delay { sdram_dq[* }");
         $fdisplay(fld, "# Note: path to error_detected is still single cycle to allow  not to calculate data when no error in stream_in");
         $fdisplay(fld, "set_multicycle_path -hold %0d -from dp_bypassed* -to {dp_decoded_cpt* ram_er_cor_reg}", MC_LENGTH-1);
         $fdisplay(fld, "set_multicycle_path -setup %0d -from dp_bypassed* -to {dp_decoded_cpt* ram_er_cor_reg}", MC_LENGTH);
         $fclose(fld);
         $display("   Info: write SDC file 'ehl_sdram.sdc' for FT configuration.");
      end
   end
`endif

   localparam ADDR_WIDTH = ROW_ADDR_WIDTH + COL_ADDR_WIDTH + BANK_ADDR_WIDTH + CS_ADDR_BITS;
// Note: address is ADDR_WIDTH bits, but for example, if there are up to 256-Mb memory bits in SDRAM
//       32 MB require 25 address bits, 2 of them (24:23) are Bank Address
//       13 of them (22:10) are Row address
//       10 of them (9:0) are Col address
`ifndef SYNTHESIS
   initial
   begin
      if(DATA_WIDTH != 8 && DATA_WIDTH != 16 && DATA_WIDTH != 32 && DATA_WIDTH != 64)
      begin
         $display("   Error: '%m' invalid value %0d for parameter DATA_WIDTH (8, 16, 32, 64).", DATA_WIDTH);
         $finish;
      end
      if(SDRAM_WIDTH != 8 && SDRAM_WIDTH != 16 && SDRAM_WIDTH != 32 && SDRAM_WIDTH != 64)
      begin
         $display("   Error: '%m' invalid value %0d for parameter SDRAM_WIDTH (8, 16, 32, 64).", SDRAM_WIDTH);
         $finish;
      end
      if(FT_ENA)
      begin
         if(SDRAM_WIDTH !== DATA_WIDTH)
         begin
            $display("   Error: '%m' invalid values for parameters SDRAM_WIDTH (%0d), DATA_WIDTH(%0d) (SDRAM_WIDTH == DATA_WIDTH).", SDRAM_WIDTH, DATA_WIDTH);
            $finish;
         end
         if(MODE_REGISTER & 13'h7)
         begin
            $display("   Error: '%m' MODE_REGISTER.BURST_LENGTH (%x) should be equal to 0 (length equal to 1) in FT mode.", MODE_REGISTER);
            $finish;
         end
      end
   end
`endif
   reg [31:0] counter;
   localparam [3:0]
      CMD_IDLE            = 4'b1111, // 1xxx = INHIBIT
      CMD_NOP             = 4'b0111,
      CMD_ACTIVE          = 4'b0011,
      CMD_READ            = 4'b0101,
      CMD_WRITE           = 4'b0100,
      CMD_BURST_TERMINATE = 4'b0110,
      CMD_PRECHARGE       = 4'b0010,
      CMD_REFRESH         = 4'b0001,
      CMD_LOAD_MODE_REG   = 4'b0000;

   localparam INIT_AUTOREFRESH_CNT = 8; // former 2
   localparam AUTOPRECHARGE_ENABLE_BIT = 10; // sdram_a's bit that enables auto-precharge

// Note: timing parameters section...
   wire [31:0] tRP                = PRECHARGE_COMMAND_PERIOD_NS * CLOCK_FREQUENCY_MHZ / 1000 + 1 ;
   wire [31:0] tRFC               = AUTO_REFRESH_PERIOD_NS * CLOCK_FREQUENCY_MHZ / 1000 + 1 ;
   wire [31:0] tMRD               = LOAD_MODE_REGISTER_TO_ACTIVE_OR_REFRESH_CYCLES; // p.38
   wire [31:0] INIT_CYCLES        = 1/*GAP*/ + 1/*NOP*/ + 1/*PRECHARGE*/ + tRP + /*INIT_AUTOREFRESH_CNT**/1 /*AUTO-REFRESH*/ + INIT_AUTOREFRESH_CNT*tRFC /*AUTO_REFRESH*/ + 1/*LOAD_MODE_REG*/ + tMRD;
   wire [31:0] tRCD               = ACTIVE_TO_READ_OR_WRITE_DELAY_NS * CLOCK_FREQUENCY_MHZ / 1000 + 1;
   wire [31:0] tWR                = WRITE_RECOVERY_TIME_NS * CLOCK_FREQUENCY_MHZ / 1000 + 1 ;
   localparam BURST_LENGTH       = DATA_WIDTH / SDRAM_WIDTH;
   wire [31:0] WR_with_ACT_CYCLES = tRCD + 1-1/*ACTIVATE*/ + tWR + BURST_LENGTH + tRP;
   wire [31:0] CAS_LATENCY        = (MODE_REGISTER & 32'h00000070) >> 4;
   wire [31:0] RD_with_ACT_CYCLES = tRCD + 1/*ACTIVATE*/ + CAS_LATENCY + BURST_LENGTH + tRP;
   localparam tREFRESH           = AUTO_REFRESH_CYCLE_NS * CLOCK_FREQUENCY_MHZ / 1000 - 1; // 64 ms / 8192 rows = 7.81us
   wire [31:0] REFRESH_CYCLES     = 1/*PRECHARGE*/ + tRP + 1/*REFRESH*/ + tRFC;

   reg [CS_ADDR_BITS - 1 : 0] chip_select; // binary form to specify active CS/CKE

   reg [MC_LENGTH-1:0] mc_reg;
   reg ready_cpt;

   reg [2:0] queue;              // Note: keeps incoming requests for { RD, WR, REFRESH }
   reg [2:0] exec;               // Note: indicates which command is executed now { RD, WR, REFRESH }
   reg [2:0] exec_delay;         // used to specify begin of procedure
   reg initialization_completed; // set when initial sequence completed
   reg [31:0] refresh_counter;
   wire issue_refresh = refresh_counter == 1;

   wire error_corrected, error_detected;
   reg ram_er_det, ram_er_cor;
   localparam ST_IDLE    = 3'b000;
   localparam ST_REFRESH = 3'b001;
   localparam ST_WRITE   = 3'b010;
   localparam ST_READ    = 3'b100;

   always@(posedge sdram_clk or negedge res)
   if(!res)
      queue <= ST_IDLE;
   else
   begin
      if(ready_cpt & (rd | wr & ~&be)) queue[2] <= 1'b1; // Note: read has priority over write to allow RMW when byte enabled.
      else if(counter == 1 & exec[2]) queue[2] <= 1'b0;
      if(ready_cpt & wr) queue[1] <= 1'b1;
      else if(counter == 1 & exec[1]) queue[1] <= 1'b0;
      else if(~queue[1] & ram_er_det) queue[1]  <= 1; // Note: simple read with error corrected and detected
      if(issue_refresh) queue[0] <= 1'b1;
      else if(counter == 1 & exec[0]) queue[0] <= 1'b0;
   end

   always@(posedge sdram_clk or negedge res)
   if(!res)
      exec <= ST_IDLE;
   else
   begin
      if(exec == 0) // activate new command
      begin
         if(queue[0]) exec <= ST_REFRESH;
         // Note: READ has higher priority to allow RMW when WR+BE
         else if(queue[2]) exec <= ST_READ;
         else if(queue[1]) exec <= ST_WRITE;
      end
      else // process current command and activate new one
      begin
         if(counter == 1) // end of current command
         begin
            if(exec == ST_REFRESH)
               exec <= queue[2] ? ST_READ : {queue[2:1], 1'b0}; // Note: WR & RD should be 0
            else if(exec == ST_WRITE)
               exec <= queue[0] ? ST_REFRESH : ST_IDLE; // Note: no incoming RD should be
            else if(exec == ST_READ)
               exec <= queue[0] ? ST_REFRESH : {1'b0,queue[1],1'b0};
         end
      end
   end

   always@(posedge sdram_clk or negedge res)
   if(!res)
      exec_delay <= ST_IDLE;
   else
      exec_delay <= exec;

   always@(posedge sdram_clk or negedge res)
   if(!res)
      ready_cpt <= 1'b0;
   else if(!initialization_completed)
      ready_cpt <= 1'b0;
else if(ram_er_det) ready_cpt <= 1'b0;
   else if(queue[2:1] == 0 & initialization_completed & (!wr|!ready_cpt) & (!rd|!ready_cpt))
      ready_cpt <= 1'b1;
   else
      ready_cpt <= 1'b0;

   assign ready = ready_cpt  & !wr         & !ram_er_det;

// Note: some improvements introduced in this counter:
//  1) no need to reload counter inside initialization period
//  2) no need to count after reset - as reset duration can be long enough to leak dram content, after reset initialization procedure should be taken (assume that memory content is unknown)
   always@(posedge sdram_clk or negedge res)
   if(!res)
      refresh_counter <= 0/*tREFRESH*/; // Note: (2)
   else if(|refresh_counter)
      refresh_counter <= refresh_counter - 1;
   else if(initialization_completed) // Note: (1)
      refresh_counter <= DYNAMIC_REFRESH ? refresh_period : tREFRESH;

   reg [3:0] state;
   assign output_enable = state == CMD_WRITE;

// Note: control logic for precharged/activated banks  ... and all chips!!!
   reg [ADDR_WIDTH-1:0] cmd_addr;
`include "ehl_sdram_pre_act.inc"
   reg [(DATA_WIDTH>>3)-1:0] cmd_be;
   wire [31:0] \100US_DELAY = 2*100 * CLOCK_FREQUENCY_MHZ + INIT_CYCLES;

//       if(rd)
//            if(is_any_row_active & not readable row) precharge activated row; active required row
//            read data (with auto-precharge if queue refresh exist)
//       else if(wr)
//            if(is_any_row_active & not writeable row) precharge activated row; active required row
//            write data(RMW decision at 'exec' FF) (with auto-precharge if queue refresh exist)
//       else if(refresh)
//            if(is_any_row_active) precharge activated row
//            refresh all rows

   reg trx_error_detected;
   reg read_data_now_delay;

// todo: implement clock gating !!!!
   always@(posedge sdram_clk or negedge res)
   if(!res)
      sdram_cke <= {CS_CNT{1'b1}};
//   else if(|queue[2:1] | exec[2:1])
//      sdram_cke <= 1<<chip_select;//{CS_CNT{1'b1}};
//   else if(queue[0] | exec[0] | !initialization_completed)
//      sdram_cke <= {CS_CNT{1'b1}};
//   else
//      sdram_cke <= {CS_CNT{1'b0}};

   integer int_a;
   always@(posedge sdram_clk or negedge res)
   if(!res)
   begin
      counter <= \100US_DELAY + 30.3 ;
      initialization_completed <= 1'b0;
      sdram_dqm <= {(SDRAM_WIDTH>>3){1'b1}};
      sdram_ba <= #1 2'b00;
      sdram_a <= 'd0;
      state <= CMD_IDLE;
   end
// Note: 100 us initialization: NOP + after 100 us initialization commands: PRECHARGE + (2x+6x) REFRESH + LOAD MODE REG
   else if(|counter && !initialization_completed)
   begin
      counter <= counter - 1;
      // Note: after 100 us initialization
      if(counter==INIT_CYCLES)
         state <= CMD_NOP;
      else if(counter == INIT_CYCLES - 1)
      begin
         state <= CMD_PRECHARGE;
         sdram_a[AUTOPRECHARGE_ENABLE_BIT] <= 1'b1; // precharge ALL banks
      end
      else if(counter == INIT_CYCLES - 1 - 1)
         state <= CMD_IDLE;
      else if(counter == INIT_CYCLES - 1 - 1 - tRP)
         state <= CMD_REFRESH;
      else if(counter == INIT_CYCLES - 1 - 1 - tRP - 1)
         state <= CMD_IDLE;
// Note: this part of code should be synchronized with 'INIT_AUTOREFRESH_CNT', for 2 only 1* and 1*-1*   >>>>>>
      else if(counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 1*tRFC ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 2*tRFC ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 3*tRFC ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 4*tRFC ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 5*tRFC ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 6*tRFC ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 7*tRFC)
         state <= CMD_REFRESH;
      else if(counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 1*tRFC - 1 ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 2*tRFC - 1 ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 3*tRFC - 1 ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 4*tRFC - 1 ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 5*tRFC - 1 ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 6*tRFC - 1 ||
              counter == INIT_CYCLES - 1 - 1 - tRP - 1 - 7*tRFC - 1)
         state <= CMD_IDLE;
// <<<<<<<<<<<<<<
      else if(counter == INIT_CYCLES - 1 - 1 - tRP - 1 - INIT_AUTOREFRESH_CNT*tRFC - 1)
      begin
         state <= CMD_LOAD_MODE_REG;
         sdram_a[11:0] <= MODE_REGISTER[11:0];
         sdram_a[12] <= 1'b0;
      end
      else if((counter < (INIT_CYCLES - 1 - 1 - tRP - 1 - INIT_AUTOREFRESH_CNT*tRFC - (INIT_AUTOREFRESH_CNT-1)*1)) && (counter > (INIT_CYCLES - 1 - 1 - tRP - 1 - INIT_AUTOREFRESH_CNT*tRFC - 1 - tMRD)))
         state <= CMD_NOP;
      else
         state <= CMD_NOP;
   end
// work mode
   else
   begin
      if(|counter) counter <= counter - 1;
// WRITE
      if(exec[1] & ~exec_delay[1])
      begin
         if(row_miss)                begin state <= CMD_PRECHARGE; sdram_ba <= #1 active_bank; sdram_a <= active_row; end
         else if(!is_any_row_active) begin state <= CMD_ACTIVE;    sdram_ba <= #1 addr_bank;   sdram_a <= addr_row; end
         else                        begin state <= trx_error_detected || (read_data_now_delay && error_detected /*WR+BE*/) ? CMD_NOP : CMD_WRITE;     sdram_ba <= #1 addr_bank;   sdram_a <= addr_col; end// todo: precharge bit skip!!!
         counter <= WR_with_ACT_CYCLES - 1 -// BASE + PRECHARGE(opt) + ACTIVE(opt) + FT(opt)
            (row_miss ? 0 : tRP) - // PRECHARGE
            ((row_miss || !is_any_row_active) ? 0 : tRCD) + // ACTIVE
            (mc_reg[MC_LENGTH-1-1]/*RD*/ || (read_data_now_delay && error_detected /*WR+BE*/) ? MC_LENGTH-1 : 0);
         sdram_dqm <= ~cmd_be; // {(SDRAM_WIDTH>>3){1'b0}}; // todo: skip masked by BE bytes...
      end
      else if(exec[1])
      begin
         if(counter == WR_with_ACT_CYCLES - 1)
            state <= CMD_NOP;
         else if((counter == WR_with_ACT_CYCLES - tRP) & (!is_any_row_active))
         begin
            state <= CMD_ACTIVE;
            sdram_ba <= #1 addr_bank;
            sdram_a <= addr_row;
         end
         else if(counter == WR_with_ACT_CYCLES - tRP - 1)
            state <= CMD_NOP;
         else if(counter == WR_with_ACT_CYCLES - tRP - tRCD)
         begin
            state <= CMD_WRITE;
            sdram_a[AUTOPRECHARGE_ENABLE_BIT] <= queue[0] ? 1'b1 : 1'b0;
            for(int_a = 0; int_a <= COL_ADDR_WIDTH; int_a = int_a + 1) // Note: skip AUTOPRECHARGE_ENABLE_BIT-th sdram_a bit
            begin
               if(int_a > AUTOPRECHARGE_ENABLE_BIT)
                  sdram_a[int_a] <= cmd_addr[int_a-1];
               else if(int_a < AUTOPRECHARGE_ENABLE_BIT)
                  sdram_a[int_a] <= cmd_addr[int_a];
            end
         end
         else if(counter == WR_with_ACT_CYCLES - tRP - tRCD - BURST_LENGTH)
            state <= CMD_NOP;
         if((counter >= WR_with_ACT_CYCLES - tRP - tRCD - BURST_LENGTH) && (counter < WR_with_ACT_CYCLES - tRP - tRCD - 1))
            sdram_a <= sdram_a + 1;
         if(counter == 1)
         begin
            sdram_dqm<={(SDRAM_WIDTH>>3){1'b1}};
            state<=CMD_IDLE;
         end // Note: release CKE to reduce power
      end
// READ
      else if(exec[2] & ~exec_delay[2])
      begin
         if(row_miss)                begin state <= CMD_PRECHARGE; sdram_ba <= #1 active_bank; sdram_a <= active_row; end
         else if(!is_any_row_active) begin state <= CMD_ACTIVE;    sdram_ba <= #1 addr_bank;   sdram_a <= cmd_addr[COL_ADDR_WIDTH +:ROW_ADDR_WIDTH]; end
         else                        begin state <= CMD_READ;      sdram_ba <= #1 addr_bank;   sdram_a <= cmd_addr[COL_ADDR_WIDTH-1 :0]; end
         counter <= RD_with_ACT_CYCLES -1 -// BASE + PRECHARGE(opt) + ACTIVE(opt) + FT(opt)
            (row_miss ? 0 : tRP) - // PRECHARGE
            ((row_miss || !is_any_row_active) ? 0 : tRCD); // ACTIVE
         sdram_dqm <= {(SDRAM_WIDTH>>3){1'b0}};
      end
      else if(exec[2]) // Note: no tRP if no AUTO-PRECHARGE will be at the end, but command latency compemsate it...
      begin
         if(counter == RD_with_ACT_CYCLES - 1)
            state <= CMD_NOP;
         else if(counter == RD_with_ACT_CYCLES - tRP)
         begin
            state <= CMD_ACTIVE;
            sdram_ba <= #1 addr_bank;
            sdram_a <= cmd_addr[COL_ADDR_WIDTH +:ROW_ADDR_WIDTH];
         end
         else if(counter == RD_with_ACT_CYCLES - tRP - 1)
            state <= CMD_NOP;
         else if(counter == RD_with_ACT_CYCLES - tRP - tRCD)
         begin
            state <= CMD_READ;
            sdram_a[AUTOPRECHARGE_ENABLE_BIT] <= queue[0] ? 1'b1 : 1'b0;
            for(int_a = 0; int_a <= COL_ADDR_WIDTH; int_a = int_a + 1) // Note: skip AUTOPRECHARGE_ENABLE_BIT-th sdram_a bit
            begin
               if(int_a > AUTOPRECHARGE_ENABLE_BIT)
                  sdram_a[int_a] <= cmd_addr[int_a-1];
               else if(int_a < AUTOPRECHARGE_ENABLE_BIT)
                  sdram_a[int_a] <= cmd_addr[int_a];
            end
         end
         else if(counter > RD_with_ACT_CYCLES - tRP - tRCD)
            state <= CMD_NOP;
         else if(counter == RD_with_ACT_CYCLES - tRP - tRCD - CAS_LATENCY + 1)//- BURST_LENGTH)
            state <= CMD_NOP;
         if(counter < RD_with_ACT_CYCLES - tRP - tRCD-1 && counter > CAS_LATENCY)
            sdram_a <= sdram_a + 1;

         if(counter == 1)
         begin
            state <= CMD_IDLE;
            sdram_dqm<={SDRAM_WIDTH>>3{1'b1}};
         end
      end
// REFRESH
     else if(exec[0])
     begin // Note: ALL connected CHIPS (as defined by CS) are refreshed
         if(|counter) counter <= counter - 1;
         else counter <= REFRESH_CYCLES - (is_any_row_active ? 0 : tRP); // Note: if no rows open - > no PRECHARGE

         if(counter == REFRESH_CYCLES)
         begin
            state <= CMD_PRECHARGE;
            sdram_a[AUTOPRECHARGE_ENABLE_BIT] <= 1'b1; // auto-precharge ALL Banks
         end
         else if(counter == REFRESH_CYCLES - 1)
            state <= CMD_NOP;
         else if(counter == REFRESH_CYCLES - 1 - tRP)
            state <= CMD_REFRESH;
         else if(counter == REFRESH_CYCLES - 1 - tRP - 1)
            state <= CMD_NOP;
         if(counter == 1)
            state <= CMD_IDLE;

      end
      initialization_completed <= 1'b1;
   end

//
// DataPath structure (according to sdram.docx):
   wire [SDRAM_WIDTH - 1 + (FT_ENA ? DATA_WIDTH/2 : 0) : 0] dp_sd_in;
   reg [SDRAM_WIDTH - 1 + (FT_ENA ? DATA_WIDTH/2 : 0) : 0] dp_bypassed, dp_nonmcp_bypassed;
   wire [SDRAM_WIDTH - 1 : 0] dp_decoded;
   reg [SDRAM_WIDTH - 1 : 0] dp_decoded_cpt;
   wire dp_error_detected_and_corrected;
   wire [DATA_WIDTH - 1 : 0] dp_rdata; // Note: DATA_WIDTH === SDRAM_WIDTH (FT mode)
   wire [DATA_WIDTH - 1 : 0] dp_wdata;
   wire [DATA_WIDTH - 1 : 0] dp_to_enc;
   wire [(DATA_WIDTH>>3) - 1 : 0] dp_be;
   wire [SDRAM_WIDTH - 1 + (FT_ENA ? DATA_WIDTH/2 : 0) : 0] dp_sd_out;

   assign dp_sd_in = sdram_dq_in;
   always@(posedge sdram_clk)
   if(mc_reg[1])
      dp_decoded_cpt <= dp_decoded;

   wire read_data_now = exec[2] && counter == 1;
`define __remove_reset_from_dp_bypass
`ifdef __remove_reset_from_dp_bypass
   always@(posedge sdram_clk) // Note: do not clear this large register -> clear flag, which uses data from this register
   if(read_data_now)
      dp_bypassed <= ft_bypass ? 0 : dp_sd_in;
`else
   always@(posedge sdram_clk or negedge res) // Note: do not clear this large register -> clear flag, which uses data from this register
   if(!res) dp_bypassed <= 0; // Note: non-error value to remove masking from core inputs
   else if(read_data_now)
      dp_bypassed <= ft_bypass ? 0 : dp_sd_in;
`endif
// Note: this register is for non Multicycle Path usage (same as dp_bypassed)
   always@(posedge sdram_clk or negedge res)
   if(!res) dp_nonmcp_bypassed <= 0;
   else if(read_data_now)
      dp_nonmcp_bypassed <= dp_sd_in;

   assign dp_error_detected_and_corrected = error_detected;
   assign dp_rdata = dp_error_detected_and_corrected ? dp_decoded_cpt : dp_nonmcp_bypassed;
   assign data_out = dp_rdata;
   assign dp_be = cmd_be;
   assign dp_wdata = data_in;

   ehl_mux
   #(
      .DATA_WIDTH (FT_RS_SYMBOL_WIDTH),
      .SEL_WIDTH (DATA_WIDTH>>3)
   ) be_inst
   (
      .data_in_0 ( dp_rdata ),
      .data_in_1 ( dp_wdata ),
      .sel       ( dp_be ),
      .data_out  ( dp_to_enc )
   );

   always@(posedge sdram_clk)
   if((wr || rd) & ready_cpt) // defend from spurious wr/rd
   begin
      cmd_addr <= addr;
      cmd_be <= rd ? 0 : be;
   end

   always@(posedge sdram_clk)
   if(wr | rd)
      chip_select <= CS_ADDR_BITS ? addr[ROW_ADDR_WIDTH+COL_ADDR_WIDTH+BANK_ADDR_WIDTH-1+CS_ADDR_BITS -: (CS_ADDR_BITS ? CS_ADDR_BITS : 1)] : 1'b0;

   assign {sdram_ras, sdram_cas, sdram_we} = state[2:0];
   // Refresh mode selects all of the chips
   // wr/rd mode select single chip
   genvar gen_cs;
   for(gen_cs=0; gen_cs<2**CS_ADDR_BITS; gen_cs = gen_cs+1)
      assign sdram_cs[gen_cs] = (exec[0] || !initialization_completed) ? state[3] : chip_select == gen_cs ? state[3] : 1'b1;

   assign #2 sdram_dq_out = ft_bypass ? dp_to_enc : dp_sd_out;

// Note: check if sequential RS decoder detect errors
   always@(posedge sdram_clk) read_data_now_delay <= read_data_now;

   always@(posedge sdram_clk or negedge res)
   if(!res)
      trx_error_detected<=1'b0;
   else if(read_data_now_delay)
      trx_error_detected<=error_detected;
   else if(ready)
      trx_error_detected<=0;

   always@(posedge sdram_clk or negedge res)
   if(!res)
      ram_er_det<=1'b0;
   else if(read_data_now_delay)
      ram_er_det<=error_detected;
   else
      ram_er_det<=0;
   always@(posedge sdram_clk or negedge res)
   if(!res)
      ram_er_cor<=1'b0;
   else if(mc_reg[1])
      ram_er_cor<=error_corrected;
   else
      ram_er_cor<=0;

   if(FT_ENA == 1)
   begin : fault_tolerance
      ehl_rs_dec
`ifndef SYNTHESIS
      #(
         .SYMBOL_WIDTH (FT_RS_SYMBOL_WIDTH),
         .DATA_SYMBOLS (DATA_WIDTH / FT_RS_SYMBOL_WIDTH),
         .ERROR_FIXED  (FT_RS_ERROR_FIXED)
      )
`endif
      rs_dec_inst
      (
         .stream_in       ( dp_bypassed ),
         .stream_out      ( dp_decoded ),
         .error_detected  ( error_detected ),
         .error_corrected ( error_corrected )
      );
// todo: add register after encoder...
      ehl_rs_enc rs_enc_inst
      (
         .stream_in  ( ft_bypass ? 0 : dp_to_enc ),
         .stream_out ( dp_sd_out )
      );
      defparam rs_enc_inst.SYMBOL_WIDTH = FT_RS_SYMBOL_WIDTH;
      defparam rs_enc_inst.DATA_SYMBOLS = DATA_WIDTH / FT_RS_SYMBOL_WIDTH;
      defparam rs_enc_inst.ERROR_FIXED  = FT_RS_ERROR_FIXED;

      always@(posedge sdram_clk or negedge res)
      if(!res)
         mc_reg <= 0;
      else if(ram_er_det)
         mc_reg <= 1 << (MC_LENGTH-1);
      else if(|mc_reg)
         mc_reg <= mc_reg >> 1;
// Note: only 8-bit symbol supported
// Note: only 2 errors correction supported
      always@(posedge sdram_clk or negedge res)
      if(!res)
      begin
         recoverable_error <= 1'b0;
         unrecoverable_error <= 1'b0;
      end
      else if(mc_reg[0])
      begin
         if(ram_er_cor) recoverable_error <= 1'b1;
         else unrecoverable_error <= 1'b1;
      end
      else
      begin
         recoverable_error <= 1'b0;
         unrecoverable_error <= 1'b0;
      end
   end

   else
   begin
      assign error_corrected = 0;
      assign error_detected = 0;
      always@(posedge sdram_clk)
      begin
         recoverable_error <= 1'b0;
         unrecoverable_error <= 1'b0;
         mc_reg <= 0;
      end
   end

endmodule
