# ==========================================
# HIL Automation Script (Step 3)
# ==========================================
puts "============================================="
puts ">>> STARTING HARDWARE-IN-THE-LOOP (HIL)   <<<"
puts "============================================="

# 0. Clean up previous connections (Prevents TCP:localhost:3121 error)
catch {disconnect_hw_server -quiet}
catch {close_hw_manager -quiet}

# 1. Open physical connection with the Arty board
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

# 2. Identify the connected FPGA chip
set current_device [lindex [get_hw_devices] 0]
current_hw_device $current_device
refresh_hw_device -update_hw_probes false $current_device

# 3. Search for the Bitstream and Probes file (.ltx)
set bit_file [glob -nocomplain ./precompiled/*.bit]
set ltx_file [glob -nocomplain ./precompiled/*.ltx]

if {[llength $bit_file] == 0} {
    puts "\[ERROR\] No bitstream found! Did you run Step 2?"
    return
}

set target_bit [lindex $bit_file 0]
set_property PROGRAM.FILE $target_bit $current_device

if {[llength $ltx_file] > 0} {
    set_property PROBES.FILE [lindex $ltx_file 0] $current_device
    puts "\[INFO\] Probes file (.ltx) trovato e caricato!"
} else {
    puts "\[WARNING\] Nessun file .ltx trovato."
}

puts "\[INFO\] Programming FPGA with: $target_bit"
program_hw_devices $current_device

# ---> AGGIUNTA CRITICA: Aggiorna lo stato dopo aver programmato <---
refresh_hw_device $current_device

puts "============================================="
puts ">>> BOARD PROGRAMMED. STARTING AXI TEST...<<<"
puts "============================================="

# 4. Intercept the JTAG-to-AXI Master (Ricerca universale)
set jtag_axi [lindex [get_hw_axis] 0]
if {$jtag_axi == ""} {
    puts "\[ERROR\] JTAG-to-AXI IP not found in the hardware design!"
    return
}
puts "\[INFO\] JTAG-to-AXI agganciato: $jtag_axi"

# 5. Send the START command to the FSM (Address 0x44A00000)
puts "\[INFO\] Sending WRITE transaction to address 0x44A00000..."
create_hw_axi_txn start_txn [get_hw_axis $jtag_axi] -type WRITE -address 0000000044A00000 -data 00000001 -force
run_hw_axi start_txn

puts "============================================="
puts ">>> TEST SUCCESSFULLY COMPLETED!          <<<"
puts ">>> Check the led_pronto_2 on the board   <<<"
puts "============================================="