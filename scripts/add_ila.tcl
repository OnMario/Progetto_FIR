puts ">>> [INFO] Inserting ILA Debug Core post-synthesis..."

set_property MARK_DEBUG true [get_nets {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/state[0]}]
set_property MARK_DEBUG true [get_nets {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/state[1]}]
set_property MARK_DEBUG true [get_nets {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/state[2]}]
set_property MARK_DEBUG true [get_nets {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/step_count_reg_n_0_[0]}]
set_property MARK_DEBUG true [get_nets {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/step_count_reg_n_0_[1]}]
set_property MARK_DEBUG true [get_nets {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/step_count_reg_n_0_[2]}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]

set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list synth_top_i/clk_wiz_0/inst/clk_out1]]

set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/state[0]} {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/state[1]} {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/state[2]}]]

create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/step_count_reg_n_0_[0]}]]

create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/step_count_reg_n_0_[1]}]]

create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {synth_top_i/design_1_0/engine_controller_fsm_0/U0/engine_controller_fsm_master_lite_v1_0_M00_AXI_inst/step_count_reg_n_0_[2]}]]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_100MHz_IBUF]

puts ">>> [INFO] ILA Core inserted successfully."