# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Thu Nov 21 18:03:04 2019
# Designs open: 1
#   V1: /home/cc/eecs151/fa19/class/eecs151-abm/fa19_team28/hardware/sim/echo_testbench.vpd
# Toplevel windows open: 1
# 	TopLevel.2
#   Wave.1: 177 signals
#   Group count = 20
#   Group ALU signal count = 4
#   Group Asel_mux signal count = 4
#   Group Bsel_mux signal count = 4
#   Group FA_1_mux signal count = 4
#   Group FA_2_mux signal count = 4
#   Group FB_1_mux signal count = 4
#   Group FB_2_mux signal count = 4
#   Group InstSel_mux signal count = 5
#   Group MMap_DMem_mux signal count = 4
#   Group PCSel_mux signal count = 5
#   Group alu_mem_ff signal count = 5
#   Group controls signal count = 36
#   Group dmem signal count = 6
#   Group mmap_mem signal count = 17
#   Group on_chip_uart signal count = 15
#   Group rf signal count = 11
#   Group wb_mux signal count = 5
#   Group uatransmit signal count = 13
#   Group off_chip_uart signal count = 16
# End_DVE_Session_Save_Info

# DVE version: G-2012.09
# DVE build date: Aug 24 2012 00:30:46


#<Session mode="Full" path="/home/cc/eecs151/fa19/class/eecs151-abm/fa19_team28/hardware/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE Topleve session: 


# Create and position top-level windows :TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{43 55} {1666 986}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_set_toolbar_attributes -toolbar {&File} -dock_state top
gui_set_toolbar_attributes -toolbar {&File} -offset 0
gui_show_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_set_toolbar_attributes -toolbar {BackTrace} -dock_state top
gui_set_toolbar_attributes -toolbar {BackTrace} -offset 0
gui_show_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 471} {child_wave_right 1147} {child_wave_colname 241} {child_wave_colvalue 226} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) none
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) none
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.2}

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
gui_bus_create -name EXP:uart_rcv {{echo_testbench.CPU.mmap_mem.UART_recv[7]} {echo_testbench.CPU.mmap_mem.UART_recv[6]} {echo_testbench.CPU.mmap_mem.UART_recv[5]} {echo_testbench.CPU.mmap_mem.UART_recv[4]} {echo_testbench.CPU.mmap_mem.UART_recv[3]} {echo_testbench.CPU.mmap_mem.UART_recv[2]} {echo_testbench.CPU.mmap_mem.UART_recv[1]} {echo_testbench.CPU.mmap_mem.UART_recv[0]}}
gui_bus_create -name EXP:uart_recv {{echo_testbench.CPU.mmap_mem.UART_recv[7]} {echo_testbench.CPU.mmap_mem.UART_recv[6]} {echo_testbench.CPU.mmap_mem.UART_recv[5]} {echo_testbench.CPU.mmap_mem.UART_recv[4]} {echo_testbench.CPU.mmap_mem.UART_recv[3]} {echo_testbench.CPU.mmap_mem.UART_recv[2]} {echo_testbench.CPU.mmap_mem.UART_recv[1]} {echo_testbench.CPU.mmap_mem.UART_recv[0]}}
gui_bus_create -name EXP:uart_rx {{echo_testbench.CPU.mmap_mem.UART_recv[6]} {echo_testbench.CPU.mmap_mem.UART_recv[5]} {echo_testbench.CPU.mmap_mem.UART_recv[4]} {echo_testbench.CPU.mmap_mem.UART_recv[3]} {echo_testbench.CPU.mmap_mem.UART_recv[2]} {echo_testbench.CPU.mmap_mem.UART_recv[1]} {echo_testbench.CPU.mmap_mem.UART_recv[0]}}

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {echo_testbench.CPU.Asel_mux}
gui_load_child_values {echo_testbench.CPU.FB_2_mux}
gui_load_child_values {echo_testbench.CPU.FB_1_mux}
gui_load_child_values {echo_testbench.CPU.PCSel_mux}
gui_load_child_values {echo_testbench.CPU.alu_mem_ff}
gui_load_child_values {echo_testbench.off_chip_uart}
gui_load_child_values {echo_testbench.CPU.FA_2_mux}
gui_load_child_values {echo_testbench.CPU.ALU}
gui_load_child_values {echo_testbench.CPU.on_chip_uart}
gui_load_child_values {echo_testbench.CPU.FA_1_mux}
gui_load_child_values {echo_testbench.CPU.mmap_mem}
gui_load_child_values {echo_testbench.CPU.MMap_DMem_mux}
gui_load_child_values {echo_testbench.CPU.InstSel_mux}
gui_load_child_values {echo_testbench.CPU.on_chip_uart.uatransmit}
gui_load_child_values {echo_testbench.CPU.controls}
gui_load_child_values {echo_testbench.CPU.Bsel_mux}
gui_load_child_values {echo_testbench.CPU.wb_mux}


