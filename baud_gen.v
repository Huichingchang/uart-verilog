module baud_gen #(
    parameter SYS_CLK_FREQ = 50000000,  //系統時脈(Hz),例如50MHz
    parameter BAUD_RATE = 9600  //UART波特率
)
(
    input wire clk,  //系統時脈輸入
    input wire rst_n,  //非同步reset (低有效)
    output reg baud_tick  //每個baud時間產生一個tick
);

    //計算除頻常數: 系統時脈/波特率
    localparam integer BAUD_DIV = SYS_CLK_FREQ / BAUD_RATE;

    reg [12:0] counter;  // for 9600 baud @ 50MHz->約5208需要13 bit

    always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
	  counter <= 0;
          baud_tick <= 0;
       end else begin
	  if (counter == BAUD_DIV - 1) begin
              counter <= 0;
              baud_tick <= 1;
          end else begin
	      counter <= counter + 1;
              baud_tick <= 0;
          end
       end
    end
endmodule
