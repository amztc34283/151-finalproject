`define LOAD 0
`define STORE 8
`define X 2
`define BRANCH 24
`define JALR 25
`define JAL 27
`define R 12
`define I 4
`define AUIPC 5
`define LUI 13
`define CSRW 28

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
`define LOAD_X 7

`define BEQ 0
`define BNE 1
`define BLT 4
`define BGE 5
`define BLTU 6
`define BGEU 7

`define WBSEL_X 0

// imm_gen control signals
`define I_TYPE 1
`define S_TYPE 2
`define B_TYPE 3
`define U_TYPE 4
`define J_TYPE 5
`define X_TYPE 6

module controller(
    input rst,
    input clk,
    input [31:0] inst,
    input BrEq,
    input BrLt,
    output reg [1:0] PCSel,
    output reg [1:0] InstSel,
    output reg RegWrEn,
    output reg [2:0] ImmSel,
    output reg BrUn,
    output reg BSel,
    output reg ASel,
    output reg [3:0] ALUSel,
    output reg CSREn,
    output reg CSRSel,
    output reg MemRW,
    output reg [1:0] WBSel,
    output FA_1,
    output FB_1,
    output FA_2,
    output FB_2,
    output reg [2:0] LdSel,
    output reg [1:0] SSel);

    reg [31:0] ex_inst_reg = 32'h00000013;
    reg [31:0] mem_wb_inst_reg = 32'h00000013;

    reg [4:0] ex_state = 2;
    reg [4:0] mem_wb_state = 2;

   // Forwarding Logic
   // We wish to forward to FA_2 when instruction in mem/wb uses rd
   // and instruction in execute uses rs1
   assign FA_2 = (mem_wb_inst_reg[11:7] == ex_inst_reg[19:15]) &&
                           ((mem_wb_state != `BRANCH) &&
                           (mem_wb_state != `STORE) &&
                           (mem_wb_state != `X)) &&
                   ((ex_state != `LUI) && (ex_state != `AUIPC) &&
                   (ex_state != `JAL) && (ex_state != `X));

   // We wish to forward to FB_2 when instruction in mem/wb uses rd
   // and instruction in execute uses rs2
   assign FB_2 = (mem_wb_inst_reg[11:7] == ex_inst_reg[24:20]) &&
                           ((mem_wb_state != `BRANCH) &&
                           (mem_wb_state != `STORE) &&
                           (mem_wb_state != `X)) &&
                   ((ex_state != `LUI) && (ex_state != `AUIPC) &&
                   (ex_state != `JAL) && (ex_state != `JALR) && 
                   (ex_state != `LOAD) && (ex_state != `I) && 
                   (ex_state != `X) && (ex_state != `CSRW));


   // We wish to forward to FA_1 when instruction in mem/wb uses rd
   // and instruction in if/decode uses rs1
   assign FA_1 = (mem_wb_inst_reg[11:7] == inst[19:15]) &&
                       ((mem_wb_state != `BRANCH) &&
                       (mem_wb_state != `STORE) &&
                       (mem_wb_state != `X)) &&
                   ((inst[6:2] != `LUI) && (inst[6:2] != `AUIPC) &&
                   (inst[6:2] != `JAL) &&  (inst[6:2] != `X));

   // We wish to forward to FB_1 when instruction in mem/wb uses rd
   // and instruction in if/decode uses rs2
   assign FB_1 = (mem_wb_inst_reg[11:7] == inst[24:20]) &&
                           ((mem_wb_state != `BRANCH) &&
                           (mem_wb_state != `STORE) &&
                           (mem_wb_state != `X)) &&
                   ((inst[6:2] != `LUI) && (inst[6:2]!= `AUIPC) &&
                   (inst[6:2] != `JAL) && (inst[6:2] != `JALR) && 
                   (inst[6:2] != `LOAD) && (inst[6:2] != `I) && 
                   (inst[6:2] != `X) && (inst[6:2] != `CSRW));

    always @(posedge clk) begin
        if (rst) begin
            ex_inst_reg <= 32'h00000013;
            mem_wb_inst_reg <= 32'h00000013;

            ex_state <= 2;
            mem_wb_state <= 2;
        end else begin
            ex_inst_reg <= inst;
            mem_wb_inst_reg <= ex_inst_reg;

            ex_state <= inst[6:2];
            mem_wb_state <= ex_state;
        end
    end

    // We may wish to refactor this to use continuously assign
    // the control signals based on the opcode, such an
    // implementation should be more resource efficient

    // This representation lets us test the correctness
    // of the control signals values more easily

    // If a control signal is not relevant for a particular
    // instruction type, we set it to an arbitrary value
    // to avoid xxx during synthesis-- the arbitrary value
    // should not conflict with used values

    always @(*) begin
        case (inst[6:2])
        `LOAD:      ImmSel = `I_TYPE;
        `STORE:     ImmSel = `S_TYPE;
        `BRANCH:    ImmSel = `B_TYPE;
        `JALR:      ImmSel = `I_TYPE;
        `JAL:       ImmSel = `J_TYPE;
        `R:         ImmSel = `X_TYPE;
        `I:         ImmSel = `I_TYPE;
        `AUIPC:     ImmSel = `U_TYPE;
        `LUI:       ImmSel = `U_TYPE;
        `CSRW:      ImmSel = `X_TYPE;
        default:    ImmSel = `X_TYPE;
        endcase
    end



    always @(*) begin
        case (ex_state)
        `LOAD: begin
            ASel = 0;
            BSel = 1;
            BrUn = 0; // Doesn't matter
            ALUSel = `ADD;
            MemRW = 1;
            SSel = 3; // Not SW, SB, or SH
            //Changed from 0 to 1 for BIOS MEM test
            InstSel = 1;
            PCSel = 0;

        end
        `STORE: begin
            ASel = 0;
            BSel = 1;
            BrUn = 0; // Doesn't matter
            ALUSel = `ADD;
            MemRW = 1;
            SSel = ex_inst_reg[13:12];
            //Changed from 0 to 1 for BIOS MEM test
            InstSel = 1;
            PCSel = 0;

        end
        `BRANCH: begin
            ASel = 1;
            BSel = 1;
            BrUn = ex_inst_reg[14:13] == 2'b11 ? 1 : 0;
            ALUSel = `ADD;
            MemRW = 0;
            SSel = 3;
            InstSel = 2;
            // This encoding can be minimized further
            case (ex_inst_reg[14:12])
                `BEQ: PCSel = BrEq ? 1 : 2;
                `BNE: PCSel = BrEq ? 2 : 1;
                `BLT: PCSel = BrLt ? 1 : 2;
                `BGE: PCSel = !BrLt ? 1 : 2;
                `BLTU: PCSel = BrLt ? 1 : 2;
                `BGEU: PCSel = !BrLt ? 1 : 2;
            endcase

        end
        `JALR: begin
            ASel = 0;
            BSel = 1;
            BrUn = 0;
            ALUSel = `ADD;
            MemRW = 0;
            SSel = 3;
            InstSel = 2;
            PCSel = 1;

        end
        `JAL: begin
            ASel = 1;
            BSel = 1;
            BrUn = 0;
            ALUSel = `ADD;
            MemRW = 0;
            SSel = 3;
            PCSel = 1;
            InstSel = 2;

        end
        `R: begin
            ASel = 0;
            BSel = 0;
            BrUn = 0;
            ALUSel = {ex_inst_reg[30], ex_inst_reg[14:12]};
            MemRW = 0;
            SSel = 3;
            //Changed from 0 to 1 for BIOS MEM test
            InstSel = 1;
            PCSel = 0;

        end
        `I: begin
            ASel = 0;
            BSel = 1;
            BrUn = 0;
            //ALUSel should not use ex_inst_reg[30] for ADDI, SLTI, SLTIU, XORI, ORI, ANDI
            ALUSel = (ex_inst_reg[14:12] == 3'b001 || ex_inst_reg[14:12] == 3'b101) ? {ex_inst_reg[30], ex_inst_reg[14:12]} : {1'b0, ex_inst_reg[14:12]};
            MemRW = 0;
            SSel = 3;
            //Changed from 0 to 1 for BIOS MEM test
            InstSel = 1;
            PCSel = 0;

         end
        `AUIPC: begin
            ASel = 1;
            BSel = 1;
            BrUn = 0;
            ALUSel = `ADD;
            MemRW = 0;
            SSel = 3;
            //Changed from 0 to 1 for BIOS MEM test
            InstSel = 1;
            PCSel = 0;

         end
        `LUI: begin
            ASel = 0;
            BSel = 1;
            BrUn = 0;
            ALUSel = `B;
            MemRW = 0;
            SSel = 3;
            //Changed from 0 to 1 for BIOS MEM test
            InstSel = 1;
            PCSel = 0;

        end
        `CSRW: begin
            ASel = 0;
            BSel = 0;
            BrUn = 0;
            ALUSel = `B;
            MemRW = 0;
            SSel = 3;
            InstSel = 1;
            PCSel = 0;

        end
        default: begin
            ASel = 0;
            BSel = 1;
            BrUn = 0;
            ALUSel = `B;
            MemRW = 0;
            SSel = 3;
            //Changed from 0 to 1 for BIOS MEM test
            InstSel = 1;
            PCSel = 2;
        end
        endcase
    end

    always @(*) begin
        case (mem_wb_state)
        `LOAD: begin
            LdSel = mem_wb_inst_reg[14:12];
            WBSel = 0;
            RegWrEn = 1;
            CSREn = 0;
            CSRSel = 0;
        end
        `STORE: begin
            LdSel = 7;
            WBSel = `WBSEL_X; // Doesn't matter, since RegWrEn == 0
            RegWrEn = 0;
            CSREn = 0;
            CSRSel = 0;

        end
        `BRANCH: begin
            LdSel = 7;
            WBSel = `WBSEL_X;
            RegWrEn = 0;
            CSREn = 0;
            CSRSel = 0;

        end
        `JALR: begin
            LdSel = 7;
            WBSel = 2;
            RegWrEn = 1;
            CSREn = 0;
            CSRSel = 0;

        end
        `JAL: begin
            LdSel = 7;
            WBSel = 2;
            RegWrEn = 1;
            CSREn = 0;
            CSRSel = 0;

        end
        `R: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;
            CSREn = 0;
            CSRSel = 0;
        end
        `I: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;
            CSREn = 0;
            CSRSel = 0;

        end
        `AUIPC: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;
            CSREn = 0;
            CSRSel = 0;

        end
        `LUI: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;
            CSREn = 0;
            CSRSel = 0;
        end
        `CSRW: begin
            LdSel = 7;
            WBSel = `WBSEL_X;
            RegWrEn = 0;
            CSREn = 1;
            CSRSel = mem_wb_inst_reg[14:12];
            
        end
        default: begin
            LdSel = `LOAD_X;
            WBSel = 0;
            RegWrEn = 0;
            CSREn = 0;
            CSRSel = 0;
        end
        endcase
    end




endmodule
