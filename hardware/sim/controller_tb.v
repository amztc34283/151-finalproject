`timescale 1ns/100ps
`define CLK_PERIOD 12

`define LOAD 0
`define STORE 8
`define BRANCH 24
`define JALR 25
`define JAL 27
`define R 12
`define I 4
`define AUIPC 5
`define LUI 13

`define SUB 8
`define ADD 0
`define SLT 2
`define SLTU 3
`define XOR 4
`define OR 6
`define AND 7
`define SLL 1
`define SRL 5
`define SRA 13

`define LB_FUNC3 0
`define LH_FUNC3 1
`define LW_FUNC3 2
`define LBU_FUNC3 4
`define LHU_FUNC3 5
`define LOAD_X 7

`define SB_FUNC3 0
`define SH_FUNC3 1
`define SW_FUNC3 2
`define STORE_X 3

`define WBSEL_X 0

module controller_tb();

    reg rst = 0;
    reg clk = 0;
    reg [31:0] inst = 0;
    wire PCSel;
    wire [1:0] InstSel;
    wire RegWrEn;
    wire BrUn;
    reg BrEq_in = 0;
    reg BrLt_in = 0;
    wire BSel;
    wire ASel;
    wire [3:0] ALUSel;
    wire MemRW;
    wire [1:0] WBSel;
    wire FA_1;
    wire FB_1;
    wire FA_2;
    wire FB_2;
    wire [2:0] LdSel;
    wire [1:0] SSel;

    always #(`CLK_PERIOD/2) clk <= ~clk;

    controller DUT_controller (
        .rst(rst),
        .clk(clk),
        .inst(inst),
        .BrEq(BrEq_in),
        .BrLt(BrLt_in),
        .PCSel(PCSel),
        .InstSel(InstSel),
        .RegWrEn(RegWrEn),
        .BrUn(BrUn),
        .BSel(BSel),
        .ASel(ASel),
        .ALUSel(ALUSel),
        .MemRW(MemRW),
        .WBSel(WBSel),
        .FA_1(FA_1),
        .FB_1(FB_1),
        .FA_2(FA_2),
        .FB_2(FB_2),
        .LdSel(LdSel),
        .SSel(SSel)
        );

    reg FA_1_e;
    reg FB_1_e;
    reg FA_2_e;
    reg FB_2_e;
    reg BrUn_e;
    reg BSel_e;
    reg ASel_e;
    reg [3:0] ALUSel_e;
    reg MemRW_e;
    reg [2:0] LdSel_e;
    reg [1:0] WBSel_e;
    reg PCSel_e;
    reg [1:0] SSel_e;
    reg RegWrEn_e;
    reg [1:0] InstSel_e;

    reg FA_1_e_b;
    reg FB_1_e_b;
    reg FA_2_e_b;
    reg FB_2_e_b;
    reg BrUn_e_b;
    reg BSel_e_b;
    reg ASel_e_b;
    reg [3:0] ALUSel_e_b;
    reg MemRW_e_b;
    reg [2:0] LdSel_e_b;
    reg [1:0] WBSel_e_b;
    reg PCSel_e_b;
    reg [1:0] SSel_e_b;
    reg RegWrEn_e_b;
    reg [1:0] InstSel_e_b;
    reg BrEq_in_b = 0;
    reg BrLT_in_b = 0;

   `define debug_FB1 \
        $display("mem_wb_inst: %h", DUT_controller.mem_wb_inst_reg); \
        $display("if_d_inst: %h", DUT_controller.inst); \
        $display("mem_wb_reg: %d\n inst_reg: %d\n mem_wb_state: %d\n, inst_op: %d\n", \
                        DUT_controller.mem_wb_inst_reg[11:7], \
                        DUT_controller.inst[24:20], \
                        DUT_controller.mem_wb_state, \
                        DUT_controller.inst[6:2]);

   `define debug_FA1 \
        $display("mem_wb_inst: %h", DUT_controller.mem_wb_inst_reg); \
        $display("if_d_inst: %h", DUT_controller.inst); \
        $display("mem_wb_reg: %d\n inst_reg: %d\n mem_wb_state: %d\n, inst_op: %d\n", \
                        DUT_controller.mem_wb_inst_reg[11:7], \
                        DUT_controller.inst[19:15], \
                        DUT_controller.mem_wb_state, \
                        DUT_controller.inst[6:2]);

    `define stage1a(name) \
        if (FA_1 != FA_1_e) begin \
            $display("%s IF/D failed", name); \
            $display("FA_1: actual %d, expected %d", FA_1, FA_1_e); \
            `debug_FA1; \
        end \
        if (FB_1 != FB_1_e) begin \
            $display("%s IF/D failed", name); \
            $display("FB_1: actual %d, expected %d", FB_1, FB_1_e); \
            `debug_FB1; \
        end 

    `define stage1b(name) \
        if (FA_1 != FA_1_e_b) begin \
            $display("%s IF/D failed", name); \
            $display("FA_1: actual %d, expected %d", FA_1, FA_1_e_b); \
            `debug_FA1; \
        end \
        if (FB_1 != FB_1_e_b) begin \
            $display("%s IF/D failed", name); \
            $display("FB_1: actual %d, expected %d", FB_1, FB_1_e_b); \
            `debug_FB1; \
        end 

    `define stage2b(name) \
         if (FA_2 != FA_2_e_b) begin \
             $display("%s Execute failed", name); \
             $display("FA_2: actual %d, expected %d", FA_2, FA_2_e_b); \
         end \
         if (FB_2 != FB_2_e_b) begin \
             $display("%s Execute failed", name); \
             $display("FB_2: actual %d, expected %d", FB_2, FB_2_e_b); \
         end \
         if (BrUn != BrUn_e_b) begin \
             $display("%s Execute failed", name); \
             $display("BrUn: actual %d, expected %d", BrUn, BrUn_e_b); \
         end \
         if (ASel != ASel_e_b) begin \
             $display("%s Execute Stage failed", name); \
             $display("ASel: actual %d, expected %d", ASel, ASel_e_b); \
         end \
         if (BSel != BSel_e_b) begin \
             $display("%s Execute Stage failed", name); \
             $display("BSel: actual %d, expected %d", BSel, BSel_e_b); \
         end \
         if (ALUSel != ALUSel_e_b) begin \
             $display("%s Execute Stage failed", name); \
             $display("ALUSel: actual %d, expected %d", ALUSel, ALUSel_e_b); \
         end  \
         if (MemRW != MemRW_e_b) begin \
             $display("%s Execute Stage failed", name); \
             $display("MemRW: actual %d, expected %d", MemRW, MemRW_e_b); \
         end \
         if (PCSel != PCSel_e_b) begin \
             $display("%s Execute Stage failed", name); \
             $display("PCSel: actual %d, expected %d", PCSel, PCSel_e_b); \
         end \
         if (SSel != SSel_e_b) begin \
             $display("%s Execute Stage failed", name); \
             $display("SSel: actual %d, expected %d", SSel, SSel_e_b); \
             $display("Controller: %d", DUT_controller.SSel); \
             $display("SSel: actual %d, expected %d", SSel, SSel_e_b); \
         end \
         if (InstSel != InstSel_e_b) begin \
             $display("%s Execute Stage failed", name); \
             $display("InstSel: actual %d, expected %d", InstSel, InstSel_e_b); \
         end \
 
 
    `define stage2a(name) \
         if (FA_2 != FA_2_e) begin \
             $display("%s Execute failed", name); \
             $display("FA_2: actual %d, expected %d", FA_2, FA_2_e); \
         end \
         if (FB_2 != FB_2_e) begin \
             $display("%s Execute failed", name); \
             $display("FB_2: actual %d, expected %d", FB_2, FB_2_e); \
         end \
         if (BrUn != BrUn_e) begin \
             $display("%s Execute failed", name); \
             $display("BrUn: actual %d, expected %d", BrUn, BrUn_e); \
         end \
         if (ASel != ASel_e) begin \
             $display("%s Execute Stage failed", name); \
             $display("ASel: actual %d, expected %d", ASel, ASel_e); \
         end \
         if (BSel != BSel_e) begin \
             $display("%s Execute Stage failed", name); \
             $display("BSel: actual %d, expected %d", BSel, BSel_e); \
         end \
         if (ALUSel != ALUSel_e) begin \
             $display("%s Execute Stage failed", name); \
             $display("ALUSel: actual %d, expected %d", ALUSel, ALUSel_e); \
         end  \
         if (MemRW != MemRW_e) begin \
             $display("%s Execute Stage failed", name); \
             $display("MemRW: actual %d, expected %d", MemRW, MemRW_e); \
         end \
         if (PCSel != PCSel_e) begin \
             $display("%s Execute Stage failed", name); \
             $display("PCSel: actual %d, expected %d", PCSel, PCSel_e); \
         end \
         if (SSel != SSel_e) begin \
             $display("%s Execute Stage failed", name); \
             $display("SSel: actual %d, expected %d", SSel, SSel_e); \
         end \
         if (InstSel != InstSel_e) begin \
             $display("%s Execute Stage failed", name); \
             $display("InstSel: actual %d, expected %d", InstSel, InstSel_e); \
         end \
 
     `define stage3a(name) \
        if (WBSel != WBSel_e) begin \
            $display("%s Mem/WB Stage failed", name); \
            $display("WBSel: actual %d, expected %d", WBSel, WBSel_e); \
        end \
        if (RegWrEn != RegWrEn_e) begin \
            $display("%s Mem/WB Stage failed", name); \
            $display("RegWrEn: actual %d, expected %d", RegWrEn, RegWrEn_e); \
        end \
        if (LdSel != LdSel_e) begin \
            $display("%s Mem/WB Stage failed", name); \
            $display("LdSel: actual %d, expected %d", LdSel, LdSel_e); \
        end   
        
       `define stage3b(name) \
        if (WBSel != WBSel_e_b) begin \
            $display("%s Mem/WB Stage failed", name); \
            $display("WBSel: actual %d, expected %d", WBSel, WBSel_e_b); \
        end \
        if (RegWrEn != RegWrEn_e_b) begin \
            $display("%s Mem/WB Stage failed", name); \
            $display("RegWrEn: actual %d, expected %d", RegWrEn, RegWrEn_e_b); \
        end     \
        if (LdSel != LdSel_e_b) begin \
            $display("%s Mem/WB Stage failed", name); \
            $display("LdSel: actual %d, expected %d", LdSel, LdSel_e_b); \
        end   
                   
     `define ctrl_test(name, inst_input) \
        fork \
            begin \
                inst = inst_input; \
                @(posedge clk); \
                #(1); \
                inst = 32'h00000013; \
                @(posedge clk); \
                #(1); \
                inst = 32'h00000013; \
            end\
            begin \
                #(1); \
                `stage1a(name); \
                @(posedge clk); \
                #(1); \
                if (InstSel == 2) \
                    inst = 32'h00000013; \
                `stage2a(name); \
                @(posedge clk); \
                #(1); \
                `stage3a(name); \
                repeat(2) @(posedge clk); \
            end \
        join 

    // Macro for testing adjacent forwarding instructions
    // 1st inst enters IF/D
    // 1st inst enters ex, 2nd inst enters IF/D
    // 1st inst enters mem/wb, 2nd inst enters ex
    // 2nd inst enters ex

    // stage1a
    // posedge clk
    // stage2a
    // stage1b
    // posedge clk
    // stage3a
    // stage2b
    // posedge clk
    // stage3b
    `define forward2_test(name_a, inst_input_a, name_b, inst_input_b, BrEq_in_B, BrLt_in_B) \
        fork \
            begin \
                inst = inst_input_a; \
                @(posedge clk); \
                #(1); \
                inst = inst_input_b; \
                @(posedge clk); \
                #(1); \
                inst = 32'h00000013; \
                @(posedge clk); \
                #(1); \
                inst = 32'h00000013; \
            end \
            begin \
                #(1); \
                `stage1a(name_a); \
                @(posedge clk); \
                #(1); \
                `stage2a(name_a); \
                `stage1b(name_b); \
                @(posedge clk); \
                #(1); \
                `stage3a(name_a); \
                `stage2b(name_b); \
                @(posedge clk); \
                #(1); \
                `stage3b(name_b); \
                repeat(2) @(posedge clk); \
            end \
        join 
// Put this before stage2b
//        BrEq_in = BrEq_in_B; 
//        BrLt_in = BrLt_in_B;

    initial begin
    // LOAD INSTRUCTIONS
    FA_1_e = 0;
    FB_1_e = 0;
    FA_2_e = 0;
    FB_2_e = 0;
    BrUn_e = 0;
    BrEq_in = 1'bx;
    BrLt_in = 1'bx; 
    BSel_e = 1;
    ASel_e = 0;
    ALUSel_e = `ADD;
    MemRW_e = 1;
    LdSel_e = `LW_FUNC3;
    WBSel_e = 0;
    PCSel_e = 0;
    SSel_e = `STORE_X;
    RegWrEn_e = 1;
    InstSel_e = 2'b00;

    // lw x2 0(x3)
    `ctrl_test("lw", 32'h0001a103);

    // lh x2 0(x3)
    LdSel_e = `LH_FUNC3;
    `ctrl_test("lh", 32'h00019103);

    // lb x2 0(x3)
    LdSel_e = `LB_FUNC3;
    `ctrl_test("lb", 32'h00018103);

    // lhu x2 0(x3)
    LdSel_e = `LHU_FUNC3;
    `ctrl_test("lhu", 32'h0001d103);

    // lbu x2 0(x3)
    LdSel_e = `LBU_FUNC3;
    `ctrl_test("lbu", 32'h0001c103);
    
    // STORE INSTRUCTIONS
    FA_1_e = 0;
    FB_1_e = 0;
    FA_2_e = 0;
    FB_2_e = 0;
    BrUn_e = 0;
    BrEq_in = 1'bx;
    BrLt_in = 1'bx;
    BSel_e = 1;
    ASel_e = 0;
    ALUSel_e = `ADD;
    MemRW_e = 1;
    LdSel_e = `LOAD_X;
    WBSel_e = 2'bxx;
    PCSel_e = 0;
    SSel_e = `SW_FUNC3;
    RegWrEn_e = 0;
    InstSel_e = 2'b00;

    // sw x2 0(x3)
    `ctrl_test("sw", 32'h0021a023);

    // sh x2 0(x3)
    SSel_e = `SH_FUNC3;
    `ctrl_test("sh", 32'h00219023);  

    // sb x2 0(x3)
    SSel_e = `SB_FUNC3;
    `ctrl_test("sb", 32'h00218023);
    
    // R INSTRUCTIONS
    FA_1_e = 0;
    FB_1_e = 0;
    FA_2_e = 0;
    FB_2_e = 0;
    BrUn_e = 0;
    BrEq_in = 1'bx;
    BrLt_in = 1'bx;
    BSel_e = 0;
    ASel_e = 0;
    ALUSel_e = `ADD;
    MemRW_e = 0;
    LdSel_e = `LOAD_X;
    WBSel_e = 1;
    PCSel_e = 0;
    SSel_e = `STORE_X;
    RegWrEn_e = 1; 
    InstSel_e = 2'b00;
    
    // add x3 x4 x1 
    `ctrl_test("add", 32'h001201b3);

    // sub x3 x4 x1
    ALUSel_e = `SUB;
    `ctrl_test("sub", 32'h401201b3);

    // slt x3 x4 x1
    ALUSel_e = `SLT;
    `ctrl_test("slt", 32'h001221b3);

    // sltu x3 x4 x1
    ALUSel_e = `SLTU;
    `ctrl_test("sltu", 32'h001231b3);

    // xor x3 x4 x1
    ALUSel_e = `XOR;
    `ctrl_test("xor", 32'h001241b3);

    // or x3 x4 x1
    ALUSel_e = `OR;
    `ctrl_test("or", 32'h001261b3);

    // and x3 x4 x1
    ALUSel_e = `AND;
    `ctrl_test("and", 32'h001271b3);

    // sll x3 x4 x1
    ALUSel_e = `SLL;
    `ctrl_test("sll", 32'h001211b3);

    // srl x3 x4 x1
    ALUSel_e = `SRL;
    `ctrl_test("srl", 32'h001251b3);

    // sra x3 x4 x1
    ALUSel_e = `SRA;
    `ctrl_test("sra", 32'h401251b3);
    
    
    // I INSTRUCTION TESTS 
    FA_1_e = 0;
    FB_1_e = 0;
    FA_2_e = 0;
    FB_2_e = 0;
    BrUn_e = 0;
    BrEq_in = 1'bx;
    BrLt_in = 1'bx;
    BSel_e = 1;
    ASel_e = 0;
    ALUSel_e = `ADD;
    MemRW_e = 0;
    LdSel_e = `LOAD_X;
    WBSel_e = 1;
    PCSel_e = 0;
    SSel_e = `STORE_X;
    RegWrEn_e = 1; 
    InstSel_e = 2'b00;

     // addi x3 x4 x1 
     `ctrl_test("addi", 32'h00420193);

     // slti x3 x4 x1
     ALUSel_e = `SLT;
     `ctrl_test("slti", 32'h00422193);

     // sltui x3 x4 x1
     ALUSel_e = `SLTU;
     `ctrl_test("sltiu", 32'h00423193);

     // xori x3 x4 x1
     ALUSel_e = `XOR;
     `ctrl_test("xori", 32'h00424193);

     // ori x3 x4 x1
     ALUSel_e = `OR;
     `ctrl_test("ori", 32'h00426193);

     // andi x3 x4 x1
     ALUSel_e = `AND;
     `ctrl_test("andi", 32'h00427193);

     // slli x3 x4 x1
     ALUSel_e = `SLL;
     `ctrl_test("slli", 32'h00421193);

     // srli x3 x4 x1
     ALUSel_e = `SRL;
     `ctrl_test("srli", 32'h00425193);

     // srai x3 x4 x1
     ALUSel_e = `SRA;
     `ctrl_test("srai", 32'h40425193);

    // B INSTRUCTION TESTS 
    FA_1_e = 0;
    FB_1_e = 0;
    FA_2_e = 0;
    FB_2_e = 0;
    BrLt_in = 1'b0;
    BSel_e = 1;
    ASel_e = 1;
    ALUSel_e = `ADD;
    MemRW_e = 0;
    LdSel_e = `LOAD_X;
    WBSel_e = 1'bx;
    PCSel_e = 1;
    SSel_e = `STORE_X;
    RegWrEn_e = 0; 
    InstSel_e = 2'b10;

    // beq x30 x1 156
    BrUn_e = 0;
    BrEq_in = 1'b1;
    PCSel_e = 1;
    `ctrl_test("beq_true", 32'h081f0e63);
    BrEq_in = 1'b0;
    PCSel_e = 0;
    `ctrl_test("beq_false", 32'h081f0e63);

    // bne x30 x1 152
    BrEq_in = 1'b0;
    PCSel_e = 1;
    `ctrl_test("bne_true", 32'h081f1c63);
    BrEq_in = 1'b1;
    PCSel_e = 0;
    `ctrl_test("bne_false", 32'h081f1c63);

    // blt x30 x1 148
    BrLt_in = 1'b1;
    PCSel_e = 1;
    `ctrl_test("blt_true", 32'h081f4a63);
    BrLt_in = 1'b0;
    PCSel_e = 0;
    `ctrl_test("blt_false", 32'h081f4a63);

    // bge x30 x1 144
    BrLt_in = 1'b0;
    PCSel_e = 1;
    `ctrl_test("bge_true", 32'h081f5863);
    BrLt_in = 1'b1;
    PCSel_e = 0;
    `ctrl_test("bge_false", 32'h081f5863);

    // bltu x30 x1 140
    BrUn_e = 1;
    BrLt_in = 1'b1;
    PCSel_e = 1;
    `ctrl_test("bltu_true", 32'h081f6663);
    BrLt_in = 1'b0;
    PCSel_e = 0;
    `ctrl_test("bltu_false", 32'h081f6663);

    // bgeu x30 x1 136
    BrLt_in = 1'b1;
    PCSel_e = 0;
    `ctrl_test("bgeu_false", 32'h081f7463);
    BrLt_in = 1'b0;
    PCSel_e = 1;
    `ctrl_test("bgeu_true", 32'h081f7463);


    // J INSTRUCTION TESTS
    FA_1_e = 0;
    FB_1_e = 0;
    FA_2_e = 0;
    FB_2_e = 0;
    BrUn_e = 1'bx;
    BrEq_in = 1'bx;
    BrLt_in = 1'bx;
    BSel_e = 1;
    ASel_e = 1;
    ALUSel_e = `ADD;
    MemRW_e = 0;
    LdSel_e = `LOAD_X;
    WBSel_e = 2'b10;
    SSel_e = `STORE_X;
    RegWrEn_e = 1; 
    InstSel_e = 2'b00;

    // jal x0 96
    InstSel_e = 2'b10;
    PCSel_e = 1;
    WBSel_e = 2;
    `ctrl_test("jal", 32'h0600006f);
  
    // jalr x0 x7 100
    InstSel_e = 2'b10;
    ASel_e = 0;  
    BSel_e = 1;
    `ctrl_test("jalr", 32'h06438067);

    // U INSTRUCTION TESTS
    FA_1_e = 0;
    FB_1_e = 0;
    FA_2_e = 0;
    FB_2_e = 0;
    BrUn_e = 1'bx;
    BrEq_in = 1'bx;
    BrLt_in = 1'bx;
    BSel_e = 1;
    ASel_e = 0;
    ALUSel_e = `ADD;
    MemRW_e = 0;
    LdSel_e = `LOAD_X;
    WBSel_e = 1;
    PCSel_e = 0;
    SSel_e = `STORE_X;
    RegWrEn_e = 1; 
    InstSel_e = 2'b00;

    // lui x2 1000
    ALUSel_e = `B;
    `ctrl_test("lui", 32'h003e8137);

    // auipc x2 1000
    ASel_e = 1;
    BSel_e = 1;
    ALUSel_e = `ADD;
    `ctrl_test("auipc", 32'h003e8117);

    // FORWARDING TESTS, ADJCACENT CASE
    // ALU -> ALU Forwarding, rs1
    // add x2 x3 x1
    // add x4 x2 x3
    // Expected Control Signals for First Inst
    FA_1_e = 0;
    FB_1_e = 0;
    FA_2_e = 0;
    FB_2_e = 0;
    BrUn_e = 1'bx;
    BrEq_in = 1'bx;
    BrLt_in = 1'bx;
    BSel_e = 0;
    ASel_e = 0;
    ALUSel_e = `ADD;
    MemRW_e = 0;
    LdSel_e = `LOAD_X;
    WBSel_e = 1;
    PCSel_e = 0;
    SSel_e = `STORE_X;
    RegWrEn_e = 1; 
    InstSel_e = 2'b00;

    // Expected Control Signals for 2nd Inst
    FA_1_e_b = 0;
    FB_1_e_b = 0;
    FA_2_e_b = 1;
    FB_2_e_b = 0;
    BrUn_e_b = 1'bx;
    BrEq_in_b = 1'bx;
    BrLT_in_b = 1'bx;
    BSel_e_b = 0;
    ASel_e_b = 0;
    ALUSel_e_b = `ADD;
    MemRW_e_b = 0;
    LdSel_e_b = `LOAD_X;
    WBSel_e_b = 1;
    PCSel_e_b = 0;
    SSel_e_b = `STORE_X;
    RegWrEn_e_b = 1; 
    InstSel_e_b = 2'b00;
    // add x2 x3 x1
    // add x4 x2 x3
    `forward2_test("add_rs1_a", 32'h00118133, "add_rs1_b", 32'h00310233, BrEq_in_b, BrLt_in_b);
    
    // ALU -> ALU Forwarding, rs2
    // add x2 x3 x1
    // add x4 x3 x2
    FA_2_e_b = 0;
    FB_2_e_b = 1;
    `forward2_test("add_rs2_a", 32'h00118133, "add_rs2_b", 32'h00218233, BrEq_in_b, BrLt_in_b);
    
    // ALU -> Mem Forwarding, rs1
    // Expected Control Signals for 2nd Inst
    // add x2 x3 x1
    // lw x3 0(x2)
    FA_1_e_b = 0;
    FB_1_e_b = 0;
    FB_2_e_b = 0;
    BrUn_e_b = 1'bx;
    BrEq_in_b = 1'bx;
    BrLT_in_b = 1'bx;
    ALUSel_e_b = `ADD;
    
    PCSel_e_b = 0;
    SSel_e_b = `STORE_X;
    InstSel_e_b = 2'b00;   
 
    ASel_e_b = 0;
    BSel_e_b = 1;
    MemRW_e_b = 1;
    LdSel_e_b = `LW_FUNC3;
    WBSel_e_b = 0;
    RegWrEn_e_b = 1; 
    FA_2_e_b = 1;
    `forward2_test("add_rs1_a", 32'h00118133, "lw_rs1_b", 32'h00012183, BrEq_in_b, BrLt_in_b);

    // ALU -> Mem Forwarding, rs2
    // add x2 x3 x1
    // sw x2 0(x3)
    FA_2_e_b = 0;
    FB_2_e_b = 1;
    LdSel_e_b = `LOAD_X;
    SSel_e_b = `SW_FUNC3;
    RegWrEn_e_b = 0; 
    WBSel_e_b = `WBSEL_X;
    `forward2_test("add_rs2_a", 32'h00118133, "sw_rs2_b", 32'h0021a023, BrEq_in_b, BrLt_in_b);


    $finish();

    end
endmodule
