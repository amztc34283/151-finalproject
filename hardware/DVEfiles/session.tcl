# Begin_DVE_Session_Save_Info
# DVE reload session
# Saved on Thu Nov 21 21:57:18 2019
# Designs open: 1
#   V1: /home/cc/eecs151/fa19/class/eecs151-abm/fa19_team28/hardware/sim/echo_testbench.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: echo_testbench
#   Wave.1: 88 signals
#   Group count = 14
#   Group uatransmit signal count = 5
#   Group controls signal count = 12
#   Group mmap_mem signal count = 8
#   Group uareceive signal count = 8
#   Group Group1 signal count = 3
#   Group Group2 signal count = 7
#   Group ALU signal count = 4
#   Group wb_mux signal count = 5
#   Group mmap_mem_1 signal count = 8
#   Group MMap_DMem_mux signal count = 5
#   Group rf signal count = 12
# End_DVE_Session_Save_Info

# DVE version: G-2012.09
# DVE build date: Aug 24 2012 00:30:46


#<Session mode="Reload" path="/home/cc/eecs151/fa19/class/eecs151-abm/fa19_team28/hardware/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Reload
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all
gui_clear_window -type Wave
gui_clear_window -type List

# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE Topleve session: 


# Create and position top-level windows :TopLevel.1

set TopLevel.1 TopLevel.1

# Docked window settings
set HSPane.1 HSPane.1
set Hier.1 Hier.1
set DLPane.1 DLPane.1
set Data.1 Data.1
set Console.1 Console.1
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 Source.1
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level windows :TopLevel.2

set TopLevel.2 TopLevel.2

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 Wave.1
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 506} {child_wave_right 1235} {child_wave_colname 246} {child_wave_colvalue 255} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings


#</WindowLayout>

#<Database>

# DVE Open design session: 

if { ![gui_is_db_opened -db {/home/cc/eecs151/fa19/class/eecs151-abm/fa19_team28/hardware/sim/echo_testbench.vpd}] } {
	gui_open_db -design V1 -file /home/cc/eecs151/fa19/class/eecs151-abm/fa19_team28/hardware/sim/echo_testbench.vpd -nosource
}
gui_set_precision 1ps
gui_set_time_units 1ps
#</Database>

# DVE Global setting session: 


# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {echo_testbench.CPU.rf}
gui_load_child_values {echo_testbench.CPU.on_chip_uart.uareceive}
gui_load_child_values {echo_testbench.CPU.ALU}
gui_load_child_values {echo_testbench.CPU.mmap_mem}
gui_load_child_values {echo_testbench.CPU.MMap_DMem_mux}
gui_load_child_values {echo_testbench.off_chip_uart.uatransmit}
gui_load_child_values {echo_testbench.CPU.wb_mux}


set _session_group_127 uatransmit
gui_sg_create "$_session_group_127"
set uatransmit "$_session_group_127"

gui_sg_addsignal -group "$_session_group_127" { echo_testbench.off_chip_uart.uatransmit.bit_counter echo_testbench.off_chip_uart.uatransmit.data_in_ready echo_testbench.off_chip_uart.uatransmit.data_in echo_testbench.off_chip_uart.uatransmit.tx_shift echo_testbench.off_chip_uart.uatransmit.data_in_valid }

set _session_group_128 controls
gui_sg_create "$_session_group_128"
set controls "$_session_group_128"

gui_sg_addsignal -group "$_session_group_128" { echo_testbench.CPU.controls.inst echo_testbench.CPU.controls.ex_state echo_testbench.CPU.controls.mem_wb_state echo_testbench.CPU.controls.data_out_valid echo_testbench.CPU.controls.data_in_ready echo_testbench.CPU.controls.MMapSel echo_testbench.CPU.controls.MMap_DMem_Sel echo_testbench.CPU.controls.data_out_ready echo_testbench.CPU.controls.data_in_valid echo_testbench.CPU.controls.ex_inst_reg echo_testbench.CPU.controls.mem_wb_inst_reg echo_testbench.CPU.controls.ALU_out_mem }

set _session_group_129 mmap_mem
gui_sg_create "$_session_group_129"
set mmap_mem "$_session_group_129"

gui_sg_addsignal -group "$_session_group_129" { echo_testbench.CPU.mmap_mem.clk echo_testbench.CPU.mmap_mem.rst echo_testbench.CPU.mmap_mem.MMap_Sel echo_testbench.CPU.mmap_mem.data_in_ready echo_testbench.CPU.mmap_mem.data_out_valid echo_testbench.CPU.mmap_mem.MMap_dout echo_testbench.CPU.mmap_mem.cycle_counter echo_testbench.CPU.mmap_mem.inst_counter }

set _session_group_130 uareceive
gui_sg_create "$_session_group_130"
set uareceive "$_session_group_130"