set _session_group_242 ALU
gui_sg_create "$_session_group_242"
set ALU "$_session_group_242"

gui_sg_addsignal -group "$_session_group_242" { echo_testbench.CPU.ALU.op1 echo_testbench.CPU.ALU.op2 echo_testbench.CPU.ALU.sel echo_testbench.CPU.ALU.res }

set _session_group_243 Asel_mux
gui_sg_create "$_session_group_243"
set Asel_mux "$_session_group_243"

gui_sg_addsignal -group "$_session_group_243" { echo_testbench.CPU.Asel_mux.sel echo_testbench.CPU.Asel_mux.s0 echo_testbench.CPU.Asel_mux.s1 echo_testbench.CPU.Asel_mux.out }

set _session_group_244 Bsel_mux
gui_sg_create "$_session_group_244"
set Bsel_mux "$_session_group_244"

gui_sg_addsignal -group "$_session_group_244" { echo_testbench.CPU.Bsel_mux.sel echo_testbench.CPU.Bsel_mux.s0 echo_testbench.CPU.Bsel_mux.s1 echo_testbench.CPU.Bsel_mux.out }

set _session_group_245 FA_1_mux
gui_sg_create "$_session_group_245"
set FA_1_mux "$_session_group_245"

gui_sg_addsignal -group "$_session_group_245" { echo_testbench.CPU.FA_1_mux.sel echo_testbench.CPU.FA_1_mux.s0 echo_testbench.CPU.FA_1_mux.s1 echo_testbench.CPU.FA_1_mux.out }

set _session_group_246 FA_2_mux
gui_sg_create "$_session_group_246"
set FA_2_mux "$_session_group_246"

gui_sg_addsignal -group "$_session_group_246" { echo_testbench.CPU.FA_2_mux.sel echo_testbench.CPU.FA_2_mux.s0 echo_testbench.CPU.FA_2_mux.s1 echo_testbench.CPU.FA_2_mux.out }

set _session_group_247 FB_1_mux
gui_sg_create "$_session_group_247"
set FB_1_mux "$_session_group_247"

gui_sg_addsignal -group "$_session_group_247" { echo_testbench.CPU.FB_1_mux.sel echo_testbench.CPU.FB_1_mux.s0 echo_testbench.CPU.FB_1_mux.s1 echo_testbench.CPU.FB_1_mux.out }

set _session_group_248 FB_2_mux
gui_sg_create "$_session_group_248"
set FB_2_mux "$_session_group_248"

gui_sg_addsignal -group "$_session_group_248" { echo_testbench.CPU.FB_2_mux.sel echo_testbench.CPU.FB_2_mux.s0 echo_testbench.CPU.FB_2_mux.s1 echo_testbench.CPU.FB_2_mux.out }

set _session_group_249 InstSel_mux
gui_sg_create "$_session_group_249"
set InstSel_mux "$_session_group_249"

