module UART(
input SCLK, SRES, WRITE_UCR, SET_UCR, CLEAR_UCR, READ_UCR, WRITE_UTR, WRITE_UTDR, UARTTxIE, UARTRxIE,
input [15:0] data,
output reg UARTIFG,
output [5:0] UCR, output reg [15:0] UTR, output reg [8:0] UTDR, output [8:0] URDR,
input RX, output reg TX
);

reg [2:0] StartBit;
reg [15:0] RxTcnt, TxTcnt;
reg [3:0] RxBitCnt, TxBitCnt;
reg TxIP, RxIP, len, StopBit;
reg [9:0] URDR_full;
reg RxIF, TxIF, delay_TxIP;

wire LoadTxBit, SaveRxBit, RxPacketEnd, TxPacketEnd, RxBitEnd;
wire [3:0] PacketLen;

assign URDR = URDR_full[8:0];

//assign SaveRxBit = {RxTcnt[14:0],1'b0}==UTR[15:0];
assign SaveRxBit = RxTcnt[14:0]==UTR[15:1];
assign LoadTxBit = TxTcnt==UTR;
assign RxPacketEnd = RxBitCnt==PacketLen;
assign TxPacketEnd = TxBitCnt==PacketLen;
assign RxBitEnd = RxTcnt==UTR;

assign PacketLen = len + 4'h8 + StopBit;


/////////////////// CLOCK DIVIDER REGISTER
always@(posedge SCLK or negedge SRES)
if(!SRES)
	UTR<=16'hFFFF;
else if(WRITE_UTR)
	UTR<=data;
/////////////////// CONTROL REGISTER
assign UCR = {RxIF, TxIF, len, StopBit, TxIP, RxIP};

always@(posedge SCLK or negedge SRES)
if(!SRES)
	len<=1'h0;
else if(WRITE_UCR)
	len<=data[3];
else if(SET_UCR)
	len<=data[3] | len;
else if(CLEAR_UCR)
	len<=~data[3] & len;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	StopBit<=1'h0;
else if(WRITE_UCR)
	StopBit<=data[2];
else if(SET_UCR)
	StopBit<=data[2] | StopBit;
else if(CLEAR_UCR)
	StopBit<=~data[2] & StopBit;
/////////////////// RECEIVER
always@(posedge SCLK or negedge SRES)
if(!SRES)
	StartBit<=3'h7;
else if(!RxIP)
	StartBit<={RX, StartBit[2:1]};
else
	StartBit<=3'h7;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	RxIP<=1'h0;
else if(RxIP & RxPacketEnd & RxBitEnd)
	RxIP<=1'b0;
else if(StartBit[1:0]==2'b01)
	RxIP<=1'b1;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	RxTcnt<=16'h0;
else if(RxIP)
	RxTcnt<= RxBitEnd ? 16'h0 : RxTcnt+16'h1;
else
	RxTcnt<=16'h0;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	RxBitCnt<=4'h0;
else if(RxBitEnd & RxIP)
	RxBitCnt<=RxBitCnt+4'h1;
else if(!RxIP)
	RxBitCnt<=4'h0;

always@(posedge SCLK)
if(SaveRxBit)
	URDR_full<={StopBit & len ? RX : 1'b0 , 
				StopBit ^ len ? RX : URDR_full[9] ,
				!StopBit & !len ? RX : URDR_full[8] ,
				URDR_full[7:1]};
/////////////////// TRANSMITTER
always@(posedge SCLK or negedge SRES)
if(!SRES)
	TX<=1'h1;
else if(TxIP & !delay_TxIP)
	TX<=1'b0;//START
else if(LoadTxBit & TxIP)
	TX<=UTDR[0];
else if(!TxIP)
	TX<=1'b1;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	TxIP<=1'h0;
else if(TxPacketEnd & LoadTxBit)
	TxIP<=1'b0;
else if(WRITE_UCR)
	TxIP<=data[1];
else if(SET_UCR)
	TxIP<=data[1] | TxIP;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	delay_TxIP<=1'b0;
else
	delay_TxIP<=TxIP;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	TxTcnt<=16'h0;
else if(TxIP & delay_TxIP)
	TxTcnt<= LoadTxBit ? 16'h0 : TxTcnt+16'h1;
else
	TxTcnt<=16'h0;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	TxBitCnt<=4'h0;
else if(LoadTxBit & TxIP)
	TxBitCnt<=TxBitCnt+4'h1;
else if(!TxIP)
	TxBitCnt<=4'h0;

always@(posedge SCLK)
if(WRITE_UTDR)
	UTDR<=data[8:0];
else if(LoadTxBit)
	UTDR<={!StopBit, len ? UTDR[8] : !StopBit, UTDR[7:1]};
/////////////////// INTERRUPT PART
always@(posedge SCLK or negedge SRES)
if(!SRES)
	UARTIFG<=1'b0;
else if((UARTRxIE & RxPacketEnd & RxBitEnd) | (UARTTxIE & TxPacketEnd & LoadTxBit) )
	UARTIFG<=1'b1;
else
	UARTIFG<=1'b0;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	RxIF<=1'b0;
else if(/*UARTRxIE & */RxPacketEnd & RxBitEnd)
	RxIF<=1'b1;
else if(READ_UCR)
	RxIF<=1'b0;

always@(posedge SCLK or negedge SRES)
if(!SRES)
	TxIF<=1'b0;
else if(/*UARTTxIE & */TxPacketEnd & LoadTxBit)
	TxIF<=1'b1;
else if(READ_UCR)
	TxIF<=1'b0;

endmodule
