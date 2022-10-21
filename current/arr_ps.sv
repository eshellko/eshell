module arr_ps(input [2:0] ptr, output [3:0] q);

   wire pack_arr [7:0]; // Note: packed array
   assign q = pack_arr[ptr+:4]; // Error: part-select for array is not valid

endmodule
/*
      if(FPGA_TECH == 2)
      begin : xlnx_ddr4
         wire [8*SDRAM_WIDTH-1:0] rdData;
         wire rdDataEn;
         wire wrDataEn;
         reg [8*SDRAM_WIDTH-1:0] wrData;
         reg [SDRAM_WIDTH-1:0] wrDataMask;
         // Note: to provide data before it is required by the PHY there is necessary to delay all control signals to PHY.
         //       except write data itself - data written into FIFO 2 cycles to create single write burst.
         //       also, need to align data with burst boundary made inside FIFO
         wire [1:0] r_dfi_cke, r_dfi_cs, r_dfi_ras_n, r_dfi_cas_n, r_dfi_we_n, r_dfi_odt, r_dfi_act_n;
         wire [3:0] r_dfi_bg;
         wire [5:0] r_dfi_bank;
         wire [27:0] r_dfi_address;
         ehl_cdc
         #(
            .SYNC_STAGE ( 1                    ),
            .WIDTH      ( 2+2+6+2+2+2+28+2+2+4 )
         ) ac_dly_inst
         (
            .clk     ( mctrl_clk ),
            .reset_n ( presetn   ),
            .din     ( {dfi_cke, dfi_cs_n, dfi_ras_n, dfi_cas_n, dfi_we_n, dfi_odt, dfi_act_n, dfi_bg, dfi_bank, dfi_address[31:18], dfi_address[13:0]} ),
            .dout    ( {r_dfi_cke, r_dfi_cs, r_dfi_ras_n, r_dfi_cas_n, r_dfi_we_n, r_dfi_odt, r_dfi_act_n, r_dfi_bg, r_dfi_bank, r_dfi_address} )
         );
         // Note: parameters to module are not provided as core should be regenerated in case of parameter change
         assign sdram_we_n = sdram_a[14];
         assign sdram_a[15] = 1'b0;
         phy_ddr4 phy_inst
         (
            .sys_rst                 ( !presetn          ),
            .c0_sys_clk_p            ( ref_clk           ),
            .c0_sys_clk_n            ( ref_clk_n         ),
            .c0_ddr4_ui_clk_sync_rst ( ui_rst            ),
            .c0_ddr4_act_n           ( sdram_act_n       ),
            .c0_ddr4_adr             ( {sdram_ras_n, sdram_cas_n, sdram_a[14:0]}),
            .c0_ddr4_ba              ( sdram_ba[1:0]     ),
            .c0_ddr4_bg              ( sdram_bg[0]       ),
            .c0_ddr4_cke             ( sdram_cke         ),
            .c0_ddr4_odt             ( sdram_odt         ),
            .c0_ddr4_cs_n            ( sdram_cs_n        ),
            .c0_ddr4_ck_t            ( sdram_ck          ),
            .c0_ddr4_ck_c            ( sdram_ck_n        ),
            .c0_ddr4_reset_n         ( sdram_reset_n     ),
            .c0_ddr4_dm_dbi_n        ( sdram_dm          ),
            .c0_ddr4_dq              ( sdram_dq          ),
            .c0_ddr4_dqs_c           ( sdram_dqs_n       ),
            .c0_ddr4_dqs_t           ( sdram_dqs         ),
            .c0_init_calib_complete  ( dfi_init_complete ),
            .addn_ui_clkout1         ( mctrl_clk         ),
            .addn_ui_clkout2         ( slow_clk          ),
            .dBufAdr                 ( 5'h0              ) , // should be tied low
            .wrData,
            .wrDataMask,
            .rdData,
            .rdDataEn,
            .wrDataEn,
            .mcCasSlot               ( 2'h0              ),
            .mcCasSlot2              ( 1'h0              ),
            .mcRdCAS                 ( (!r_dfi_cs[0] & r_dfi_ras_n[0] & !r_dfi_cas_n[0] & r_dfi_we_n[0]) |
                                       (!r_dfi_cs[1] & r_dfi_ras_n[1] & !r_dfi_cas_n[1] & r_dfi_we_n[1])),
            .mcWrCAS                 ( (!r_dfi_cs[0] & r_dfi_ras_n[0] & !r_dfi_cas_n[0] & !r_dfi_we_n[0]) |
                                       (!r_dfi_cs[1] & r_dfi_ras_n[1] & !r_dfi_cas_n[1] & !r_dfi_we_n[1])),
            .winInjTxn               ( 1'b0              ),
            .winRmw                  ( 1'b0              ),
            .gt_data_ready           ( 1'b0              ),
            .winBuf                  ( 5'h0              ),
            .winRank                 ( 2'd0              ),
            .mc_CKE                  ( {r_dfi_cke[0], r_dfi_cke[0], // default
                                        r_dfi_cke[0], r_dfi_cke[0], // default
                                        r_dfi_cke[1], r_dfi_cke[1],
                                        r_dfi_cke[0], r_dfi_cke[0]}),
            .mc_CS_n                 ( {2'h3, 2'h3,
                                        r_dfi_cs[1], r_dfi_cs[1],
                                        r_dfi_cs[0], r_dfi_cs[0]}),
            .mc_BA                   (   {2'h0, 2'h0, r_dfi_bank[4], r_dfi_bank[4], r_dfi_bank[1], r_dfi_bank[1],
                                          2'h0, 2'h0, r_dfi_bank[3], r_dfi_bank[3], r_dfi_bank[0], r_dfi_bank[0]} ),
            .mc_ADR                  (   {2'h3, 2'h3, r_dfi_ras_n[1], r_dfi_ras_n[1], r_dfi_ras_n[0], r_dfi_ras_n[0],
                                          2'h3, 2'h3, r_dfi_cas_n[1], r_dfi_cas_n[1], r_dfi_cas_n[0], r_dfi_cas_n[0],
                                          2'h3, 2'h3, r_dfi_we_n[1], r_dfi_we_n[1], r_dfi_we_n[0], r_dfi_we_n[0],
                                          2'h0, 2'h0, r_dfi_address[27], r_dfi_address[27], r_dfi_address[13], r_dfi_address[13],
                                          2'h0, 2'h0, r_dfi_address[26], r_dfi_address[26], r_dfi_address[12], r_dfi_address[12],
                                          2'h0, 2'h0, r_dfi_address[25], r_dfi_address[25], r_dfi_address[11], r_dfi_address[11],
                                          2'h0, 2'h0, r_dfi_address[24], r_dfi_address[24], r_dfi_address[10], r_dfi_address[10],
                                          2'h0, 2'h0, r_dfi_address[23], r_dfi_address[23], r_dfi_address[9], r_dfi_address[9],
                                          2'h0, 2'h0, r_dfi_address[22], r_dfi_address[22], r_dfi_address[8], r_dfi_address[8],
                                          2'h0, 2'h0, r_dfi_address[21], r_dfi_address[21], r_dfi_address[7], r_dfi_address[7],
                                          2'h0, 2'h0, r_dfi_address[20], r_dfi_address[20], r_dfi_address[6], r_dfi_address[6],
                                          2'h0, 2'h0, r_dfi_address[19], r_dfi_address[19], r_dfi_address[5], r_dfi_address[5],
                                          2'h0, 2'h0, r_dfi_address[18], r_dfi_address[18], r_dfi_address[4], r_dfi_address[4],
                                          2'h0, 2'h0, r_dfi_address[17], r_dfi_address[17], r_dfi_address[3], r_dfi_address[3],
                                          2'h0, 2'h0, r_dfi_address[16], r_dfi_address[16], r_dfi_address[2], r_dfi_address[2],
                                          2'h0, 2'h0, r_dfi_address[15], r_dfi_address[15], r_dfi_address[1], r_dfi_address[1],
                                          2'h0, 2'h0, r_dfi_address[14], r_dfi_address[14], r_dfi_address[0], r_dfi_address[0]}),
            .mc_ODT                  (   {r_dfi_odt[1],r_dfi_odt[1],r_dfi_odt[1],r_dfi_odt[1], // default... not really correct one
                                          r_dfi_odt[0],r_dfi_odt[0],r_dfi_odt[0],r_dfi_odt[0]}),
            .mc_ACT_n                ( {2'h3, 2'h3, r_dfi_act_n[1], r_dfi_act_n[1], r_dfi_act_n[0], r_dfi_act_n[0]}),
            .mc_BG                   ( {2'h0, 2'h0, r_dfi_bg[2], r_dfi_bg[2], r_dfi_bg[0], r_dfi_bg[0]} )
         );

         wire rd_empty;
         reg [8*SDRAM_WIDTH-1:0] rdData_write;
         integer r, p;
         always@*
         begin
            rdData_write = 0;
            for(p=0; p<8/8; p=p+1) // 8 phases
               for(r=0; r<SDRAM_WIDTH/8; r=r+1)
                  rdData_write [(r+p*SDRAM_WIDTH/8)*8 +:8] = rdData[(r*8 + p)*8 +: 8];
         end

         ehl_fifo
         #(
            //.SYNC_STAGE(0),
            .WIDTH_DIN  ( 8*SDRAM_WIDTH ),
            .WIDTH_DOUT ( 4*SDRAM_WIDTH )
         ) rd_fifo_inst
         (
            .wclk      ( mctrl_clk  ),
            .rclk      ( mctrl_clk  ),
            .wr        ( rdDataEn   ),
            .rd        ( !rd_empty  ),
            .w_reset_n ( presetn    ),
            .r_reset_n ( presetn    ),
            .wdat      ( rdData_write ),
            .rdat      ( dfi_rddata  ),
            .r_empty   ( rd_empty    ),
            .clr_of    ( 1'b0        ),
            .clr_uf    ( 1'b0        )
         );
         assign dfi_rddata_valid = {SDRAM_WIDTH/4{!rd_empty}};
         wire wr_empty;
         wire [8*SDRAM_WIDTH+8*SDRAM_WIDTH/8-1:0] wdata;
         integer w;
         always@(posedge mctrl_clk)
         if(wrDataEn & !wr_empty)
         begin
            for(w=0; w<SDRAM_WIDTH/8; w=w+1)
            begin
               wrData []w*64+:64] <= {
                  wdata[SDRAM_WIDTH/2+(7*SDRAM_WIDTH/8+w)*8 +: 8],
                  wdata[SDRAM_WIDTH/2+(6*SDRAM_WIDTH/8+w)*8 +: 8],
                  wdata[SDRAM_WIDTH/2+(5*SDRAM_WIDTH/8+w)*8 +: 8],
                  wdata[SDRAM_WIDTH/2+(4*SDRAM_WIDTH/8+w)*8 +: 8],
                  wdata[              (3*SDRAM_WIDTH/8+w)*8 +: 8],
                  wdata[              (2*SDRAM_WIDTH/8+w)*8 +: 8],
                  wdata[              (1*SDRAM_WIDTH/8+w)*8 +: 8],
                  wdata[              (                w)*8 +: 8]
                  };
               wrDataMask [w*8 +:8] <= ~{
                     wdata[SDRAM_WIDTH*8 + SDRAM_WIDTH/2 + w + 3*SDRAM_WIDTH/8],
                     wdata[SDRAM_WIDTH*8 + SDRAM_WIDTH/2 + w + 2*SDRAM_WIDTH/8],
                     wdata[SDRAM_WIDTH*8 + SDRAM_WIDTH/2 + w + 1*SDRAM_WIDTH/8],
                     wdata[SDRAM_WIDTH*8 + SDRAM_WIDTH/2 + w                  ],
                     wdata[SDRAM_WIDTH*4 + w + 3*SDRAM_WIDTH/8],
                     wdata[SDRAM_WIDTH*4 + w + 2*SDRAM_WIDTH/8],
                     wdata[SDRAM_WIDTH*4 + w + 1*SDRAM_WIDTH/8],
                     wdata[SDRAM_WIDTH*4 + w]
                  };
            end
         end
         ehl_fifo
         #(
            .WIDTH_DIN  ( 4*SDRAM_WIDTH+4*SDRAM_WIDTH/8 ),
            .WIDTH_DOUT ( 8*SDRAM_WIDTH+8*SDRAM_WIDTH/8 ),
            .DEPTH      ( 32     ),
            .SYNC_STAGE ( 0      )
         )
         wr_fifo_inst
         (
            .wclk      ( mctrl_clk                     ),
            .rclk      ( mctrl_clk                     ),
            .wr        ( dfi_wrdata_en[0]              ),
            .rd        ( wrDataEn & !wr_empty          ),
            .w_reset_n ( presetn                       ),
            .r_reset_n ( presetn                       ),
            .wdat      ( {dfi_wrdata_mask, dfi_wrdata} ),
            .rdat      ( wdata                         ),
            .r_empty   ( wr_empty                      ),
            .clr_of    ( 1'b0                          ),
            .clr_uf    ( 1'b0                          )
         );
         assign s0_phy_phy_cal_success = dfi_init_complete;
         assign s0_phy_phy_cal_fail    = 1'b0; // TODO: make it too...
      end
*/
