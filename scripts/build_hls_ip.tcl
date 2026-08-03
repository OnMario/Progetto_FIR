# =========================================================
# Script: build_hls_ip.tcl
# Description: Automates Vitis HLS synthesis and IP export
# =========================================================
puts ">>> \[INFO\] Building HLS FIR Engine IP..."

catch {close_project}

open_project -reset temp_hls_prj
set_top fir_engine

# path C/C++ files 
add_files ./src/hls/fir_engine/fir.cpp 

open_solution -reset "solution1" -flow_target vivado
set_part {xc7a100tcsg324-1}
create_clock -period 10 -name default

csynth_design
export_design -format ip_catalog -output ./ip_repo/fir_engine_hls_ip

close_project
puts ">>> \[INFO\] HLS IP successfully exported to ip_repo!"
exit