gui_sg_addsignal -group "$_session_group_130" { echo_testbench.CPU.on_chip_uart.uareceive.has_byte echo_testbench.CPU.on_chip_uart.uareceive.bit_counter echo_testbench.CPU.on_chip_uart.uareceive.data_out echo_testbench.CPU.on_chip_uart.uareceive.data_out_ready echo_testbench.CPU.on_chip_uart.uareceive.start echo_testbench.CPU.on_chip_uart.uareceive.data_out_valid echo_testbench.CPU.on_chip_uart.uareceive.rx_shift echo_testbench.CPU.on_chip_uart.uareceive.serial_in }

set _session_group_131 Group1
gui_sg_create "$_session_group_131"
set Group1 "$_session_group_131"

gui_sg_addsignal -group "$_session_group_131" { }

set _session_group_132 $_session_group_131|
append _session_group_132 uatransmit
gui_sg_create "$_session_group_132"
set Group1|uatransmit "$_session_group_132"

gui_sg_addsignal -group "$_session_group_132" { echo_testbench.CPU.on_chip_uart.uatransmit.clk echo_testbench.CPU.on_chip_uart.uatransmit.reset echo_testbench.CPU.on_chip_uart.uatransmit.data_in echo_testbench.CPU.on_chip_uart.uatransmit.data_in_valid echo_testbench.CPU.on_chip_uart.uatransmit.data_in_ready echo_testbench.CPU.on_chip_uart.uatransmit.serial_out echo_testbench.CPU.on_chip_uart.uatransmit.tx_shift echo_testbench.CPU.on_chip_uart.uatransmit.bit_counter echo_testbench.CPU.on_chip_uart.uatransmit.clock_counter echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_FREQ echo_testbench.CPU.on_chip_uart.uatransmit.BAUD_RATE echo_testbench.CPU.on_chip_uart.uatransmit.SYMBOL_EDGE_TIME echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_COUNTER_WIDTH }
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_FREQ}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_FREQ}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.BAUD_RATE}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.BAUD_RATE}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.SYMBOL_EDGE_TIME}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.SYMBOL_EDGE_TIME}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_COUNTER_WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_COUNTER_WIDTH}

set _session_group_133 $_session_group_131|
append _session_group_133 uareceive
gui_sg_create "$_session_group_133"
set Group1|uareceive "$_session_group_133"

gui_sg_addsignal -group "$_session_group_133" { echo_testbench.CPU.on_chip_uart.uareceive.SAMPLE_TIME echo_testbench.CPU.on_chip_uart.uareceive.has_byte echo_testbench.CPU.on_chip_uart.uareceive.rx_running echo_testbench.CPU.on_chip_uart.uareceive.BAUD_RATE echo_testbench.CPU.on_chip_uart.uareceive.reset echo_testbench.CPU.on_chip_uart.uareceive.bit_counter echo_testbench.CPU.on_chip_uart.uareceive.CLOCK_FREQ echo_testbench.CPU.on_chip_uart.uareceive.data_out echo_testbench.CPU.on_chip_uart.uareceive.sample echo_testbench.CPU.on_chip_uart.uareceive.data_out_ready echo_testbench.CPU.on_chip_uart.uareceive.symbol_edge echo_testbench.CPU.on_chip_uart.uareceive.CLOCK_COUNTER_WIDTH echo_testbench.CPU.on_chip_uart.uareceive.clock_counter echo_testbench.CPU.on_chip_uart.uareceive.clk echo_testbench.CPU.on_chip_uart.uareceive.start echo_testbench.CPU.on_chip_uart.uareceive.data_out_valid echo_testbench.CPU.on_chip_uart.uareceive.rx_shift echo_testbench.CPU.on_chip_uart.uareceive.SYMBOL_EDGE_TIME echo_testbench.CPU.on_chip_uart.uareceive.serial_in }
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.SAMPLE_TIME}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.SAMPLE_TIME}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.BAUD_RATE}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.BAUD_RATE}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.CLOCK_FREQ}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.CLOCK_FREQ}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.CLOCK_COUNTER_WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.CLOCK_COUNTER_WIDTH}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.SYMBOL_EDGE_TIME}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uareceive.SYMBOL_EDGE_TIME}

gui_sg_move "$_session_group_133" -after "$_session_group_131" -pos 2 

set _session_group_134 $_session_group_131|
append _session_group_134 controls
gui_sg_create "$_session_group_134"
set Group1|controls "$_session_group_134"

gui_sg_addsignal -group "$_session_group_134" { echo_testbench.CPU.controls.clk echo_testbench.CPU.controls.inst echo_testbench.CPU.controls.ex_inst_reg echo_testbench.CPU.controls.mem_wb_inst_reg echo_testbench.CPU.controls.data_in_ready echo_testbench.CPU.controls.data_in_valid echo_testbench.CPU.controls.ALU_out_mem echo_testbench.CPU.controls.data_out_ready echo_testbench.CPU.controls.FA_1 echo_testbench.CPU.controls.FA_2 echo_testbench.CPU.controls.FB_1 echo_testbench.CPU.controls.data_out_valid echo_testbench.CPU.controls.FB_2 echo_testbench.CPU.controls.MMapSel echo_testbench.CPU.controls.MMap_DMem_Sel }

gui_sg_move "$_session_group_134" -after "$_session_group_131" -pos 1 

