puts "=================================================================="
puts "        AUTOMATED DEMO: SoC FIR FILTER ON XILINX ARTY FPGA"
puts "=================================================================="
puts ">>> Esecuzione Step 1: Ricostruzione Progetto..."
source recreate_project.tcl

puts "=================================================================="
puts ">>> Esecuzione Step 2: Simulazione RTL..."
puts "=================================================================="
source run_sim.tcl

puts "=================================================================="
puts ">>> Esecuzione Step 3: HIL Test su FPGA..."
puts "=================================================================="
source hil_test.tcl

puts "=================================================================="
puts "                  >>> DEMO COMPLETATA CON SUCCESSO! <<<"
puts "=================================================================="