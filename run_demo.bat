@echo off
color 0A
cls
echo ==================================================================
echo         AUTOMATED DEMO: SoC FIR FILTER ON XILINX ARTY FPGA
echo ==================================================================
echo.
echo Questa demo eseguira' automaticamente:
echo  1. Ricostruzione del progetto Vivado (Clean Clone)
echo  2. Simulazione RTL con AXI VIP (Verifica Matematica)
echo  3. Esecuzione Hardware-in-the-Loop su FPGA
echo.
pause

echo.
echo ==================================================================
echo [STEP 1] Ricostruzione Progetto e Importazione IP...
echo ==================================================================
call vivado -mode batch -source recreate_project.tcl
if %errorlevel% neq 0 goto :error

echo.
echo ==================================================================
echo [STEP 2] Avvio Simulazione (Verifica Golden Model)...
echo ==================================================================
call vivado -mode batch -source run_sim.tcl
if %errorlevel% neq 0 goto :error

echo.
echo ==================================================================
echo [STEP 3] Sintesi e Implementazione (SKIPPATO PER LA DEMO)
echo ==================================================================
echo [INFO] Per ragioni di tempo, viene utilizzato il Golden Bitstream 
echo        pre-compilato situato nella cartella /precompiled/.
timeout /t 5 >nul

echo.
echo ==================================================================
echo [STEP 4] Programmazione Board ed Esecuzione HIL Test...
echo ==================================================================
echo Assicurati che la scheda Arty sia collegata via USB!
pause
call vivado -mode batch -source hil_test.tcl
if %errorlevel% neq 0 goto :error

echo.
echo ==================================================================
echo                  >>> DEMO COMPLETATA CON SUCCESSO! <<<
echo ==================================================================
pause
exit

:error
color 0C
echo.
echo ==================================================================
echo [ERRORE] Si e' verificato un problema durante l'esecuzione.
echo ==================================================================
pause
exit