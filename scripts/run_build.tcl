puts "============================================="
puts ">>> STARTING BITSTREAM GENERATION         <<<"
puts "============================================="

reset_run synth_1
reset_run impl_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

puts "============================================="
puts ">>> BITSTREAM SUCCESSFULLY GENERATED!     <<<"
puts "============================================="

puts "\n          *** BUILD REPORT ***"
puts "    \[REPORT\] Project : [current_project]"
puts "    \[REPORT\] Status  : [get_property status [get_runs impl_1]]"
puts "    \[REPORT\] Elapsed : [get_property stats.elapsed [get_runs impl_1]]"
puts "    \[REPORT\] WNS     : [get_property stats.wns [get_runs impl_1]]"
puts "    \[REPORT\] WHS     : [get_property stats.whs [get_runs impl_1]]\n"