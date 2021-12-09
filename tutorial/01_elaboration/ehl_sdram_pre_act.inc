   wire [COL_ADDR_WIDTH-1:0]  addr_col  = cmd_addr [COL_ADDR_WIDTH-1 :0];
   wire [ROW_ADDR_WIDTH-1:0]  addr_row  = cmd_addr [COL_ADDR_WIDTH +:ROW_ADDR_WIDTH];
   wire [BANK_ADDR_WIDTH-1:0] addr_bank = cmd_addr [ROW_ADDR_WIDTH + COL_ADDR_WIDTH +:BANK_ADDR_WIDTH];
   wire [2**CS_ADDR_BITS-1:0] addr_cs   = CS_ADDR_BITS ? cmd_addr [ROW_ADDR_WIDTH+COL_ADDR_WIDTH+BANK_ADDR_WIDTH+CS_ADDR_BITS-1 -: (CS_ADDR_BITS ? CS_ADDR_BITS : 1)] : 1'b0;
   reg is_any_row_active;
// ACTIVE command should select ROW / BANK / CHIP to be accessed
   reg [ROW_ADDR_WIDTH+COL_ADDR_WIDTH+BANK_ADDR_WIDTH+2**CS_ADDR_BITS-1:0] active_addr;
   wire [ROW_ADDR_WIDTH-1:0]  active_row  = active_addr [COL_ADDR_WIDTH +:ROW_ADDR_WIDTH];
   wire [BANK_ADDR_WIDTH-1:0] active_bank = active_addr [ROW_ADDR_WIDTH + COL_ADDR_WIDTH +:BANK_ADDR_WIDTH];
   wire [2**CS_ADDR_BITS-1:0] active_cs   = CS_ADDR_BITS ? active_addr [ROW_ADDR_WIDTH+COL_ADDR_WIDTH+BANK_ADDR_WIDTH+CS_ADDR_BITS-1 -: (CS_ADDR_BITS ? CS_ADDR_BITS : 1)] : 1'b0;
   always@(posedge sdram_clk)
   if(state == CMD_ACTIVE)
      active_addr <= {addr_cs,addr_bank,addr_row,addr_col};

   always@(posedge sdram_clk or negedge res)
   if(!res)
      is_any_row_active <= 1'b0;
   else if(state == CMD_ACTIVE)
      is_any_row_active <= 1'b1;
   else if(state == CMD_PRECHARGE || state == CMD_REFRESH)
      is_any_row_active <= 1'b0;
   else if((state == CMD_READ || state == CMD_WRITE) && sdram_a[AUTOPRECHARGE_ENABLE_BIT]) // Note: always in current implementation!!!
      is_any_row_active <= 1'b0;

   wire row_miss = is_any_row_active &&
                   (addr_row != active_row ||
                   addr_cs != active_cs ||
                   addr_bank != active_bank);
