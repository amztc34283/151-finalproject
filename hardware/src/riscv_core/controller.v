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
`define RST 1

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

`define UART_CTRL 32'h80000000  // 0
`define UART_RX 32'h80000004    // 1
`define UART_TX 32'h80000008    // 2
`define UART_CC 32'h80000010    // 3
`define UART_IC 32'h80000014    // 4
`define UART_RST 32'h80000018   // 5
// Control Injected Nop         // 6
// Don't Care Value             // 7
// `define GPIO_FIFO_EMPTY 32'h80000020
// `define GPIO_FIFO_READ 32'h80000024
// `define SWITCHES 32'h80000028
// `define GPIO_LEDS 32'h80000030

// imm_gen control signals
`define I_TYPE 1
`define S_TYPE 2
`define B_TYPE 3
`define U_TYPE 4
`define J_TYPE 5
`define X_TYPE 6

`define CONTROL_NOP 32'h0000_0013

module controller #(
    parameter RESET_PC = 32'h4000_0000)
(
    input rst,
    input clk,
    input [31:0] inst,
    input BrEq,
    input BrLt,
    input [31:0] ALU_out,
    output reg [1:0] PCSel,
    output reg InstSel,
    output reg RegWrEn,
    output reg [2:0] ImmSel,
    output BrUn,
    output reg BSel,
    output reg ASel,
    output reg [3:0] ALUSel,
    output reg CSREn,
    output reg CSRSel,
    output MemRW,
    output reg [1:0] WBSel,
    output FA_1,
    output FB_1,
    output FA_2,
    output FB_2,
    output reg [2:0] LdSel,
    output reg [1:0] SSel,
    output reg [2:0] MMapSel,
    output data_out_ready,
    output data_in_valid
    );

    reg [31:0] ex_inst_reg;
    reg [31:0] mem_wb_inst_reg;

    wire [4:0] ex_state;
    wire [4:0] mem_wb_state;

    reg [31:0] ALU_out_mem;

    // TODO: DISABLE FORWARD FOR INJECTED NOP? 

   // Forwarding Logic
   // We wish to forward to FA_2 when instruction in mem/wb uses rd
   // and instruction in execute uses rs1
   assign FA_2 = ex_state == `CSRW ?
                (mem_wb_inst_reg[11:7] != 0) &&
                (ex_inst_reg[19:15] != 0) &&
                (mem_wb_inst_reg[11:7] == ex_inst_reg[19:15]) &&
                ((mem_wb_state != `BRANCH) &&
                (mem_wb_state != `STORE) &&
                (mem_wb_state != `X) &&
                (mem_wb_state != `RST)) &&
                ((ex_state != `LUI) && (ex_state != `AUIPC) &&
                (ex_state != `JAL) && (ex_state != `X) &&
                (ex_state != `RST)) :
                (mem_wb_inst_reg[11:7]  != 0) &&
                (ex_inst_reg[19:15] != 0) &&
                (mem_wb_inst_reg[11:7] == ex_inst_reg[19:15]) &&
                ((mem_wb_state != `BRANCH) &&
                (mem_wb_state != `STORE) &&
                (mem_wb_state != `X) &&
                (mem_wb_state != `RST)) &&
                ((ex_state != `LUI) && (ex_state != `AUIPC) &&
                (ex_state != `JAL) && (ex_state != `X) &&
                (ex_state != `RST));


   // We wish to forward to FB_2 when instruction in mem/wb uses rd
   // and instruction in execute uses rs2
   assign FB_2 =  (mem_wb_inst_reg[11:7] != 0) &&
                 (ex_inst_reg[24:20] != 0) &&
                 (mem_wb_inst_reg[11:7] == ex_inst_reg[24:20]) &&
                           ((mem_wb_state != `BRANCH) &&
                           (mem_wb_state != `STORE) &&
                           (mem_wb_state != `X) &&
                           (mem_wb_state != `RST)) &&
                   ((ex_state != `LUI) && (ex_state != `AUIPC) &&
                   (ex_state != `JAL) && (ex_state != `JALR) &&
                   (ex_state != `LOAD) && (ex_state != `I) &&
                   (ex_state != `X) && (ex_state != `CSRW) &&
                   (ex_state != `RST));


   // We wish to forward to FA_1 when instruction in mem/wb uses rd
   // and instruction in if/decode uses rs1
   // if CSRW then dont compare x0s
   // if not CSRW then compare x0s
   assign FA_1 = inst[6:2] == `CSRW ?
                    (mem_wb_inst_reg[11:7] == inst[19:15]) &&
                    (mem_wb_inst_reg[11:7]  != 0) &&
                    (inst[19:15] != 0) &&
                    ((mem_wb_state != `BRANCH) &&
                    (mem_wb_state != `STORE) &&
                    (mem_wb_state != `X) &&
                    (mem_wb_state != `RST)) &&
                    ((inst[6:2] != `LUI) && (inst[6:2] != `AUIPC) &&
                    (inst[6:2] != `JAL) &&  (inst[6:2] != `X) &&
                    (inst[6:2] != `RST)) :
                (mem_wb_inst_reg[11:7] == inst[19:15]) &&
                (mem_wb_inst_reg[11:7] != 0) &&
                (inst[19:15] != 0) && ((mem_wb_state != `BRANCH) &&
                (mem_wb_state != `STORE) &&
                (mem_wb_state != `X) &&
                (mem_wb_state != `RST)) &&
                ((inst[6:2] != `LUI) && (inst[6:2] != `AUIPC) &&
                (inst[6:2] != `JAL) &&  (inst[6:2] != `X) &&
                (inst[6:2] != `RST));


   // We wish to forward to FB_1 when instruction in mem/wb uses rd
   // and instruction in if/decode uses rs2
   assign FB_1 =  (mem_wb_inst_reg[11:7] != 0) &&
                 (inst[24:20] != 0) &&
                 (mem_wb_inst_reg[11:7] == inst[24:20]) &&
                           ((mem_wb_state != `BRANCH) &&
                           (mem_wb_state != `STORE) &&
                           (mem_wb_state != `X)) &&
                   ((inst[6:2] != `LUI) && (inst[6:2]!= `AUIPC) &&
                   (inst[6:2] != `JAL) && (inst[6:2] != `JALR) &&
                   (inst[6:2] != `LOAD) && (inst[6:2] != `I) &&
                   (inst[6:2] != `X) && (inst[6:2] != `CSRW));

    assign ex_state = ex_inst_reg[6:2];
    assign mem_wb_state = mem_wb_inst_reg[6:2];

    always @(posedge clk) begin
        if (rst) begin
            ex_inst_reg <= RESET_PC + 32'h00000004;
            mem_wb_inst_reg <= RESET_PC + 32'h00000004;

        end else begin
            // Naive Branch Prediction, Assume Not Taken
            // Branch:          Ex Stage => Mem Stage
            // Inserted Nop:    IF/D Stage => Ex Stage
            if (ex_state == `BRANCH && PCSel == 2'b01)
                ex_inst_reg <= `CONTROL_NOP;
            else
                ex_inst_reg <= inst;

            mem_wb_inst_reg <= ex_inst_reg;
        end
    end

    always @(posedge clk) begin
        if (rst)
            ALU_out_mem <= 0;
        else
            ALU_out_mem <= ALU_out;
    end


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


    assign BrUn = ex_state == `BRANCH ? (ex_inst_reg[14:13] == 2'b11 ? 1 : 0) : 0;

    assign MemRW = ex_state == `STORE || ex_state == `LOAD ?
                ((ALU_out != `UART_CTRL && ALU_out != `UART_RX &&
                ALU_out != `UART_CC && ALU_out != `UART_IC &&
                ALU_out != `UART_TX && ALU_out != `UART_RST) ? 1 : 0) : 0;

    assign data_out_ready = (ex_state == `LOAD && ALU_out == `UART_RX) ? 1 : 0;
    assign data_in_valid = (ex_state == `STORE && ALU_out == `UART_TX) ? 1 : 0;

    // assign MMapSel = ex_state == `BRANCH || ex_state == `JAL || ex_state == `JAL ? 6 : 
    //                 ex_state == `STORE ? 2 : 7;



    always @(*) begin
        case (ex_state)
        `LOAD: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `ADD;
            SSel = 3; // Not SW, SB, or SH
            InstSel = 0;
            PCSel = 0;

            CSREn = 0;
            CSRSel = 0;

            MMapSel = 1;

        end
        `STORE: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `ADD;
            SSel = ex_inst_reg[13:12];
            InstSel = 0;
            PCSel = 0;

            CSREn = 0;
            CSRSel = 0;

            MMapSel = 2;

        end
        `BRANCH: begin
            ASel = 1;
            BSel = 1;
            ALUSel = `ADD;
            SSel = 3;

            // // Naive Branch Prediction, Assume Not Taken
            InstSel = 0;

            // Always Stall
            // InstSel = 1;

            // This encoding can be minimized further
            case (ex_inst_reg[14:12])
                `BEQ: PCSel = BrEq ? 1 : 0;
                `BNE: PCSel = !BrEq ? 1 : 0;
                `BLT: PCSel = BrLt ? 1 : 0;
                `BGE: PCSel = !BrLt ? 1 : 0;
                `BLTU: PCSel = BrLt ? 1 : 0;
                `BGEU: PCSel = !BrLt ? 1 : 0;
                default: PCSel = 0;
            endcase

            CSREn = 0;
            CSRSel = 0;

            // We assume not taken, so NOP injected if PCSel == 1
            MMapSel = PCSel == 1 ? 6 : 7;

        end
        `JALR: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `ADD;
            SSel = 3;
            InstSel = 1;
            PCSel = 1;

            CSREn = 0;
            CSRSel = 0;

            MMapSel = 6;

        end
        `JAL: begin
            ASel = 1;
            BSel = 1;
            ALUSel = `ADD;
            SSel = 3;
            PCSel = 1;
            InstSel = 1;

            CSREn = 0;
            CSRSel = 0;

            MMapSel = 6;


        end
        `R: begin
            ASel = 0;
            BSel = 0;
            ALUSel = {ex_inst_reg[30], ex_inst_reg[14:12]};
            SSel = 3;
            InstSel = 0;
            PCSel = 0;

            CSREn = 0;
            CSRSel = 0;

            MMapSel = 7;

        end
        `I: begin
            ASel = 0;
            BSel = 1;
            //ALUSel should not use ex_inst_reg[30] for ADDI, SLTI, SLTIU, XORI, ORI, ANDI
            ALUSel = (ex_inst_reg[14:12] == 3'b001 || ex_inst_reg[14:12] == 3'b101) ? {ex_inst_reg[30], ex_inst_reg[14:12]} : {1'b0, ex_inst_reg[14:12]};
            SSel = 3;
            InstSel = 0;
            PCSel = 0;

            CSREn = 0;
            CSRSel = 0;

            MMapSel = 7;


         end
        `AUIPC: begin
            ASel = 1;
            BSel = 1;

            ALUSel = `ADD;
            SSel = 3;
            InstSel = 0;
            PCSel = 0;

            CSREn = 0;
            CSRSel = 0;

            MMapSel = 7;



         end
        `LUI: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `B;
            SSel = 3;
            InstSel = 0;
            PCSel = 0;

            CSREn = 0;
            CSRSel = 0;

            MMapSel = 7;

        end
        `CSRW: begin
            ASel = 0;
            BSel = 0;
            ALUSel = `B;
            SSel = 3;
            InstSel = 0;
            PCSel = 0;

            CSREn = 1;
            CSRSel = ex_inst_reg[14];

            MMapSel = 7;

        end
        `RST: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `B;
            SSel = 3;
            InstSel = 1;
            PCSel = 2;
            CSREn = 0;
            CSRSel = 0;

            MMapSel = 7;

        end
        default: begin
            ASel = 0;
            BSel = 1;
            ALUSel = `B;
            SSel = 3;
            InstSel = 1;
            PCSel = 0;
            CSREn = 0;
            CSRSel = 0;
            MMapSel = 7;

        end
        endcase
    end

    always @(*) begin
        case (mem_wb_state)
        `LOAD: begin
            LdSel = mem_wb_inst_reg[14:12];
            WBSel = 0;
            // Set RegWrEn when ALU_out's first 4 bits are 4’b00x1
            // Make sure it will not load data from DMEM to register
            // when load address is not DMEM

            // Load should stilll occur on mem mapped io instruction
            RegWrEn = (ALU_out_mem[31:28] == 4'b0011 || ALU_out_mem[31:28] == 4'b0001 || 
                    ALU_out_mem[31:28] == 4'b0100 || ALU_out_mem[31:28] == 4'b1000) ? 1 : 0;
            // It is okay to just use 4'b1000 for mmap

        end
        `STORE: begin
            LdSel = 7;
            WBSel = `WBSEL_X; // Doesn't matter, since RegWrEn == 0
            RegWrEn = 0;


        end
        `BRANCH: begin
            LdSel = 7;
            WBSel = `WBSEL_X;
            RegWrEn = 0;


        end
        `JALR: begin
            LdSel = 7;
            WBSel = 2;
            RegWrEn = 1;



        end
        `JAL: begin
            LdSel = 7;
            WBSel = 2;
            RegWrEn = 1;


        end
        `R: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;

        end
        `I: begin
            LdSel = 7;
            WBSel = 1;

            // Disable RegWrEn if injected control nop
            RegWrEn = mem_wb_inst_reg != `CONTROL_NOP ? 1 : 0;

        end
        `AUIPC: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;



        end
        `LUI: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;



        end
        `CSRW: begin
            LdSel = 7;
            WBSel = `WBSEL_X;
            RegWrEn = 0;

        end
        `RST: begin
            LdSel = `LOAD_X;
            WBSel = 0;
            RegWrEn = 0;

        end
        default: begin
            LdSel = `LOAD_X;
            WBSel = 0;
            RegWrEn = 0;


        end
        endcase
    end

endmodule
