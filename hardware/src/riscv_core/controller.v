`define LOAD 0
`define STORE 8
`define BRANCH 24
`define JALR 25
`define JAL 27
`define R 12
`define I 4
`define AUIPC 5
`define LUI 13
`define CSRW 16
`define CSRWI 17

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
`define B 9

`define LB_FUNC3 0
`define LH_FUNC3 1
`define LW_FUNC3 2
`define LBU_FUNC 4
`define LHU_FUNC 5

`define BEQ 0
`define BNE 1
`define BLT 4
`define BGE 5
`define BLTU 6
`define BGEU 7

module controller(
    input rst,
    input clk,
    input [31:0] inst,
    input BrEq,
    input BrLt,
    output reg PCSel,
    output reg InstSel,
    output reg RegWrEn,
    output reg BrUn,
    output reg BSel,
    output reg ASel,
    output reg [3:0] ALUSel,
    output reg MemRW,
    output reg [1:0] WBSel,
    output FA_1,
    output FB_1,
    output FA_2,
    output FB_2,
    output reg [2:0] LdSel,
    output reg [1:0] SSel);

    reg [31:0] ex_inst_reg;
    reg [31:0] mem_wb_inst_reg;

    reg [4:0] ex_state = 0;
    reg [4:0] mem_wb_state = 0;

//    // Forwarding Logic
//    // We wish to forward to FA_2 when instruction in mem/wb uses rd
//    // and instruction in execute uses rs1
//    assign FA_2 =  (mem_wb_inst_reg[11:7] == ex_inst_reg[19:15]) && 
//                            ((mem_wb_state != `BRANCH) && 
//                            (mem_wb_state != `STORE)) && 
//                    ((ex_state != `LUI) && (ex_state != `AUIPC) && 
//                    (ex_state != `JAL) && (ex_state != `CSRWI));

//    // We wish to forward to FB_2 when instruction in mem/wb uses rd
//    // and instruction in execute uses rs2
//    assign FB_2 =  (mem_wb_inst_reg[11:7] == ex_inst_reg[24:20]) && 
//                            ((mem_wb_state != `BRANCH) && 
//                            (mem_wb_state != `STORE)) && 
//                    ((ex_state != `LUI) && (ex_state != `AUIPC) && 
//                    (ex_state != `JAL) && (ex_state != `CSRWI) && 
//                    (ex_state != `JALR) && (ex_state != `LOAD) && 
//                    (ex_state != `I));

//    // We wish to forward to FA_1 when instruction in mem/wb uses rd
//    // and instruction in if/decode uses rs1
//    assign FA_1 = (mem_wb_inst_reg[11:7] == inst[19:15]) && 
//                        ((mem_wb_state != `BRANCH) && 
//                        (mem_wb_state != `STORE)) && 
//                    ((inst[19:15] != `LUI) && (inst[19:15] != `AUIPC) && 
//                    (inst[19:15] != `JAL) && (inst[19:15] != `CSRWI));

//    // We wish to forward to FB_1 when instruction in mem/wb uses rd
//    // and instruction in if/decode uses rs2
//    assign FB_1 =   (mem_wb_inst_reg[11:7] == ex_inst_reg[24:20]) && 
//                            ((mem_wb_state != `BRANCH) && 
//                            (mem_wb_state != `STORE)) && 
//                    ((inst[19:15] != `LUI) && (inst[19:15] != `AUIPC) && 
//                    (inst[19:15] != `JAL) && (inst[19:15] != `CSRWI) && 
//                    (inst[19:15] != `JALR) && (inst[19:15] != `LOAD) && 
//                    (inst[19:15] != `I));

    always @(posedge clk) begin
        ex_inst_reg <= inst;
        mem_wb_inst_reg <= ex_inst_reg;

        ex_state <= inst[6:2];
        mem_wb_state <= ex_state;
    end

    always @(*) begin
       case (ex_state) 
        `LOAD: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `ADD;
            MemRW = 1;
            InstSel = 0;
            PCSel = 0;
        end
        `STORE: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `ADD;
            MemRW = 1;
            SSel = mem_wb_inst_reg[13:12];
            InstSel = 0;
            PCSel = 0;
        end
        `BRANCH: begin
            ASel = 1;
            BSel = 1;
            ALUSel = `ADD;
            BrUn = mem_wb_inst_reg[14:13] == 2'b11 ? 1 : 0; 
            // This encoding can be minimized further
            case (mem_wb_inst_reg[14:12])
                `BEQ: PCSel = BrEq ? 1 : 0;
                `BNE: PCSel = BrEq ? 0 : 1;
                `BLT: PCSel = BrLt ? 1 : 0;
                `BGE: PCSel = !BrLt ? 1 : 0;
                `BLTU: PCSel = BrLt ? 1 : 0;
                `BGEU: PCSel = !BrLt ? 1 : 0; 
            endcase
            InstSel = 2;
            MemRW = 0;
        end
        `JALR: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `ADD;
            PCSel = 1;
            MemRW = 0;
            InstSel = 0;
        end
        `JAL: begin
            ASel = 1;
            BSel = 1;
            ALUSel = `ADD;
            PCSel = 1;
            MemRW = 0;
            InstSel = 2;
        end
        `R: begin
            ASel = 0;
            BSel = 0;
            ALUSel = {ex_inst_reg[30], ex_inst_reg[14:12]};
            MemRW = 0;
            InstSel = 0;
            PCSel = 0;
        end
        `I: begin
            ASel = 0;
            BSel = 1;
            ALUSel = {ex_inst_reg[30], ex_inst_reg[14:12]};
            MemRW = 0;
            InstSel = 0;
            PCSel = 0;
         end
        `AUIPC: begin 
            ASel = 1;
            BSel = 1;
            ALUSel = `ADD;
            MemRW = 0;
            InstSel = 0;
            PCSel = 0;
         end
        `LUI: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `B;
            InstSel = 0;
            MemRW = 0;
            PCSel = 0;
        end
        endcase
    end

    always @(*) begin
        case (mem_wb_state)
        `LOAD: begin
            LdSel = mem_wb_inst_reg[14:12];
            WBSel = 0;
            RegWrEn = 1;
        end
        `STORE: begin
            RegWrEn = 0;
        end
        `BRANCH: begin
            WBSel = 0;
            RegWrEn = 0;
        end
        `JALR: begin
            WBSel = 2;
            RegWrEn = 1;
        end
        `JAL: begin
            WBSel = 2;
            RegWrEn = 1;
        end
        `R: begin
            WBSel = 1;
            RegWrEn = 1;
        end
        `I: begin
            WBSel = 1;
            RegWrEn = 1;
        end
        `AUIPC: begin
            WBSel = 1;
            RegWrEn = 1;
        end
        `LUI: begin 
            WBSel = 1;
            RegWrEn = 1;
        end
        endcase
    end




endmodule