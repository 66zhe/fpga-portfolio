# fpga-portfolio

面向 2027 春招的 FPGA 学习与项目仓库。目标：在春招前产出 3 个可写进简历、可现场演示的 FPGA 项目。

## 硬件 / 环境

| 项 | 型号 / 版本 | 说明 |
| --- | --- | --- |
| 开发板 | 正点原子 达芬奇 FPGA 开发板 | 主控 **XC7A35TFGG484-2**（Artix-7） |
| 综合实现 | Vivado 2020.2 | 安装路径 `E:\Xilink\Vivado\2020.2` |
| 仿真 | Icarus Verilog 12.0 + GTKWave 3.3.100 | 路径 `D:\iverilog` |
| 编辑器 | VS Code + Verilog-HDL / TerosHDL | 语法检查走 iverilog linter |
| 符号索引 | Universal Ctags 6.1.0 | `D:\tools\ctags\ctags.exe` |
| 串口 | XCOM V2.0 + CH340/CH341 驱动 | 上板联调用 |

## 目录约定

```
fpga-portfolio/
├─ notes/          学习笔记（每天一篇，截图放 notes/img/）
├─ projects/       每个项目一个目录，自带 src/ sim/ 和 README
└─ README.md
```

每个项目目录统一结构，`src/` 放可综合代码，`sim/` 放 testbench，根目录放 `run.bat`（iverilog 一键仿真）。

## 项目进度

| # | 项目 | 状态 | 对应简历能力点 |
| --- | --- | --- | --- |
| 0 | `projects/01_led_blink` | ✅ 仿真通过 | 工具链打通、分频、testbench 写法 |
| 1 | 待定（基础外设 / 接口类） | ⬜ 未开始 | — |
| 2 | 待定（通信 / 协议类） | ⬜ 未开始 | — |
| 3 | 待定（综合 / 小型系统类） | ⬜ 未开始 | — |

## 一键仿真（不依赖 Vivado，秒级反馈）

```bat
cd /d D:\fpga-portfolio\projects\01_led_blink
run.bat
```

等价于三条命令：

```bat
D:\iverilog\bin\iverilog.exe -o sim.vvp src\led_blink.v sim\tb_led_blink.v
D:\iverilog\bin\vvp.exe sim.vvp
start "" "D:\iverilog\gtkwave\bin\gtkwave.exe" wave.vcd
```
