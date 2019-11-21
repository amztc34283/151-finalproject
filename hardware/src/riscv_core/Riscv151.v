module Riscv151 #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 45_500
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
    wire [1:0] PCSel_signal;
    wire [1:0] InstSel_signal;
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
    wire [7:0] IO_data_in;
    wire [7:0] IO_data_out;
    wire IO_data_in_valid;
    wire IO_data_out_ready;
    wire IO_data_in_ready;
    wire IO_data_out_valid;

    wire MMap_Din_Sel_signal;
    wire [2:0] MMapSel_signal;
    wire MMap_DMem_Sel_signal;

    wire [31:0] inst;
    wire [31:0] ALU_out;

    controller controls(
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
      .MMap_DMem_Sel(MMap_DMem_Sel_signal),
      .data_out_valid(IO_data_out_valid),
      .data_out_ready(IO_data_out_ready),
      .data_in_ready(IO_data_in_ready),
      .data_in_valid(IO_data_in_valid)
    );

    //Wire for pipeline register at IF
    wire [31:0] PC_next_d;
    wire [31:0] PC_next_q;

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


    // Can we parametrize the bit width of the mux
    threeonemux PCSel_mux (
        .sel(PCSel_signal),
        .s0(pc_plus_4),
        .s1(ALU_out),
        .s2(PC_next_q),
        .out(PC_next_d)
    );

    wire [31:0] bios_addra, bios_addrb;
    wire [31:0] bios_douta, bios_doutb;
    wire bios_ena, bios_enb;
    assign bios_ena = 1;
    bios_mem bios_mem (
      .clk(clk),
      .ena(bios_ena),
      .addra(PC_next_d[13:2]),
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
    d_ff csrwi_ex_ff (
        .d($unsigned(inst[19:15])),
        .clk(clk),
        .rst(rst),
        .q(csrwi_ex_wire)
    );

    wire [31:0] PC_plus_4_ex;
    d_ff PC_plus_4_ex_ff (
        .d(pc_plus_4),
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
        .d(FA_1_out),
        .clk(clk),
        .rst(rst),
        .q(rd1_ex)
    );

    wire [31:0] rd2_ex;
    d_ff rs2_ex_ff (
        .d(FB_1_out),
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
        // .ra1(rd1_ex),
        // .ra2(rd2_ex),
        .ra1(FA_2_out),
        .ra2(FB_2_out),
        .BrUn(BrUn_signal),
        .BrEq(BrEq_signal),
        .BrLT(BrLT_signal)
    );

    wire [31:0] Asel_out;
    twoonemux Asel_mux(
        .sel(ASel_signal),
        // .s0(rd1_ex),
        .s0(FA_2_out),
        .s1(PC_Asel_ex),
        .out(Asel_out));

    wire [31:0] Bsel_out;
    twoonemux Bsel_mux(
        .sel(BSel_signal),
        // .s0(rd2_ex),
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
        // .rs2(rd2_ex),
        .rs2(FB_2_out),
        .dmem_we(dmem_we),
        .dmem_din(dmem_din)
    );

    /*********** everything before MEM stage is implemented above ***********/

    wire [31:0] dmem_dout;
    dmem dmem (
      .clk(clk),
      .en(MemRW_signal),
      .we(dmem_we),
      .addr(ALU_out[15:2]),
      .din(dmem_din),
      .dout(dmem_dout)
    );


    wire [31:0] mmap_dout;
    mmap_mem mmap_mem (
        .clk(clk),
        .rst(rst),
        .MMap_Sel(MMapSel_signal),       
        .data_in_ready(IO_data_in_ready),    // Signal from UART reciever                     
        .data_out_valid(IO_data_out_valid),     // Signal from UART reciever
        .data_out_ready(IO_data_out_ready),  // After recieve, goes hi, then low, back hi after load
        .data_in_valid(IO_data_in_valid),
        .IO_mem_din_rx(IO_data_out),            // data_out
        .IO_mem_din_tx(FA_2_out[7:0]),          // FA2
        .MMap_dout(mmap_dout)                            
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

    wire [31:0] MMap_Ld_Mux_out;
    twoonemux MMap_DMem_mux (
        .sel(MMap_DMem_Sel_signal), // top bit addr == 1 ? mmap_dout : ld_out
        .s0(ld_out),                // output of ld_sel
        .s1(mmap_dout),             // output of mmap_mem
        .out(MMap_Ld_Mux_out)       // goes to WB_mux
    );

    threeonemux wb_mux(
      .sel(WBSel_signal),
      .s0(MMap_Ld_Mux_out),
      .s1(alu_mem),
      .s2(pc_plus_4_mem),
      .out(wd)
    );


    // On-chip UART
    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) on_chip_uart (
        .clk(clk),
        .reset(rst),
        .data_in(IO_data_in),
        .data_in_valid(IO_data_in_valid),
        .data_out_ready(IO_data_out_ready),
        .serial_in(FPGA_SERIAL_RX),
    
        .data_in_ready(IO_data_in_ready),
        .data_out(IO_data_out),
        .data_out_valid(IO_data_out_valid),
        .serial_out(FPGA_SERIAL_TX)
    );
endmodule
