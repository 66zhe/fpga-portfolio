@echo off
setlocal
cd /d "%~dp0"

set "IVERILOG=D:\iverilog\bin\iverilog.exe"
set "VVP=D:\iverilog\bin\vvp.exe"
set "GTKWAVE=D:\iverilog\gtkwave\bin\gtkwave.exe"

echo ==========================================
echo   FPGA selftest : compile - simulate - wave
echo ==========================================
echo.

if not exist "%IVERILOG%" (
    echo [ERROR] Cannot find iverilog.exe at:
    echo         %IVERILOG%
    echo Please verify the Icarus Verilog install folder.
    goto theend
)

echo [1/3] Compiling ...
"%IVERILOG%" -o sim.vvp tb_led_blink.v led_blink.v
if errorlevel 1 goto compilefail
echo       OK

echo.
echo [2/3] Running simulation ...
"%VVP%" sim.vvp

echo.
echo [3/3] Opening GTKWave ...
if exist "%GTKWAVE%" (
    start "" "%GTKWAVE%" wave.vcd
) else (
    echo [WARN] GTKWave not found at %GTKWAVE%
    echo Run manually in this folder:  gtkwave wave.vcd
)
echo.
echo Done. In GTKWave: expand tb_led_blink, then u_led_blink,
echo and double-click clk / rst_n / cnt / led.
goto theend

:compilefail
echo.
echo [FAILED] Compile error. Read the message above.

:theend
echo.
echo --- window stays open. Press any key to close ---
pause >nul
endlocal