set _session_group_135 Group2
gui_sg_create "$_session_group_135"
set Group2 "$_session_group_135"

gui_sg_addsignal -group "$_session_group_135" { echo_testbench.CPU.data_in echo_testbench.CPU.data_out echo_testbench.CPU.data_out_valid echo_testbench.CPU.rst echo_testbench.CPU.data_in_valid echo_testbench.CPU.data_out_ready echo_testbench.CPU.data_in_ready }

set _session_group_136 ALU
gui_sg_create "$_session_group_136"
set ALU "$_session_group_136"

gui_sg_addsignal -group "$_session_group_136" { echo_testbench.CPU.ALU.op1 echo_testbench.CPU.ALU.op2 echo_testbench.CPU.ALU.sel echo_testbench.CPU.ALU.res }

set _session_group_137 wb_mux
gui_sg_create "$_session_group_137"
set wb_mux "$_session_group_137"

gui_sg_addsignal -group "$_session_group_137" { echo_testbench.CPU.wb_mux.sel echo_testbench.CPU.wb_mux.s0 echo_testbench.CPU.wb_mux.s1 echo_testbench.CPU.wb_mux.s2 echo_testbench.CPU.wb_mux.out }

set _session_group_138 mmap_mem_1
gui_sg_create "$_session_group_138"
set mmap_mem_1 "$_session_group_138"

gui_sg_addsignal -group "$_session_group_138" { echo_testbench.CPU.mmap_mem.MMap_dout echo_testbench.CPU.mmap_mem.inst_counter echo_testbench.CPU.mmap_mem.cycle_counter echo_testbench.CPU.mmap_mem.data_in_ready echo_testbench.CPU.mmap_mem.MMap_Sel echo_testbench.CPU.mmap_mem.clk echo_testbench.CPU.mmap_mem.data_out_valid echo_testbench.CPU.mmap_mem.rst }

set _session_group_139 MMap_DMem_mux
gui_sg_create "$_session_group_139"
set MMap_DMem_mux "$_session_group_139"

gui_sg_addsignal -group "$_session_group_139" { echo_testbench.CPU.MMap_DMem_mux.sel echo_testbench.CPU.MMap_DMem_mux.s0 echo_testbench.CPU.MMap_DMem_mux.s1 echo_testbench.CPU.MMap_DMem_mux.s2 echo_testbench.CPU.MMap_DMem_mux.out }

set _session_group_140 rf
gui_sg_create "$_session_group_140"
set rf "$_session_group_140"

gui_sg_addsignal -group "$_session_group_140" { echo_testbench.CPU.rf.clk echo_testbench.CPU.rf.we echo_testbench.CPU.rf.ra1 echo_testbench.CPU.rf.ra2 echo_testbench.CPU.rf.wa echo_testbench.CPU.rf.wd echo_testbench.CPU.rf.rd1 echo_testbench.CPU.rf.rd2 echo_testbench.CPU.rf.ex_wa echo_testbench.CPU.rf.wb_wa echo_testbench.CPU.rf.i echo_testbench.CPU.rf.registers }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 1430000



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {UnnamedProcess 1} {Function 1} {Block 1} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {PowSwitch 0} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {IsoCell 0} {ClassDef 1} }
gui_list_set_filter -id ${Hier.1} -text {*} -force
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_expand -id ${Hier.1} echo_testbench}
catch {gui_list_expand -id ${Hier.1} echo_testbench.CPU}
catch {gui_list_select -id ${Hier.1} {echo_testbench.CPU.rf}}
gui_view_scroll -id ${Hier.1} -vertical -set 149
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {echo_testbench.CPU.rf}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 149
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active echo_testbench /home/cc/eecs151/fa19/class/eecs151-abm/fa19_team28/hardware/sim/echo_testbench.v
gui_view_scroll -id ${Source.1} -vertical -set 30
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_wv_zoom_timerange -id ${Wave.1} 1269692 1683389
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_list_add_group -id ${Wave.1}  -after Group1 {Group1|uatransmit}
gui_list_add_group -id ${Wave.1}  -after Group1 {Group1|controls}
gui_list_add_group -id ${Wave.1}  -after Group1 {Group1|uareceive}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group2}
gui_list_add_group -id ${Wave.1} -after {New Group} {ALU}
gui_list_add_group -id ${Wave.1} -after {New Group} {wb_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {mmap_mem_1}
gui_list_add_group -id ${Wave.1} -after {New Group} {MMap_DMem_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {rf}
gui_list_collapse -id ${Wave.1} Group1|uareceive
gui_list_collapse -id ${Wave.1} Group2
gui_list_collapse -id ${Wave.1} ALU
gui_list_collapse -id ${Wave.1} mmap_mem_1
gui_list_collapse -id ${Wave.1} MMap_DMem_mux
gui_list_select -id ${Wave.1} {echo_testbench.CPU.controls.MMapSel }
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group Group1|controls  -item {echo_testbench.CPU.controls.mem_wb_inst_reg[31:0]} -position below

gui_marker_move -id ${Wave.1} {C1} 1430000
gui_view_scroll -id ${Wave.1} -vertical -set 473
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