gui_sg_addsignal -group "$_session_group_249" { echo_testbench.CPU.InstSel_mux.sel echo_testbench.CPU.InstSel_mux.s0 echo_testbench.CPU.InstSel_mux.s1 echo_testbench.CPU.InstSel_mux.s2 echo_testbench.CPU.InstSel_mux.out }

set _session_group_250 MMap_DMem_mux
gui_sg_create "$_session_group_250"
set MMap_DMem_mux "$_session_group_250"

gui_sg_addsignal -group "$_session_group_250" { echo_testbench.CPU.MMap_DMem_mux.sel echo_testbench.CPU.MMap_DMem_mux.s0 echo_testbench.CPU.MMap_DMem_mux.s1 echo_testbench.CPU.MMap_DMem_mux.out }

set _session_group_251 PCSel_mux
gui_sg_create "$_session_group_251"
set PCSel_mux "$_session_group_251"

gui_sg_addsignal -group "$_session_group_251" { echo_testbench.CPU.PCSel_mux.sel echo_testbench.CPU.PCSel_mux.s0 echo_testbench.CPU.PCSel_mux.s1 echo_testbench.CPU.PCSel_mux.s2 echo_testbench.CPU.PCSel_mux.out }

set _session_group_252 alu_mem_ff
gui_sg_create "$_session_group_252"
set alu_mem_ff "$_session_group_252"

gui_sg_addsignal -group "$_session_group_252" { echo_testbench.CPU.alu_mem_ff.d echo_testbench.CPU.alu_mem_ff.clk echo_testbench.CPU.alu_mem_ff.rst echo_testbench.CPU.alu_mem_ff.q echo_testbench.CPU.alu_mem_ff.BUS_WIDTH }
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.alu_mem_ff.BUS_WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.alu_mem_ff.BUS_WIDTH}

set _session_group_253 controls
gui_sg_create "$_session_group_253"
set controls "$_session_group_253"

gui_sg_addsignal -group "$_session_group_253" { }
gui_sg_addsignal -group "$_session_group_253" { Divider } -divider
gui_sg_addsignal -group "$_session_group_253" { echo_testbench.CPU.controls.rst echo_testbench.CPU.controls.clk echo_testbench.CPU.controls.inst echo_testbench.CPU.controls.BrEq echo_testbench.CPU.controls.BrLt echo_testbench.CPU.controls.ALU_out echo_testbench.CPU.controls.ALU_out_mem echo_testbench.CPU.controls.data_out_valid echo_testbench.CPU.controls.data_in_ready echo_testbench.CPU.controls.PCSel echo_testbench.CPU.controls.InstSel echo_testbench.CPU.controls.RegWrEn echo_testbench.CPU.controls.ImmSel echo_testbench.CPU.controls.BrUn echo_testbench.CPU.controls.BSel echo_testbench.CPU.controls.ASel echo_testbench.CPU.controls.ALUSel echo_testbench.CPU.controls.CSREn echo_testbench.CPU.controls.CSRSel echo_testbench.CPU.controls.MemRW echo_testbench.CPU.controls.WBSel echo_testbench.CPU.controls.FA_1 echo_testbench.CPU.controls.FB_1 echo_testbench.CPU.controls.FA_2 echo_testbench.CPU.controls.FB_2 echo_testbench.CPU.controls.LdSel echo_testbench.CPU.controls.SSel echo_testbench.CPU.controls.MMapSel echo_testbench.CPU.controls.MMap_DMem_Sel echo_testbench.CPU.controls.data_out_ready echo_testbench.CPU.controls.data_in_valid echo_testbench.CPU.controls.ex_inst_reg echo_testbench.CPU.controls.mem_wb_inst_reg echo_testbench.CPU.controls.ex_state echo_testbench.CPU.controls.mem_wb_state }

set _session_group_254 dmem
gui_sg_create "$_session_group_254"
set dmem "$_session_group_254"

