# 01_led_blink —— 工具链自检项目

## 功能

`led_blink` 是一个参数化分频闪灯模块：每计满 `DIV` 个时钟周期翻转一次 `led`。

- 默认 `DIV = 8`
- testbench 给 50MHz 时钟（周期 20ns）
- 每 8 个周期（160ns）翻转一次 → **led 方波周期 320ns**

## 运行

```bat
cd /d D:\fpga-portfolio\projects\01_led_blink
run.bat
```

或在 VS Code 终端里手动三步：

```bat
D:\iverilog\bin\iverilog.exe -o sim.vvp src\led_blink.v sim\tb_led_blink.v
D:\iverilog\bin\vvp.exe sim.vvp
start "" "D:\iverilog\gtkwave\bin\gtkwave.exe" wave.vcd
```

## 自动校验（Python）

不盯波形数格子，直接用脚本核对周期：

```bat
cd /d D:\fpga-portfolio\projects\01_led_blink
python tools\vcd_period_check.py
```

`tools/vcd_period_check.py` 会解析 `wave.vcd`，把 led 每次翻转的时刻与间隔打出来，
并断言间隔是否等于理论值 160ns：

```
[PASS] 所有间隔均为 160 ns，与 DIV=8 × 20ns 理论值一致
       → led 完整周期 = 320 ns
```

## 预期波形

1. `rst_n` 前 100ns 为低，`cnt` 与 `led` 保持 0；
2. 100ns 后 `cnt` 从 0 递增到 7 归零，`led` 同步翻转；
3. 测量 led 相邻两个上升沿间隔 = **320ns**
   （GTKWave 实测 `Marker: B+321 ns | Base: 249 ns`，截图见 `notes/img/03_gtkwave_led_blink.png`）。

> GTKWave 打开后默认空白是正常的：左侧 SST 里点 `tb_led_blink` → `u_led_blink`，
> 下方把 `clk / rst_n / led / cnt` 双击加进去，再点 **Zoom Fit**（放大镜图标）。

## 学到的点

- 时序逻辑标准写法：`always @(posedge clk or negedge rst_n)` + 低电平复位
- 阻塞/非阻塞：时序块里一律 `<=`
- testbench 三件套：`$dumpfile` / `$dumpvars` / 时钟 `always #10 clk = ~clk`
- `parameter` 参数化，方便仿真用小 DIV、上板用大 DIV
