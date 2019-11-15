`define PC_BUS_WIDTH 14

module Riscv151 #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000
)(
    input clk,
    input rst,
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);
    // Memories
    wire [11:0] bios_addra, bios_addrb;
    wire [31:0] bios_douta, bios_doutb;
    wire bios_ena, bios_enb;
    bios_mem bios_mem (
      .clk(clk),
      .ena(bios_ena),
      .addra(bios_addra),
      .douta(bios_douta),
      .enb(bios_enb),
      .addrb(bios_addrb),
      .doutb(bios_doutb)
    );

    wire [13:0] dmem_addr;
    wire [31:0] dmem_din, dmem_dout;
    wire [3:0] dmem_we;
    wire dmem_en;
    dmem dmem (
      .clk(clk),
      .en(dmem_en),
      .we(dmem_we),
      .addr(dmem_addr),
      .din(dmem_din),
      .dout(dmem_dout)
    );

    wire [31:0] imem_dina, imem_doutb;
    wire [13:0] imem_addra, imem_addrb;
    wire [3:0] imem_wea;
    wire imem_ena;
    imem imem (
      .clk(clk),
      .ena(imem_ena),
      .wea(imem_wea),
      .addra(imem_addra),
      .dina(imem_dina),
      .addrb(imem_addrb),
      .doutb(imem_doutb)
    );


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
      .BrEq(),
      .BrLt(),
      .PCSel(PCSel_signal),
      .InstSel(InstSel_signal),
      .RegWrEn(RegWrEn_signal),
      .ImmSel(ImmSel_signal),
      .BrUn(),
      .BSel(),
      .ASel(),
      .ALUSel(),
      .MemRW(),
      .WBSel(),
      .FA_1(),
      .FB_1(),
      .FA_2(),
      .FB_2(),
      .LdSel(),
      .SSel()
    );

    // Muxes in IF/D
    wire [31:0] ALU_out;
    wire [`PC_BUS_WIDTH - 1:0] PC_next_d;
    // Can we parametrize the bit width of the mux
    twoonemux PCSel_mux (
        .sel(PCSel_signal),
        .s0(pc_plus_4),
        .s1(ALU_out[`PC_BUS_WIDTH - 1:0]),
        .out(PC_next_d)
    );

    threeonemux InstSel_mux (
        .sel(InstSel_signal),
        .s0(imem_doutb),
        .s1(bios_doutb),
        .s2(32'h00000013),
        .out(inst)
    );

    wire [`PC_BUS_WIDTH - 1:0] PC_next_q;
    assign bios_addra = PC_next_q;
    assign bios_addrb = PC_next_q;
    assign imem_addrb = PC_next_q;
    d_ff #(.BUS_WIDTH(`PC_BUS_WIDTH)) PC_if_ff (
        .d(PC_next_d),
        .clk(clk),
        .rst(),
        .q(PC_next_q)
    );

    wire [`PC_BUS_WIDTH - 1:0] pc_plus_4;
    pc_addr pc_plus_four (
        .PC(PC_next_q),
        .PC_out(pc_plus_4)
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

    // Pipeline Registers IF/D -> Ex Stage
    // PC+4, PC, DataA, DataB, Imm
    // PC+4 and PC, are both of width: `PC_BUS_WIDTH,
    // They should be zero extended before being used
    // PC => ALU, PC+4 => WB/Regfile
    wire [31:0] PC_plus_four_ex;
    assign PC_plus_four_ex[31:`PC_BUS_WIDTH] = 0;
    d_ff #(.BUS_WIDTH(`PC_BUS_WIDTH)) PC_plus_4_ex_ff (
        .d(PC_next_d),
        .clk(clk),
        .rst(),
        .q(PC_plus_four_ex[`PC_BUS_WIDTH - 1: 0])
    );

    // Goes to ASel Mux
    wire [31:0] PC_ASel_ex;
    assign PC_ASel_ex[31:`PC_BUS_WIDTH] = 0;
    d_ff #(.BUS_WIDTH(`PC_BUS_WIDTH)) PC_ex_ff (
        .d(PC_next_q),
        .clk(clk),
        .rst(),
        .q(PC_ASel_ex[`PC_BUS_WIDTH - 1:0])
    );

    wire [31:0] DataA_ex;
    d_ff #(.BUS_WIDTH(32)) DataA_ex_ff (
        .d(rd1),
        .clk(clk),
        .rst(),
        .q(DataA_ex)
    );

    wire [31:0] DataB_ex;
    d_ff #(.BUS_WIDTH(32)) DataB_ex_ff (
        .d(rd2),
        .clk(clk),
        .rst(),
        .q(DataB_ex)
    );

    wire [31:0] Imm_ex;
    d_ff #(.BUS_WIDTH(32)) Imm_ex_ff (
        .d(imm_out),
        .clk(clk),
        .rst(),
        .q(Imm_ex)
    );




    // On-chip UART
    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ)
    ) on_chip_uart (
        .clk(clk),
        .reset(rst),
        .data_in(),
        .data_in_valid(),
        .data_out_ready(),
        .serial_in(FPGA_SERIAL_RX),

        .data_in_ready(),
        .data_out(),
        .data_out_valid(),
        .serial_out(FPGA_SERIAL_TX)
    );
endmodule