gui_sg_addsignal -group "$_session_group_254" { echo_testbench.CPU.dmem.clk echo_testbench.CPU.dmem.en echo_testbench.CPU.dmem.we echo_testbench.CPU.dmem.addr echo_testbench.CPU.dmem.din echo_testbench.CPU.dmem.dout }

set _session_group_255 mmap_mem
gui_sg_create "$_session_group_255"
set mmap_mem "$_session_group_255"

gui_sg_addsignal -group "$_session_group_255" { echo_testbench.CPU.mmap_mem.UART_control echo_testbench.CPU.mmap_mem.UART_recv EXP:uart_rcv echo_testbench.CPU.data_out_reg echo_testbench.CPU.mmap_mem.clk echo_testbench.CPU.mmap_mem.rst echo_testbench.CPU.mmap_mem.MMap_Sel echo_testbench.CPU.mmap_mem.data_in_ready echo_testbench.CPU.mmap_mem.data_in_valid echo_testbench.CPU.mmap_mem.data_out_ready echo_testbench.CPU.mmap_mem.data_out_valid echo_testbench.CPU.mmap_mem.IO_mem_din_rx echo_testbench.CPU.mmap_mem.IO_mem_din_tx echo_testbench.CPU.mmap_mem.MMap_dout echo_testbench.CPU.mmap_mem.UART_tx echo_testbench.CPU.mmap_mem.cycle_counter echo_testbench.CPU.mmap_mem.inst_counter }

set _session_group_256 on_chip_uart
gui_sg_create "$_session_group_256"
set on_chip_uart "$_session_group_256"

gui_sg_addsignal -group "$_session_group_256" { echo_testbench.CPU.on_chip_uart.clk echo_testbench.CPU.on_chip_uart.reset echo_testbench.CPU.on_chip_uart.data_in echo_testbench.CPU.on_chip_uart.data_in_valid echo_testbench.CPU.on_chip_uart.data_in_ready echo_testbench.CPU.on_chip_uart.data_out echo_testbench.CPU.on_chip_uart.data_out_valid echo_testbench.CPU.on_chip_uart.data_out_ready echo_testbench.CPU.on_chip_uart.serial_in echo_testbench.CPU.on_chip_uart.serial_out echo_testbench.CPU.on_chip_uart.serial_in_reg echo_testbench.CPU.on_chip_uart.serial_out_reg echo_testbench.CPU.on_chip_uart.serial_out_tx echo_testbench.CPU.on_chip_uart.CLOCK_FREQ echo_testbench.CPU.on_chip_uart.BAUD_RATE }
gui_set_radix -radix {binary} -signals {V1:echo_testbench.CPU.on_chip_uart.data_in}
gui_set_radix -radix {unsigned} -signals {V1:echo_testbench.CPU.on_chip_uart.data_in}
gui_set_radix -radix {binary} -signals {V1:echo_testbench.CPU.on_chip_uart.data_out}
gui_set_radix -radix {unsigned} -signals {V1:echo_testbench.CPU.on_chip_uart.data_out}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.CLOCK_FREQ}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.CLOCK_FREQ}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.BAUD_RATE}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.BAUD_RATE}

set _session_group_257 rf
gui_sg_create "$_session_group_257"
set rf "$_session_group_257"

gui_sg_addsignal -group "$_session_group_257" { echo_testbench.CPU.rf.clk echo_testbench.CPU.rf.we echo_testbench.CPU.rf.ra1 echo_testbench.CPU.rf.ra2 echo_testbench.CPU.rf.wa echo_testbench.CPU.rf.rd1 echo_testbench.CPU.rf.rd2 echo_testbench.CPU.rf.ex_wa echo_testbench.CPU.rf.wb_wa echo_testbench.CPU.rf.i echo_testbench.CPU.rf.registers }

set _session_group_258 wb_mux
gui_sg_create "$_session_group_258"
set wb_mux "$_session_group_258"

