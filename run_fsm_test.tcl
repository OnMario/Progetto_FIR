# ==============================================================================
# Tcl Script: Hardware-in-the-Loop Validation for 16-bit FIR (short)
# ==============================================================================

set BRAM_BASE_ADDR 0xC0000000
set BRAM_OUT_ADDR  0xC0000100
set FSM_START_REG  0x44A00000
set FSM_DONE_REG   0x44A00004

set BLOCK_SIZE 16
set OUT_SIZE   26
set N_TAPS     11
set taps       {0 -10 -9 23 56 74 56 23 -9 -10 0}

puts "------------------------------------------------------"
puts " Initializing JTAG-to-AXI Connection..."
puts "------------------------------------------------------"
set jtag_axi [lindex [get_hw_axis] 0]
reset_hw_axi $jtag_axi

# ==============================================================================
# 1. Data Generation (16-bit random numbers)
# ==============================================================================
set input_data {}
for {set i 0} {$i < $BLOCK_SIZE} {incr i} {
    lappend input_data [expr {int(rand() * 20) - 10}] ;# Numbers between -10 and +9
}

# ==============================================================================
# 2. Write to BRAM (Packing: two 16-bit 'shorts' into one 32-bit 'word')
# ==============================================================================
puts " Writing Data to BRAM (16-bit packed)..."
for {set i 0} {$i < [expr {$BLOCK_SIZE / 2}]} {incr i} {
    set val0 [expr {[lindex $input_data [expr {$i*2}]] & 0xFFFF}]
    set val1 [expr {[lindex $input_data [expr {$i*2 + 1}]] & 0xFFFF}]
    set word [expr {($val1 << 16) | $val0}]
    
    set addr [format "0x%08X" [expr {$BRAM_BASE_ADDR + ($i * 4)}]]
    set data [format "0x%08X" $word]
    create_hw_axi_txn wr_txn_$i $jtag_axi -type write -address $addr -data $data -force
    run_hw_axi wr_txn_$i
}

# ==============================================================================
# 3. Start FSM
# ==============================================================================
puts "------------------------------------------------------"
puts " Starting Hardware FSM and Polling..."
create_hw_axi_txn start_fsm $jtag_axi -type write -address $FSM_START_REG -data 00000001 -force
run_hw_axi start_fsm

create_hw_axi_txn poll_fsm $jtag_axi -type read -address $FSM_DONE_REG -force
set fsm_is_done 0
set timeout 100
set count 0

while {$fsm_is_done == 0 && $count < $timeout} {
    run_hw_axi poll_fsm
    set status_hex [get_property DATA [get_hw_axi_txns poll_fsm]]
    if {$status_hex eq "00000001"} {
        set fsm_is_done 1
        puts " Hardware FSM: Elaboration Completed!"
    } else {
        after 10
        incr count
    }
}

create_hw_axi_txn reset_fsm $jtag_axi -type write -address $FSM_START_REG -data 00000000 -force
run_hw_axi reset_fsm

# ==============================================================================
# 4. Golden Model
# ==============================================================================
set golden_output {}
set shift_reg {0 0 0 0 0 0 0 0 0 0 0} ;# Initialization

for {set b 0} {$b < $OUT_SIZE} {incr b} {
    # Read input
    set x 0
    if {$b < $BLOCK_SIZE} { set x [lindex $input_data $b] }
    
    set acc 0
    # Shift 
    for {set i [expr {$N_TAPS - 1}]} {$i > 0} {incr i -1} {
        lset shift_reg $i [lindex $shift_reg [expr {$i - 1}]]
        set acc [expr {$acc + ([lindex $shift_reg $i] * [lindex $taps $i])}]
    }
    lset shift_reg 0 $x
    set acc [expr {$acc + ([lindex $shift_reg 0] * [lindex $taps 0])}]
    
    lappend golden_output $acc
}

# ==============================================================================
# 5. Reading and Verifying Results (Unpacking)
# ==============================================================================
puts "------------------------------------------------------"
puts " Verifying Results (Hardware vs Golden Model)..."
set error_count 0
set hw_outputs {}

for {set i 0} {$i < [expr {$OUT_SIZE / 2}]} {incr i} {
    set addr [format "0x%08X" [expr {$BRAM_OUT_ADDR + ($i * 4)}]]
    create_hw_axi_txn rd_txn_$i $jtag_axi -type read -address $addr -force
    run_hw_axi rd_txn_$i
    
    set hw_hex [get_property DATA [get_hw_axi_txns rd_txn_$i]]
    set hw_val [scan $hw_hex "%x"]
    
    # Unpack the two shorts and apply sign-extension
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
        puts " ERROR at index $i -> Expected: $exp_val, HW Read: $hw_val"
        incr error_count
    }
}

puts "------------------------------------------------------"
if {$error_count == 0} {
    puts " SUCCESS! Hardware validated."
} else {
    puts " TEST FAILED with $error_count errors."
}
puts "------------------------------------------------------"