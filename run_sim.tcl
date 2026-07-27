# ==========================================
# Simulation Automation Script (Step 1)
# ==========================================

# Force close any previously running simulations silently
close_sim -quiet

puts "============================================="
puts ">>> GENERATING IP SIMULATION MODELS       <<<"
puts "============================================="

# Forza la generazione dei file di simulazione per tutti i Block Design
generate_target Simulation [get_files *.bd]
export_ip_user_files -no_script -force

puts "============================================="
puts ">>> STARTING BEHAVIORAL SIMULATION        <<<"
puts "============================================="

# Launch the behavioral simulation
launch_simulation

# Run the simulation until the $finish command is reached in the Testbench
run all

puts "============================================="
puts ">>> SIMULATION COMPLETED                  <<<"
puts "============================================="