`define SIM
module uart_top(
	input wire clk,  // 系統時脈(例如50MHz)
	input wire rst_n,  // 非同步reset (低有效)
	input wire [7:0] tx_data,  // 要傳送的資料
   input wire tx_start,   //傳送開始信號
	output wire tx_done,  //傳送完成訊號
   output wire tx_line,  //TX輸出線(接到UART線)

   input wire rx_line,  //RX輸入線(從UART線接收)
   output wire [7:0] rx_data,  //接收到的資料
   output wire rx_done   //接收完成訊號
);

//===分頻產生波特率時脈===
wire baud_tick;
`ifdef SIM
	assign baud_tick = clk;  //模擬時用clk當tick
`else
	baud_gen #(
	    .SYS_CLK_FREQ(50000000),  //實際clock頻率
       .BAUD_RATE(9600)
   ) u_baud_gen(
	    .clk(clk),
	    .rst_n(rst_n),
       .baud_tick(baud_tick)
        );
`endif

// === UART傳送端===
uart_tx u_uart_tx(
	  .clk(clk),
     .rst_n(rst_n),
 	  .tx_start(tx_start),
	  .tx_data(tx_data),
	  .baud_tick(baud_tick),
	  .tx_done(tx_done),
	  .tx(tx_line)
);

//=== UART 接收端===
uart_rx u_uart_rx(
	   .clk(clk),
      .rst_n(rst_n),
 	   .rx_line(rx_line),
	   .baud_tick(baud_tick),
	   .rx_data(rx_data),
	   .rx_ready(rx_done)
);
endmodule
