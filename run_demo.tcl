puts "=================================================================="
puts "        AUTOMATED DEMO: SoC FIR FILTER ON XILINX ARTY FPGA"
puts "=================================================================="
puts ">>> Executing Step 1: Project Reconstruction..."
source scripts/recreate_project.tcl

puts "=================================================================="
puts ">>> Executing Step 2: RTL Simulation..."
puts "=================================================================="
source scripts/run_sim.tcl

puts "=================================================================="
puts ">>> Executing Step 3: BITSTREAM Generation..."
puts "=================================================================="
source scripts/run_build.tcl

puts "=================================================================="
puts ">>> Executing Step 4: HIL Test on FPGA..."
puts "=================================================================="
source scripts/hil_test.tcl

puts "=================================================================="
puts "                  >>> DEMO COMPLETED SUCCESSFULLY! <<<"
puts "=================================================================="