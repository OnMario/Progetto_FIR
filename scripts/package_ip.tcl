# =========================================================
# Script: package_ip.tcl
# Description: Packages the custom FSM VHDL into a Vivado IP
# =========================================================
set ip_name "engine_controller_fsm"
set src_dir "./src/hdl/fsm"
set ip_dir "./ip_repo/${ip_name}"

puts ">>> \[INFO\] Packaging IP: ${ip_name}..."
catch {close_project}

file delete -force $ip_dir
file mkdir $ip_dir

create_project -force temp_ip_prj $ip_dir -part xc7a100tcsg324-1

set vhdl_files [glob -nocomplain ${src_dir}/*.vhd]
if {[llength $vhdl_files] == 0} {
    puts ">>> \[ERROR\] No VHDL file found in the folder ${src_dir}!"
    exit 1
}
import_files -norecurse -fileset [current_fileset] $vhdl_files
update_compile_order -fileset sources_1
set_property top $ip_name [current_fileset]

set_msg_config -id {[IP_Flow 19-3833]} -suppress

ipx::package_project -root_dir $ip_dir -vendor xilinx.com -library user -taxonomy /UserIP
set_property name $ip_name [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]

close_project
puts ">>> \[INFO\] IP Packaging completed successfully."