gui_sg_addsignal -group "$_session_group_258" { echo_testbench.CPU.wb_mux.sel echo_testbench.CPU.wb_mux.s0 echo_testbench.CPU.wb_mux.s1 echo_testbench.CPU.wb_mux.s2 echo_testbench.CPU.wb_mux.out }

set _session_group_259 uatransmit
gui_sg_create "$_session_group_259"
set uatransmit "$_session_group_259"

gui_sg_addsignal -group "$_session_group_259" { echo_testbench.CPU.on_chip_uart.uatransmit.clk echo_testbench.CPU.on_chip_uart.uatransmit.reset echo_testbench.CPU.on_chip_uart.uatransmit.data_in echo_testbench.CPU.on_chip_uart.uatransmit.data_in_valid echo_testbench.CPU.on_chip_uart.uatransmit.data_in_ready echo_testbench.CPU.on_chip_uart.uatransmit.serial_out echo_testbench.CPU.on_chip_uart.uatransmit.tx_shift echo_testbench.CPU.on_chip_uart.uatransmit.bit_counter echo_testbench.CPU.on_chip_uart.uatransmit.clock_counter echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_FREQ echo_testbench.CPU.on_chip_uart.uatransmit.BAUD_RATE echo_testbench.CPU.on_chip_uart.uatransmit.SYMBOL_EDGE_TIME echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_COUNTER_WIDTH }
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_FREQ}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_FREQ}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.BAUD_RATE}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.BAUD_RATE}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.SYMBOL_EDGE_TIME}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.SYMBOL_EDGE_TIME}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_COUNTER_WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.CPU.on_chip_uart.uatransmit.CLOCK_COUNTER_WIDTH}

set _session_group_260 off_chip_uart
gui_sg_create "$_session_group_260"
set off_chip_uart "$_session_group_260"

gui_sg_addsignal -group "$_session_group_260" { echo_testbench.off_chip_uart.clk echo_testbench.off_chip_uart.reset echo_testbench.off_chip_uart.data_in echo_testbench.off_chip_uart.data_in_valid echo_testbench.off_chip_uart.data_in_ready echo_testbench.off_chip_uart.data_out echo_testbench.off_chip_uart.data_out_valid echo_testbench.off_chip_uart.data_out_ready echo_testbench.off_chip_uart.serial_in echo_testbench.off_chip_uart.serial_out echo_testbench.off_chip_uart.serial_in_reg echo_testbench.off_chip_uart.serial_out_reg echo_testbench.off_chip_uart.serial_out_tx echo_testbench.off_chip_uart.CLOCK_FREQ echo_testbench.off_chip_uart.BAUD_RATE }
gui_set_radix -radix {binary} -signals {V1:echo_testbench.off_chip_uart.data_out}
gui_set_radix -radix {unsigned} -signals {V1:echo_testbench.off_chip_uart.data_out}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.off_chip_uart.CLOCK_FREQ}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.off_chip_uart.CLOCK_FREQ}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.off_chip_uart.BAUD_RATE}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.off_chip_uart.BAUD_RATE}

set _session_group_261 $_session_group_260|
append _session_group_261 uatransmit
gui_sg_create "$_session_group_261"
set off_chip_uart|uatransmit "$_session_group_261"

