`define SIM
`timescale 1ns/1ps
module uart_top_tb;

  //測試訊號
  reg clk;
  reg rst_n;
  reg tx_start;
  reg [7:0] tx_data;

  wire tx_done;
  wire tx_line;
  wire [7:0] rx_data;
  wire rx_done;
  
  // ===測試DUT===
  uart_top uut(
    .clk(clk),
    .rst_n(rst_n),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_done(tx_done),
    .tx_line(tx_line),  //TX輸出
    .rx_line(tx_line),  // Loopback到RX輸入
    .rx_data(rx_data),
    .rx_done(rx_done)
  );
  
  //=== Clock產生器(50MHz = 20ns週期)===
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end


  //===Reset===
  initial begin
     rst_n = 0;
     #50;
     rst_n =1;
  end

  //===模擬流程===
    initial begin
     //初始化
     tx_start = 0;
     tx_data = 8'h00;
     #100;

     //傳送資料0x5A
     tx_data = 8'hA5;
     tx_start = 1;
     @(posedge clk);
     tx_start = 0;

     //等待傳送結束 + 接收完成
     wait (rx_done == 1);
     #20;

     //顯示接收到的資料
     $display("=== UART Loopback Test Done ===");
     $display("TX Data: 0x%h", tx_data);
     $display("RX Data: 0x%h", rx_data);
	  
	  //自動驗證(可選)
	  if (rx_data !== 8'hA5)
		 $fatal("錯誤:接收到的資料錯誤!");
	  else
	    $display("接收資料正確!UART模擬通過!");
	  
     #1000;
     $stop;
  end
endmodule
