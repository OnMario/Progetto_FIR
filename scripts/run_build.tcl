# ==========================================
# Bitstream Automation Script (Step 2)
# ==========================================
puts "============================================="
puts ">>> STARTING BITSTREAM GENERATION         <<<"
puts "============================================="

reset_run synth_1
reset_run impl_1

# Launch synthesis, implementation, and bitstream generation
# The -jobs 8 flag uses up to 8 CPU cores to speed up the process
launch_runs impl_1 -to_step write_bitstream -jobs 8

# Pause the script execution and wait for Vivado to finish the build
wait_on_run impl_1

puts "============================================="
puts ">>> BITSTREAM SUCCESSFULLY GENERATED!     <<<"
puts "============================================="

# ==========================================
# Report
# ==========================================
puts "\n          *** RESOCONTO BUILD ***"
puts "    \[REPORT\] Progetto : [current_project]"
puts "    \[REPORT\] Status   : [get_property status [get_runs impl_1]]"
puts "    \[REPORT\] Elapsed  : [get_property stats.elapsed [get_runs impl_1]]"
puts "    \[REPORT\] WNS      : [get_property stats.wns [get_runs impl_1]]"
puts "    \[REPORT\] WHS      : [get_property stats.whs [get_runs impl_1]]\n"