gui_sg_addsignal -group "$_session_group_261" { echo_testbench.off_chip_uart.uatransmit.clk echo_testbench.off_chip_uart.uatransmit.reset echo_testbench.off_chip_uart.uatransmit.data_in echo_testbench.off_chip_uart.uatransmit.data_in_valid echo_testbench.off_chip_uart.uatransmit.data_in_ready echo_testbench.off_chip_uart.uatransmit.serial_out echo_testbench.off_chip_uart.uatransmit.tx_shift echo_testbench.off_chip_uart.uatransmit.bit_counter echo_testbench.off_chip_uart.uatransmit.clock_counter echo_testbench.off_chip_uart.uatransmit.CLOCK_FREQ echo_testbench.off_chip_uart.uatransmit.BAUD_RATE echo_testbench.off_chip_uart.uatransmit.SYMBOL_EDGE_TIME echo_testbench.off_chip_uart.uatransmit.CLOCK_COUNTER_WIDTH }
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.off_chip_uart.uatransmit.CLOCK_FREQ}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.off_chip_uart.uatransmit.CLOCK_FREQ}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.off_chip_uart.uatransmit.BAUD_RATE}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.off_chip_uart.uatransmit.BAUD_RATE}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.off_chip_uart.uatransmit.SYMBOL_EDGE_TIME}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.off_chip_uart.uatransmit.SYMBOL_EDGE_TIME}
gui_set_radix -radix {decimal} -signals {V1:echo_testbench.off_chip_uart.uatransmit.CLOCK_COUNTER_WIDTH}
gui_set_radix -radix {twosComplement} -signals {V1:echo_testbench.off_chip_uart.uatransmit.CLOCK_COUNTER_WIDTH}

# Global: Highlighting
gui_highlight_signals -color #1e90ff {{echo_testbench.CPU.mmap_mem.UART_recv[4]} {echo_testbench.CPU.mmap_mem.UART_recv[0]} {echo_testbench.CPU.mmap_mem.UART_recv[1]} {echo_testbench.CPU.mmap_mem.UART_recv[2]} {echo_testbench.CPU.mmap_mem.UART_recv[3]} {echo_testbench.CPU.mmap_mem.UART_recv[5]} {echo_testbench.CPU.mmap_mem.UART_recv[7]} {echo_testbench.CPU.mmap_mem.UART_recv[6]}}

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 1065059



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


# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 628425 2161402
gui_list_add_group -id ${Wave.1} -after {New Group} {ALU}
gui_list_add_group -id ${Wave.1} -after {New Group} {Asel_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {Bsel_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {FA_1_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {FA_2_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {FB_1_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {FB_2_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {InstSel_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {MMap_DMem_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {PCSel_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {alu_mem_ff}
gui_list_add_group -id ${Wave.1} -after {New Group} {controls}
gui_list_add_group -id ${Wave.1} -after {New Group} {dmem}
gui_list_add_group -id ${Wave.1} -after {New Group} {mmap_mem}
gui_list_add_group -id ${Wave.1} -after {New Group} {on_chip_uart}
gui_list_add_group -id ${Wave.1} -after {New Group} {rf}
gui_list_add_group -id ${Wave.1} -after {New Group} {wb_mux}
gui_list_add_group -id ${Wave.1} -after {New Group} {uatransmit}
gui_list_add_group -id ${Wave.1} -after {New Group} {off_chip_uart}
gui_list_add_group -id ${Wave.1}  -after off_chip_uart {off_chip_uart|uatransmit}
gui_list_collapse -id ${Wave.1} Asel_mux
gui_list_collapse -id ${Wave.1} Bsel_mux
gui_list_collapse -id ${Wave.1} FA_1_mux
gui_list_collapse -id ${Wave.1} FA_2_mux
gui_list_collapse -id ${Wave.1} FB_1_mux
gui_list_collapse -id ${Wave.1} FB_2_mux
gui_list_collapse -id ${Wave.1} InstSel_mux
gui_list_collapse -id ${Wave.1} MMap_DMem_mux
gui_list_collapse -id ${Wave.1} PCSel_mux
gui_list_collapse -id ${Wave.1} alu_mem_ff
gui_list_collapse -id ${Wave.1} dmem
gui_list_collapse -id ${Wave.1} rf
gui_list_collapse -id ${Wave.1} wb_mux
gui_list_collapse -id ${Wave.1} off_chip_uart
gui_seek_criteria -id ${Wave.1} {Value...}



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
gui_list_set_insertion_bar  -id ${Wave.1} -group off_chip_uart  -position in

gui_marker_move -id ${Wave.1} {C1} 1065059
gui_view_scroll -id ${Wave.1} -vertical -set 1889
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

