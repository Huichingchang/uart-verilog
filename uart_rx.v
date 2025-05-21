module uart_rx(
  input wire clk,
  input wire rst_n,
  input wire rx_line,      // UART接收腳位
  input wire baud_tick,     // Baud rate時脈
  output reg [7:0] rx_data,  //接收到的資料
  output reg rx_ready      //接收完成旗標(High for one tick)
  
);

  //狀態定義
  localparam IDLE = 3'd0;
  localparam START = 3'd1;
  localparam DATA = 3'd2;
  localparam STOP = 3'd3;
  localparam DONE = 3'd4;

  reg [2:0] state, next_state;
  reg [2:0] bit_cnt;  // 資料位元計數器
  reg [7:0] data_buf;  // 接收資料暫存
  reg [3:0] baud_cnt;  // 用於中間採樣

  //狀態轉移邏輯
  always @(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
       state <= IDLE;
     end else if (baud_tick) begin
       state <= next_state;
     end
  end

  //次態邏輯
  always @(*) begin
     case (state)
       IDLE: begin
         if (~rx_line)
            next_state = START;
         else
            next_state = IDLE;
       end
       START: next_state = DATA;
       DATA: begin
         if (bit_cnt == 3'd7)
            next_state = STOP;
         else
            next_state = DATA;
       end
       STOP: next_state = DONE;
       DONE: next_state = IDLE;
       default: next_state = IDLE;
     endcase
  end

  // 接收資料處理
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_cnt <= 3'd0;
      data_buf <= 8'd0;
      rx_data <= 8'd0;
      rx_ready <= 1'b0;
    end
    else if (baud_tick) begin
      case (state)
         IDLE: begin
            bit_cnt <= 3'd0;
            rx_ready <= 1'b0;
         end
         START: begin
           //忽略起始位元(rx_line應該為0)
         end
         DATA: begin
            data_buf[bit_cnt] <= rx_line;  // LSB First
            bit_cnt <= bit_cnt + 1;
         end
         STOP: begin
            // Stop bit應為1,可選擇檢查 rx_line == 1
         end
         DONE: begin
            rx_data <= {
				data_buf[0],data_buf[1],data_buf[2],data_buf[3],
				data_buf[4],data_buf[5],data_buf[6],data_buf[7]
				};
            rx_ready <= 1'b1;
         end
      endcase
    end
  end
endmodule

