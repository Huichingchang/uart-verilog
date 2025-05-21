module uart_tx(
	input wire clk,  // 系統時脈
	input wire rst_n,  //非同步reset
	input wire tx_start,  //啟動傳送
   input wire [7:0] tx_data,  //要傳送的資料(8-bit)
   input wire baud_tick,  //來自baud_gen的tick訊號
	output reg tx,         // UART 傳送腳位(TX)
   output reg tx_busy,  //傳輸中狀態
   output reg tx_done
);

        // 狀態定義
        localparam IDLE = 3'd0;
        localparam START = 3'd1;
        localparam DATA = 3'd2;
        localparam STOP = 3'd3;
        localparam DONE = 3'd4;

        reg [2:0] state, next_state;
        reg [2:0] bit_cnt;  //資料bit計數器(0~7)
        reg [7:0] shift_reg;  //資料移位暫存器
 
        //狀態轉移
        always @(posedge clk or negedge rst_n) begin
	        if (!rst_n)
               state <= IDLE;
           else if (baud_tick)
               state <= next_state;
        end

        //次態邏輯
        always @(*) begin
            case(state)
               IDLE: next_state = tx_start ? START: IDLE;
               START: next_state = DATA;
               DATA: next_state = (bit_cnt == 3'd7) ? STOP: DATA;
               STOP: next_state = DONE;
               DONE: next_state = IDLE;
               default: next_state = IDLE;
            endcase
        end

        //移位與計數
        always @(posedge clk or negedge rst_n) begin
           if(!rst_n) begin
              bit_cnt <= 3'd0;
              shift_reg <= 8'd0;
           end else if (baud_tick) begin
              case(state)
                IDLE: begin
                   if (tx_start) begin
                       shift_reg <= tx_data;
                       bit_cnt <= 3'd0;
                   end
                end
                DATA: begin
                  shift_reg <= shift_reg >> 1;
                  bit_cnt <= bit_cnt + 1;
                end
              endcase
           end
        end

        //輸出訊號產生
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
               tx <= 1'b1;  // TX空閒狀態為高電位
               tx_busy <= 1'b0;
               tx_done <= 1'b0;
            end else if (baud_tick) begin
                case(state)
                   IDLE: begin
	             tx <= 1'b1;
                     tx_busy <= 1'b0;
                     tx_done <= 1'b0; //清除
                   end
                   START: begin
 	             tx <= 1'b0;  // Start bit = 0
                     tx_busy <= 1'b1;
                     tx_done <= 1'b0;
                   end
                   DATA: begin
                     tx <= shift_reg[0];  //LSB first
                     tx_done <= 1'b0;
                   end
                   STOP: begin
                     tx <= 1'b1;   // Stop bit = 1
                     tx_done <= 1'b0;  
                   end
                   DONE: begin
                      tx <= 1'b1;   
                      tx_done <= 1'b1;  //這裡才assert
                   end
                endcase
             end
        end
endmodule
