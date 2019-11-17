module Riscv151 #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000
)(
    input clk,
    input rst,
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);

    wire [31:0] imem_dina, imem_doutb;
    wire [31:0] imem_addra, imem_addrb;
    wire [3:0] imem_wea;
    wire imem_ena;
    // Remove the comment at step 9
    // imem imem (
    //   .clk(clk),
    //   .ena(imem_ena),
    //   .wea(imem_wea),
    //   .addra(imem_addra[13:0]),
    //   .dina(imem_dina),
    //   .addrb(imem_addrb[13:0]),
    //   .doutb(imem_doutb)
    // );


    // Finish wiring modules
    // Set PC size to same bit width as imem and biosmem
    wire BrEq_signal;
    wire BrLT_signal;
    wire PCSel_signal;
    wire [1:0] InstSel_signal;
    wire RegWrEn_signal;
    wire [2:0] ImmSel_signal;
    wire BrUn_signal;
    wire ASel_signal;
    wire BSel_signal;
    wire [3:0] ALUSel_signal;
    wire MemRW_signal;
    wire [1:0] WBSel_signal;
    wire FA_1_signal;
    wire FB_1_signal;
    wire FA_2_signal;
    wire FB_2_signal;
    wire [2:0] LdSel_signal;
    wire [1:0] SSel_signal;

    wire [31:0] inst;

    controller controls(
      .rst(),
      .clk(clk),
      .inst(inst),
      .BrEq(BrEq_signal),
      .BrLt(BrLT_signal),
      .PCSel(PCSel_signal),
      .InstSel(InstSel_signal),
      .RegWrEn(RegWrEn_signal),
      .ImmSel(ImmSel_signal),
      .BrUn(BrUn_signal),
      .BSel(BSel_signal),
      .ASel(ASel_signal),
      .ALUSel(ALUSel_signal),
      .MemRW(MemRW_signal),
      .WBSel(WBSel_signal),
      .FA_1(),
      .FB_1(),
      .FA_2(),
      .FB_2(),
      .LdSel(LdSel_signal),
      .SSel(SSel_signal)
    );

    //Wire for pipeline register at IF
    wire [31:0] PC_next_d;
    wire [31:0] PC_next_q;

    wire [31:0] PC_next_addr;

    //might be buggy
    assign PC_next_addr = rst ? 0 : PC_next_d;

    //Pipeline register at IF
    d_ff PC_if_ff (
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

    wire [31:0] ALU_out;

    // Can we parametrize the bit width of the mux
    twoonemux PCSel_mux (
        .sel(PCSel_signal),
        .s0(pc_plus_4),
        .s1(ALU_out),
        .out(PC_next_d)
    );

    wire [31:0] bios_addra, bios_addrb;
    wire [31:0] bios_douta, bios_doutb;
    wire bios_ena, bios_enb;
    assign bios_ena = 1;
    bios_mem bios_mem (
      .clk(clk),
      .ena(bios_ena),
      .addra(PC_next_addr[13:2]),
      .douta(bios_douta),
      .enb(bios_enb),
      .addrb(bios_addrb[13:2]),
      .doutb(bios_doutb)
    );

    threeonemux InstSel_mux (
        .sel(InstSel_signal),
        .s0(imem_douta),
        .s1(bios_douta),
        .s2(32'h00000013),
        .out(inst)
    );

    // Construct your datapath, add as many modules as you want
    // wire we;
    // wire [4:0] ra1, ra2, wa;
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

    /********************* Before second pipeline register is implemented above *******************/

    // Pipeline Registers IF/D -> Ex Stage
    // PC+4, PC, DataA, DataB, Imm
    // PC+4 and PC, are both of width: `PC_BUS_WIDTH,
    // They should be zero extended before being used
    // PC => ALU, PC+4 => WB/Regfile
    wire [31:0] PC_plus_4_ex;
    d_ff PC_plus_4_ex_ff (
        .d(PC_plus_4),
        .clk(clk),
        .rst(rst),
        .q(PC_plus_4_ex)
    );

    wire [31:0] PC_Asel_ex;
    d_ff PC_ex_ff (
        .d(PC_next_q),
        .clk(clk),
        .rst(rst),
        .q(PC_Asel_ex)
    );

    wire [31:0] rd1_ex;
    d_ff rs1_ex_ff (
        .d(rd1),
        .clk(clk),
        .rst(rst),
        .q(rd1_ex)
    );

    wire [31:0] rd2_ex;
    d_ff rs2_ex_ff (
        .d(rd2),
        .clk(clk),
        .rst(rst),
        .q(rd2_ex)
    );

    wire [31:0] imm_gen_ex;
    d_ff imm_gen_ex_ff (
        .d(imm_out),
        .clk(clk),
        .rst(rst),
        .q(imm_gen_ex)
    );

    /******************************* All pipeline register between IF and EX above ********************************/

    branch_comp branch_compar (
        .ra1(rd1_ex),
        .ra2(rd2_ex),
        .BrUn(BrUn_signal),
        .BrEq(BrEq_signal),
        .BrLT(BrLT_signal)
    );

    wire [31:0] Asel_out;
    twoonemux Asel_mux(
        .sel(ASel_signal),
        .s0(rd1_ex),
        .s1(PC_Asel_ex),
        .out(Asel_out));

    wire [31:0] Bsel_out;
    twoonemux Bsel_mux(
        .sel(BSel_signal),
        .s0(rd2_ex),
        .s1(imm_gen_ex),
        .out(Bsel_out));

    alu ALU (
        .op1(Asel_out),
        .op2(Bsel_out),
        .sel(ALUSel_signal),
        .res(ALU_out)
    );

    wire [3:0] dmem_we;
    s_sel ssel(
        .sel(SSel_signal),
        .offset(ALU_out[1:0]),
        .rs2(rd2_ex),
        .dmem_we(dmem_we),
        .dmem_din(dmem_din)
    );

    /*********** everything before MEM stage is implemented above ***********/

    wire [31:0] dmem_din, dmem_dout;
    dmem dmem (
      .clk(clk),
      .en(MemRW_signal),
      .we(dmem_we),
      .addr(ALU_out[15:2]),
      .din(dmem_din),
      .dout(dmem_dout)
    );

    wire [31:0] alu_mem;
    d_ff alu_mem_ff (
        .d(ALU_out),
        .clk(clk),
        .rst(rst),
        .q(alu_mem)
    );

    wire [31:0] pc_plus_4_mem;
    d_ff pc_plus_4_mem_ff (
        .d(PC_plus_4_ex),
        .clk(clk),
        .rst(rst),
        .q(pc_plus_4_mem)
    );

    /********************* Finish define elements of MEM stage ***********************/

    wire [31:0] ld_out;
    ld_sel ld(
        .sel(LdSel_signal),
        .din(dmem_dout),
        .offset(alu_mem[1:0]), //getting it from instruction after mem stage
        .dout(ld_out)
    );

    threeonemux wb_mux(
      .sel(WBSel_signal),
      .s0(ld_out),
      .s1(alu_mem),
      .s2(pc_plus_4_mem),
      .out(wd)
    );

    // On-chip UART
    // uart #(
    //     .CLOCK_FREQ(CPU_CLOCK_FREQ)
    // ) on_chip_uart (
    //     .clk(clk),
    //     .reset(rst),
    //     .data_in(),
    //     .data_in_valid(),
    //     .data_out_ready(),
    //     .serial_in(FPGA_SERIAL_RX),
    //
    //     .data_in_ready(),
    //     .data_out(),
    //     .data_out_valid(),
    //     .serial_out(FPGA_SERIAL_TX)
    // );
endmodule
