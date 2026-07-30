# ==============================================================================
# Tcl Script: Hardware-in-the-Loop Validation for 16-bit FIR
# ==============================================================================

puts "------------------------------------------------------"
puts " \[INFO\] Connecting to Board and Programming FPGA..."
puts "------------------------------------------------------"

# 0. Clean connection
catch {disconnect_hw_server -quiet}
catch {close_hw_manager -quiet}

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

# 1. Identify and program the device
set current_device [lindex [get_hw_devices] 0]
current_hw_device $current_device
refresh_hw_device -update_hw_probes false $current_device

set bit_file [glob -nocomplain ./precompiled/*.bit]
if {[llength $bit_file] == 0} {
    puts "\[ERROR\] No bitstream found! Run build step first."
    exit 1
}

set target_bit [lindex $bit_file 0]
set_property PROGRAM.FILE $target_bit $current_device
puts "\[INFO\] Programming FPGA with: $target_bit"
program_hw_devices $current_device
refresh_hw_device $current_device

# ==============================================================================
# HIL Configuration & Test
# ==============================================================================
set BRAM_BASE_ADDR 0xC0000000
set BRAM_OUT_ADDR  0xC0000100
set FSM_START_REG  "44A00000"
set FSM_DONE_REG   "44A00004"

set BLOCK_SIZE 16
set OUT_SIZE   26
set N_TAPS     11
set taps       {0 -10 -9 23 56 74 56 23 -9 -10 0}

puts "------------------------------------------------------"
puts " \[INFO\] Initializing JTAG-to-AXI Connection..."
puts "------------------------------------------------------"
set jtag_axi [lindex [get_hw_axis] 0]
if {$jtag_axi == ""} {
    puts "\[ERROR\] JTAG-to-AXI IP not found! Check your Block Design."
    exit 1
}
reset_hw_axi [get_hw_axis $jtag_axi]

# Pulisce la memoria di Vivado da eventuali transazioni rimaste appese in crash precedenti
catch {delete_hw_axi_txn [get_hw_axi_txns *]}

# ==============================================================================
# 1. Data Generation (16-bit random numbers)
# ==============================================================================
set input_data {}
for {set i 0} {$i < $BLOCK_SIZE} {incr i} {
    lappend input_data [expr {int(rand() * 20) - 10}]
}

# ==============================================================================
# 2. Write to BRAM (REUSING A SINGLE TRANSACTION OBJECT)
# ==============================================================================
puts " \[INFO\] Writing Data to BRAM (16-bit packed)..."
for {set i 0} {$i < [expr {$BLOCK_SIZE / 2}]} {incr i} {
    set val0 [expr {[lindex $input_data [expr {$i*2}]] & 0xFFFF}]
    set val1 [expr {[lindex $input_data [expr {$i*2 + 1}]] & 0xFFFF}]
    set word [expr {($val1 << 16) | $val0}]
    
    set addr [format "%08X" [expr {$BRAM_BASE_ADDR + ($i * 4)}]]
    set data [format "%08X" $word]
    
    # Sovrascrive lo stesso oggetto 'wr_txn' per evitare i memory leak
    create_hw_axi_txn wr_txn [get_hw_axis $jtag_axi] -type WRITE -address $addr -data $data -force
    run_hw_axi [get_hw_axi_txns wr_txn]
    
    # Pausa microscopica per evitare di ingolfare il cavo USB
    after 5 
}

# ==============================================================================
# 3. Start FSM and Polling
# ==============================================================================
puts "------------------------------------------------------"
puts " \[INFO\] Starting Hardware FSM and Polling..."

create_hw_axi_txn ctrl_txn [get_hw_axis $jtag_axi] -type WRITE -address $FSM_START_REG -data 00000001 -force
run_hw_axi [get_hw_axi_txns ctrl_txn]
after 5

# Crea l'oggetto di lettura una volta sola fuori dal ciclo
create_hw_axi_txn poll_txn [get_hw_axis $jtag_axi] -type READ -address $FSM_DONE_REG -force

set fsm_is_done 0
set timeout 100
set count 0

while {$fsm_is_done == 0 && $count < $timeout} {
    # Riesegue l'oggetto senza ricrearlo
    run_hw_axi [get_hw_axi_txns poll_txn]
    set status_hex [get_property DATA [get_hw_axi_txns poll_txn]]
    
    if {$status_hex eq "00000001"} {
        set fsm_is_done 1
        puts " \[SUCCESS\] Hardware FSM: Elaboration Completed!"
    } else {
        after 10
        incr count
    }
}

if {$fsm_is_done == 0} {
    puts " \[ERROR\] FSM Timeout! The hardware took too long or crashed."
}

create_hw_axi_txn ctrl_txn [get_hw_axis $jtag_axi] -type WRITE -address $FSM_START_REG -data 00000000 -force
run_hw_axi [get_hw_axi_txns ctrl_txn]
after 5

# ==============================================================================
# 4. Golden Model
# ==============================================================================
set golden_output {}
set shift_reg {0 0 0 0 0 0 0 0 0 0 0} 

for {set b 0} {$b < $OUT_SIZE} {incr b} {
    set x 0
    if {$b < $BLOCK_SIZE} { set x [lindex $input_data $b] }
    
    set acc 0
    for {set i [expr {$N_TAPS - 1}]} {$i > 0} {incr i -1} {
        lset shift_reg $i [lindex $shift_reg [expr {$i - 1}]]
        set acc [expr {$acc + ([lindex $shift_reg $i] * [lindex $taps $i])}]
    }
    lset shift_reg 0 $x
    set acc [expr {$acc + ([lindex $shift_reg 0] * [lindex $taps 0])}]
    
    lappend golden_output $acc
}

# ==============================================================================
# 5. Reading and Verifying Results
# ==============================================================================
puts "------------------------------------------------------"
puts " \[INFO\] Verifying Results (Hardware vs Golden Model)..."
set error_count 0
set hw_outputs {}

for {set i 0} {$i < [expr {$OUT_SIZE / 2}]} {incr i} {
    set addr [format "%08X" [expr {$BRAM_OUT_ADDR + ($i * 4)}]]
    
    # Sovrascrive lo stesso oggetto 'rd_txn'
    create_hw_axi_txn rd_txn [get_hw_axis $jtag_axi] -type READ -address $addr -force
    run_hw_axi [get_hw_axi_txns rd_txn]
    after 5
    
    set hw_hex [get_property DATA [get_hw_axi_txns rd_txn]]
    set hw_val [scan $hw_hex "%x"]
    
    set val0 [expr {$hw_val & 0xFFFF}]
    set val1 [expr {($hw_val >> 16) & 0xFFFF}]
    if {$val0 >= 32768} { set val0 [expr {$val0 - 65536}] }
    if {$val1 >= 32768} { set val1 [expr {$val1 - 65536}] }
    
    lappend hw_outputs $val0
    lappend hw_outputs $val1
}

for {set i 0} {$i < $OUT_SIZE} {incr i} {
    set hw_val [lindex $hw_outputs $i]
    set exp_val [lindex $golden_output $i]
    
    if {$hw_val != $exp_val} {
        puts " \[ERROR\] Index $i -> Expected: $exp_val, HW Read: $hw_val"
        incr error_count
    }
}

puts "------------------------------------------------------"
if {$error_count == 0} {
    puts " \[SUCCESS\] Hardware validated successfully!"
} else {
    puts " \[ERROR\] TEST FAILED with $error_count errors."
}
puts "------------------------------------------------------"