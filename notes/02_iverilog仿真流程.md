# 笔记 02 —— iverilog + GTKWave 仿真闭环

不打开 Vivado 就能验证逻辑对不对，这是日常开发里用得最多的动作。整套流程几秒钟，
改一行代码就能重跑一次，比 Vivado 综合快两个数量级。

## 一、三步命令

```bat
cd /d D:\fpga-portfolio\projects\01_led_blink

D:\iverilog\bin\iverilog.exe -o sim.vvp src\led_blink.v sim\tb_led_blink.v
D:\iverilog\bin\vvp.exe sim.vvp
start "" "D:\iverilog\gtkwave\bin\gtkwave.exe" wave.vcd
```

- 第一步 **编译**：把 `.v` 源文件编译成 `sim.vvp`（iverilog 的中间格式）。
- 第二步 **运行**：`vvp` 执行仿真，testbench 里的 `$dumpfile` 写出 `wave.vcd`。
- 第三步 **看波形**：`start ""` 是"启动后立刻返回命令行"，不加会阻塞终端。

一键版：目录下已放 `run.bat`，双击或命令行执行 `run.bat` 即可。

## 二、testbench 模板

```verilog
`timescale 1ns / 1ps

module tb_xxx;
    reg  clk;
    reg  rst_n;
    wire out;

    xxx u_xxx (.clk(clk), .rst_n(rst_n), .out(out));

    always #10 clk = ~clk;        // 半周期 10ns -> 50MHz

    initial begin
        $dumpfile("wave.vcd");    // 波形文件名
        $dumpvars(0, tb_xxx);     // 0 = 记录全部层级

        clk = 1'b0; rst_n = 1'b0;
        #100 rst_n = 1'b1;        // 复位 100ns 后释放
        #2000;                    // 跑够时间
        $display("---- sim finished ----");
        $finish;                  // 不写会一直跑下去
    end
endmodule
```

三条铁律：

1. 时钟用 `always #半周期 clk = ~clk`，不要用 `forever`（`always` 更简洁）。
2. **必须有 `$finish`**，否则仿真不会自己停。
3. `$dumpvars(0, 顶层)` 的 `0` 表示递归记录所有层级，波形才能看到子模块内部信号。

## 三、GTKWave 使用要点

打开后窗口是空的，这是正常的，按下面来：

1. 左上 **SST** 面板点开 `tb_xxx` → 再点 `u_xxx`（被例化的模块）；
2. 下方信号列表里**双击** `clk / rst_n / led / cnt` 加进波形区；
3. 点工具栏 **Zoom Fit**（放大镜）铺满窗口；
4. 想测量周期：点 "Toggle Measure Marker" 放两个游标，看时间差。

## 四、本次自检的判读结论

`led_blink` 参数 `DIV = 8`，时钟 20ns：

- 计数 8 个周期 = 160ns 翻转一次 → **led 完整周期 320ns**；
- 复位期间（前 100ns）`cnt`、`led` 均为 0；
- 波形实测与计算一致 → iverilog 全链路打通。

## 五、常见报错对照表

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `iverilog -v` 疯狂刷屏 | `-v` 是 verbose，不是 version | 改用 `-V` |
| `gtkwave: can't open wave.vcd` | 命令行当前目录不对 | `cd /d` 到工程目录 |
| 双击 `run.bat` 无任何输出 | 安全软件拦截 bat | 手动敲三条命令 |
| VS Code 改代码不出红线 | linter 只在 open/save 触发 | `Ctrl+S` 保存 |
| Doctor 报 `iverilog not found` | `verilog.linting.path` 填了目录 | 该项留空 |
| 波形一直跑不停 | testbench 少了 `$finish` | 补上 `$finish` |
