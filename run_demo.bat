@echo off
color 0A
cls
echo ==================================================================
echo         AUTOMATED DEMO: SoC FIR FILTER ON XILINX ARTY FPGA
echo ==================================================================
echo.
echo This demo will automatically execute:
echo  1. Vivado Project Reconstruction (Clean Clone)
echo  2. RTL Simulation with AXI VIP (Mathematical Verification)
echo  3. Hardware-in-the-Loop Execution on FPGA
echo.
pause

echo.
echo ==================================================================
echo [STEP 1] Project Reconstruction and IP Import...
echo ==================================================================
call vivado -mode batch -source recreate_project.tcl
if %errorlevel% neq 0 goto :error

echo.
echo ==================================================================
echo [STEP 2] Starting Simulation (Golden Model Verification)...
echo ==================================================================
call vivado -mode batch -source run_sim.tcl
if %errorlevel% neq 0 goto :error

echo.
echo ==================================================================
echo [STEP 3] Synthesis and Implementation (SKIPPED FOR DEMO)
echo ==================================================================
echo [INFO] To save time, the pre-compiled Golden Bitstream 
echo        located in the /precompiled/ folder will be used.
timeout /t 5 >nul

echo.
echo ==================================================================
echo [STEP 4] Board Programming and HIL Test Execution...
echo ==================================================================
echo Ensure the Arty board is connected via USB and turned on!
pause
call vivado -mode batch -source hil_test.tcl
if %errorlevel% neq 0 goto :error

echo.
echo ==================================================================
echo                  *** DEMO COMPLETED SUCCESSFULLY! ***
echo ==================================================================
pause
exit

:error
color 0C
echo.
echo ==================================================================
echo [ERROR] An issue occurred during execution.
echo ==================================================================
pause
exit