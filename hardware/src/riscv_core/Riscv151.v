module Riscv151 #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 115_200
)(
    input clk,
    input rst,
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX,
    input [2:0] clean_buttons,
    input [1:0] switches,
    output [5:0] leds,
    input clk_rx,
    input pwm_rst,
    output square_wave_out
);

    // Finish wiring modules
    // Set PC size to same bit width as imem and biosmem
    wire BrEq_signal;
    wire BrLT_signal;
    wire [1:0] PCSel_signal;
    wire InstSel_signal;
    wire RegWrEn_signal;
    wire [2:0] ImmSel_signal;
    wire BrUn_signal;
    wire ASel_signal;
    wire BSel_signal;
    wire [3:0] ALUSel_signal;
    wire MemRW_signal;
    wire [1:0] WBSel_signal;
    wire CSREn_signal;
    wire CSRSel_signal;
    wire FA_1_signal;
    wire FB_1_signal;
    wire FA_2_signal;
    wire FB_2_signal;
    wire [2:0] LdSel_signal;
    wire [1:0] SSel_signal;


    // IO Wires
    wire [7:0] data_in;
    wire [7:0] data_out;
    wire data_in_valid;
    wire data_out_ready;
    wire data_in_ready;
    wire data_out_valid;

    wire [2:0] MMapSel_signal;

    wire [31:0] inst;
    wire [31:0] ALU_out;

    reg [7:0] data_out_reg;

    controller #(.RESET_PC(RESET_PC)) controls(
      .rst(rst),
      .clk(clk),
      .inst(inst),
      .BrEq(BrEq_signal),
      .BrLt(BrLT_signal),
      .ALU_out(ALU_out),
      .PCSel(PCSel_signal),
      .InstSel(InstSel_signal),
      .RegWrEn(RegWrEn_signal),
      .ImmSel(ImmSel_signal),
      .BrUn(BrUn_signal),
      .BSel(BSel_signal),
      .ASel(ASel_signal),
      .ALUSel(ALUSel_signal),
      .CSREn(CSREn_signal),
      .CSRSel(CSRSel_signal),
      .MemRW(MemRW_signal),
      .WBSel(WBSel_signal),
      .FA_1(FA_1_signal),
      .FB_1(FB_1_signal),
      .FA_2(FA_2_signal),
      .FB_2(FB_2_signal),
      .LdSel(LdSel_signal),
      .SSel(SSel_signal),
      .MMapSel(MMapSel_signal),
      .data_out_ready(data_out_ready),
      .data_in_valid(data_in_valid)
    );

    wire [31:0] imem_dina, imem_doutb;
    wire [31:0] imem_addra;
    wire [3:0] imem_wea;
    wire imem_ena;

    //Wire for pipeline register at IF
    wire [31:0] PC_next_d;
    wire [31:0] PC_next_q;

    imem imem (
      .clk(clk),
      .ena(imem_ena),
      .wea(imem_wea),
      .addra(imem_addra[15:2]),
      .dina(imem_dina),
      .addrb(PC_next_d[15:2]),
      .doutb(imem_doutb)
    );


    //Pipeline register at IF
    d_ff #(.RESET_PC(RESET_PC)) PC_if_ff (
        .d(PC_next_d),
        .clk(clk),
        .rst(rst),
        .q(PC_next_q)
    );

    wire [31:0] pc_plus_4;

    pc_addr pc_plus_four (
        .PC(PC_next_q),
        .PC_out(pc_plus_4)
    );

    threeonemux PCSel_mux (
        .sel(PCSel_signal),
        .s0(pc_plus_4),
        .s1(ALU_out),
        .s2(PC_next_q),
        .out(PC_next_d)
    );

    wire [31:0] bios_addra;
    wire [31:0] bios_douta, bios_doutb;
    wire bios_ena, bios_enb;
    // Set Bios ena and enb to 1 when PC and Addr is 4'b0100 respectively
    assign bios_ena = PC_next_d[31:28] == 4'b0100 ? 1'b1 : 1'b0;
    assign bios_enb = ALU_out[31:28] == 4'b0100 ? 1'b1 : 1'b0;
    bios_mem bios_mem (
      .clk(clk),
      .ena(bios_ena),
      .addra(PC_next_d[13:2]),
      .douta(bios_douta),
      .enb(bios_enb),
      .addrb(ALU_out[13:2]),
      .doutb(bios_doutb)
    );

    wire [31:0] pc_inst_30;
    twoonemux PC30InstSel_mux (
        .sel(PC_next_q[30]),
        .s0(imem_doutb),
        .s1(bios_douta),
        .out(pc_inst_30)
    );

    twoonemux InstSel_mux (
        .sel(InstSel_signal),
        .s0(pc_inst_30),
        .s1(32'h00000013),
        .out(inst)
    );

    wire [31:0] wd;
    wire [31:0] rd1, rd2;
    reg_file rf (
        .clk(clk),
        .we(RegWrEn_signal),
        .ra1(inst[19:15]), .ra2(inst[24:20]), .wa(inst[11:7]),
        .wd(wd),
        .rd1(rd1), .rd2(rd2)
    );

    wire [31:0] imm_out;
    imm_gen imm_gen(
        .inst_in(inst[31:7]),
        .imm_sel(ImmSel_signal),
        .imm_out(imm_out)
    );

    /********************* MUXES BEFORE PIPELINE REGISTER **********************/

    wire [31:0] FA_1_out;
    wire [31:0] FB_1_out;

    twoonemux FA_1_mux (
        .sel(FA_1_signal),
        .s0(rd1),
        .s1(wd),
        .out(FA_1_out)
    );

    twoonemux FB_1_mux (
        .sel(FB_1_signal),
        .s0(rd2),
        .s1(wd),
        .out(FB_1_out)
    );

    /********************* Before second pipeline register is implemented above *******************/

    // Pipeline Registers IF/D -> Ex Stage
    wire [31:0] csrwi_ex_wire;
    d_ff #(.RESET_PC(RESET_PC)) csrwi_ex_ff (
        .d( {{27{1'b0}}, inst[19:15]} ),
        .clk(clk),
        .rst(rst),
        .q(csrwi_ex_wire)
    );

    wire [31:0] PC_plus_4_ex;
    d_ff #(.RESET_PC(RESET_PC)) PC_plus_4_ex_ff (
        .d(pc_plus_4),
        .clk(clk),
        .rst(rst),
        .q(PC_plus_4_ex)
    );

    wire [31:0] PC_Asel_ex;
    d_ff #(.RESET_PC(RESET_PC)) PC_ex_ff (
        .d(PC_next_q),
        .clk(clk),
        .rst(rst),
        .q(PC_Asel_ex)
    );

    wire [31:0] rd1_ex;
    d_ff #(.RESET_PC(RESET_PC)) rs1_ex_ff (
        .d(FA_1_out),
        .clk(clk),
        .rst(rst),
        .q(rd1_ex)
    );

    wire [31:0] rd2_ex;
    d_ff #(.RESET_PC(RESET_PC)) rs2_ex_ff (
        .d(FB_1_out),
        .clk(clk),
        .rst(rst),
        .q(rd2_ex)
    );

    wire [31:0] imm_gen_ex;
    d_ff #(.RESET_PC(RESET_PC)) imm_gen_ex_ff (
        .d(imm_out),
        .clk(clk),
        .rst(rst),
        .q(imm_gen_ex)
    );

    /******************************* All pipeline register between IF and EX above ********************************/
    wire [31:0] FA_2_out;
    wire [31:0] FB_2_out;

    twoonemux FA_2_mux (
        .sel(FA_2_signal),
        .s0(rd1_ex),
        .s1(wd),
        .out(FA_2_out)
    );

    twoonemux FB_2_mux (
        .sel(FB_2_signal),
        .s0(rd2_ex),
        .s1(wd),
        .out(FB_2_out)
    );

    /******************************* FA_2 and FB_2 above ********************************/

    wire [31:0] CSReg_in;
    twoonemux CSRSel_mux (
        .sel(CSRSel_signal),
        .s0(FA_2_out),
        .s1(csrwi_ex_wire),
        .out(CSReg_in)
    );

    reg [31:0] CSRW_register;
    always @(posedge clk) begin
        if (rst)
            CSRW_register <= 0;
        else if (CSREn_signal)
            CSRW_register <= CSReg_in;
    end

    branch_comp branch_compar (
        .ra1(FA_2_out),
        .ra2(FB_2_out),
        .BrUn(BrUn_signal),
        .BrEq(BrEq_signal),
        .BrLT(BrLT_signal)
    );

    wire [31:0] Asel_out;
    twoonemux Asel_mux(
        .sel(ASel_signal),
        .s0(FA_2_out),
        .s1(PC_Asel_ex),
        .out(Asel_out));

    wire [31:0] Bsel_out;
    twoonemux Bsel_mux(
        .sel(BSel_signal),
        .s0(FB_2_out),
        .s1(imm_gen_ex),
        .out(Bsel_out));

    alu ALU (
        .op1(Asel_out),
        .op2(Bsel_out),
        .sel(ALUSel_signal),
        .res(ALU_out)
    );

    wire [3:0] dmem_we;
    wire [31:0] dmem_din;
    s_sel ssel(
        .sel(SSel_signal),
        .offset(ALU_out[1:0]),
        .rs2(FB_2_out),
        .dmem_we(dmem_we),
        .dmem_din(dmem_din)
    );

    /*********** everything before MEM stage is implemented above ***********/

    // On-chip UART
    assign data_in = FB_2_out[7:0];

    wire [31:0] mmap_dout;
    wire [2:0] fifo_buttons;
    wire [31:0] mmap_or_fifo_buttons;
    mmap_mem #(
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) mmap_mem (
        .clk(clk),
        .rst(rst),
        .en(ALU_out[31]),                    // Read/Write Enable, address MSB == 1
        .addr(ALU_out[15:0]),                // Lower 16 bits of mmap address
        .MMap_Sel(MMapSel_signal),           // MMap Control Signal, nop counting, etc
        .MMap_dout(mmap_dout),               // Output of MMAP_MEM

        // On chip UART ports
        .data_in(data_in),                     // data_in := FB_2_out[7:0], transmit to offchip UART from CPU
        .data_in_valid(data_in_valid),         // Memory Mapped IO Write Val, set by store @ 0x8000_0008
        .data_out_ready(data_out_ready),       // Memory Mapped IO Write En, set by load @ 0x8000_0004
        .serial_in(FPGA_SERIAL_RX),

        .data_in_ready(data_in_ready),          // 0x8000_0000 bit 0
        .data_out(data_out),                    // Memory Mapped IO Read Val, receive from offchip UART to CPU
        .data_out_valid(data_out_valid),        // 0x8000_0000 bit 1
        .serial_out(FPGA_SERIAL_TX),

        // User I/O
        .leds(leds),
        .data(dmem_din),
        .switches(switches),
        .buttons(clean_buttons),
        .fifo_buttons(fifo_buttons),

        // PWM Integration
        .clk_rx(clk_rx),
        .pwm_rst(pwm_rst),
        .square_wave_out(square_wave_out)
    );

    // Add condition to dmem read and write
    wire dmem_memrw;
    assign dmem_memrw = (ALU_out[31:28] == 4'b0011 || ALU_out[31:28] == 4'b0001) ? MemRW_signal : 0 ;

    wire [31:0] dmem_dout;
    dmem dmem (
        .clk(clk),
        .en(dmem_memrw),
        .we(dmem_we),
        .addr(ALU_out[15:2]),
        .din(dmem_din),
        .dout(dmem_dout)
    );

    // imem only enables write when pc_30 is 1 (the pc at mem stage)
    // and ALU out address is 001x, controller needs to be modify
    // ALU_out[31:28] === 4'b001x
    // Since ALU_out[31:28] are never 001x; the condition is never true.
    assign imem_wea = (PC_Asel_ex[30] == 1 && (ALU_out[31:28] == 4'b0010 || ALU_out[31:28] == 4'b0011)) ? dmem_we : 4'b0000;
    assign imem_ena = (PC_Asel_ex[30] == 1 && (ALU_out[31:28] == 4'b0010 || ALU_out[31:28] == 4'b0011)) ? 1 : 0;

    assign imem_addra = ALU_out;
    assign imem_dina = dmem_din;

    wire [31:0] alu_mem;
    d_ff #(.RESET_PC(RESET_PC)) alu_mem_ff (
        .d(ALU_out),
        .clk(clk),
        .rst(rst),
        .q(alu_mem)
    );

    assign mmap_or_fifo_buttons = (alu_mem == 32'h80000024) ? {29'd0, fifo_buttons} : mmap_dout;

    wire [31:0] bios_dmem_mmap_out;
    wire [1:0] bios_dmem_mmap_sel_signal;
    assign bios_dmem_mmap_sel_signal = alu_mem[31] == 1'b1 ? 2'b10 : {1'b0, alu_mem[30]};
    threeonemux BIOS_DMEM_MMAP_MUX (
        .sel(bios_dmem_mmap_sel_signal),
        .s0(dmem_dout),
        .s1(bios_doutb),
        .s2(mmap_or_fifo_buttons),
        .out(bios_dmem_mmap_out));

    wire [31:0] pc_plus_4_mem;
    d_ff #(.RESET_PC(RESET_PC)) pc_plus_4_mem_ff (
        .d(PC_plus_4_ex),
        .clk(clk),
        .rst(rst),
        .q(pc_plus_4_mem)
    );

    /********************* Finish define elements of MEM stage ***********************/

    wire [31:0] ld_out;
    ld_sel ld(
        .sel(LdSel_signal),
        .din(bios_dmem_mmap_out),
        .offset({{3{1'b0}}, alu_mem[1:0]}), //getting it from instruction after mem stage
        .dout(ld_out)
    );

    threeonemux wb_mux(
      .sel(WBSel_signal),
      .s0(ld_out),
      .s1(alu_mem),
      .s2(pc_plus_4_mem),
      .out(wd)
    );

endmodule
