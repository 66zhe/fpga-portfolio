"""
vcd_period_check.py —— 用 Python 解析 VCD 波形，自动核对信号翻转间隔

用途：仿真跑完后，不靠肉眼读 GTKWave 截图，直接用脚本把"真实周期"算出来。
     这是"Python 辅助硬件验证"的第一个小例子：仿真工具负责产生数据，Python 负责断言。

用法：
    python vcd_period_check.py            # 默认读本目录上两级的 wave.vcd
    python vcd_period_check.py 别的.vcd

运行前提：先跑过 run.bat，生成 wave.vcd
"""

import sys
import os

EXPECTED_NS = 160.0          # DIV=8 × 时钟周期 20ns = 160ns 翻转一次
SIGNAL_ID = "!"              # wave.vcd 里 led 信号的 VCD 标识符
TIME_UNIT_PS = 1000          # 1ns = 1000ps（本工程 timescale 1ns/1ps）


def parse_edges(path, sig_id):
    """从 VCD 中提取某个 1 bit 信号的所有 (时刻ps, 值) 变化点"""
    t = 0
    edges = []
    with open(path, encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if line.startswith("#"):                 # 时间戳行：#2130000
                t = int(line[1:])
            elif len(line) == 2 and line[1] == sig_id and line[0] in "01":
                edges.append((t, line[0]))           # 值变化行：1! / 0!
    return edges


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    vcd = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, "..", "wave.vcd")
    vcd = os.path.normpath(vcd)

    if not os.path.exists(vcd):
        print(f"[X] 找不到波形文件: {vcd}")
        print("    先双击项目根目录的 run.bat 生成 wave.vcd")
        return 1

    edges = parse_edges(vcd, SIGNAL_ID)
    if len(edges) < 3:
        print(f"[X] 只找到 {len(edges)} 个变化点，波形可能没抓到或信号名不对")
        return 1

    # 跳过复位期间（首个边沿也在其中），只看稳定翻转阶段
    times = [t for t, _ in edges if t > 100_000]
    gaps_ns = [(times[i + 1] - times[i]) / TIME_UNIT_PS for i in range(len(times) - 1)]

    print("=" * 46)
    print(f"波形文件: {vcd}")
    print(f"led 电平变化次数: {len(edges)}")
    print("-" * 46)
    print("各次翻转时刻 (ns):", [f"{t/1000:.0f}" for t in times])
    print("相邻翻转间隔 (ns):", [f"{g:.0f}" for g in gaps_ns])
    print("-" * 46)

    ok = all(abs(g - EXPECTED_NS) < 0.001 for g in gaps_ns)
    if ok:
        print(f"[PASS] 所有间隔均为 {EXPECTED_NS:.0f} ns，与 DIV=8 × 20ns 理论值一致")
        print(f"       → led 完整周期 = {EXPECTED_NS*2:.0f} ns")
        return 0
    print(f"[FAIL] 期望 {EXPECTED_NS:.0f} ns，实测 {gaps_ns}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
