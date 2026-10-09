// tb_led_blink.v —— 自检用 testbench
// 生成 50MHz 时钟（周期 20ns），复位后跑 2000ns，波形写进 wave.vcd
`timescale 1ns / 1ps

module tb_led_blink;

    reg  clk;
    reg  rst_n;
    wire led;

    // 实例化被测模块
    led_blink #(
        .DIV(8)
    ) u_led_blink (
        .clk  (clk),
        .rst_n(rst_n),
        .led  (led)
    );

    // 时钟：每 10ns 翻转一次 -> 周期 20ns -> 50MHz
    always #10 clk = ~clk;

    initial begin
        // 波形输出，GTKWave 读这个文件
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_led_blink);

        // 初始化
        clk   = 1'b0;
        rst_n = 1'b0;

        // 复位 100ns 后释放
        #100 rst_n = 1'b1;

        // 跑 2000ns
        #2000;

        $display("---- sim finished ----");
        $finish;
    end

endmodule
