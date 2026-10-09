// led_blink.v —— 自检用最小模块
// 功能：时钟驱动下计数，计满 DIV 个周期翻转一次 led
// 这是你写的第一个能跑通 iverilog -> gtkwave 全链路的模块
`timescale 1ns / 1ps

module led_blink #(
    parameter DIV = 8          // 分频系数：每 DIV 个时钟周期翻转一次
)(
    input  wire clk,
    input  wire rst_n,         // 低电平有效复位
    output reg  led
);

    reg [7:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd0;
            led <= 1'b0;
        end else if (cnt == DIV - 1) begin
            cnt <= 8'd0;
            led <= ~led;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end


endmodule