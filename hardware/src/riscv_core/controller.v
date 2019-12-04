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

// imm_gen control signals
`define I_TYPE 1
`define S_TYPE 2
`define B_TYPE 3
`define U_TYPE 4
`define J_TYPE 5
`define X_TYPE 6

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
    output reg [1:0] MMap_DMem_Sel,
    output data_out_ready,
    output data_in_valid
    );

    reg [31:0] ex_inst_reg;
    reg [31:0] mem_wb_inst_reg;

    wire [4:0] ex_state;
    wire [4:0] mem_wb_state;

    reg [31:0] ALU_out_mem;

    // I/O Memory Map Logic

   // Forwarding Logic
   // We wish to forward to FA_2 when instruction in mem/wb uses rd
   // and instruction in execute uses rs1
   assign FA_2 = ex_state == `CSRW ?
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

    // assign FA_2 = (mem_wb_inst_reg[11:7]  != 0) &&
    //             (ex_inst_reg[19:15] != 0) &&
    //             (mem_wb_inst_reg[11:7] == ex_inst_reg[19:15]) &&
    //             ((mem_wb_state != `BRANCH) &&
    //             (mem_wb_state != `STORE) &&
    //             (mem_wb_state != `X)) &&
    //             ((ex_state != `LUI) && (ex_state != `AUIPC) &&
    //             (ex_state != `JAL) && (ex_state != `X));




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

//    assign FA_1 = (mem_wb_inst_reg[11:7] == inst[19:15]) &&
//                 (mem_wb_inst_reg[11:7] != 0) &&
//                 (inst[19:15] != 0) &&
//                 ((mem_wb_state != `BRANCH) &&
//                 (mem_wb_state != `STORE) &&
//                 (mem_wb_state != `X)) &&
//                 ((inst[6:2] != `LUI) && (inst[6:2] != `AUIPC) &&
//                 (inst[6:2] != `JAL) &&  (inst[6:2] != `X));


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
            // ex_inst_reg <= 32'h00000004;
            // mem_wb_inst_reg <= 32'h00000004;
            ex_inst_reg <= RESET_PC + 32'h00000004;
            mem_wb_inst_reg <= RESET_PC + 32'h00000004;
            // [6:2] == 000 0100
            // ex_state <= `RST;
            // mem_wb_state <= `RST;
        end else begin
            ex_inst_reg <= inst;
            mem_wb_inst_reg <= ex_inst_reg;

            // ex_state <= inst[6:2];
            // mem_wb_state <= ex_state;
        end
    end

    always @(posedge clk) begin
        if (rst)
            ALU_out_mem <= 0;
        else
            ALU_out_mem <= ALU_out;
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


    assign BrUn = ex_state == `BRANCH ? (ex_inst_reg[14:13] == 2'b11 ? 1 : 0) : 0;


    assign MemRW = ex_state == `STORE || ex_state == `LOAD ? 
                ((ALU_out != `UART_CTRL && ALU_out != `UART_RX && 
                ALU_out != `UART_CC && ALU_out != `UART_IC &&
                ALU_out != `UART_TX && ALU_out != `UART_RST) ? 1 : 0) : 0;

    assign data_out_ready = (ex_state == `LOAD && ALU_out == `UART_RX) ? 1 : 0;
    assign data_in_valid = (ex_state == `STORE && ALU_out == `UART_TX) ? 1 : 0;


    always @(*) begin
            case (ALU_out) 
                `UART_CTRL : begin 
                    MMapSel = ex_state == `LOAD ? 0 : 7;
                end
                `UART_RX : begin
                    MMapSel = ex_state == `LOAD ? 1 : 7;
                end
                `UART_CC : begin
                    MMapSel = ex_state == `LOAD ? 3 : 7;
                end
                `UART_IC : begin
                    MMapSel = ex_state == `LOAD ? 4 : 7;
                end
                `UART_TX: begin
                    MMapSel = ex_state == `STORE ? 2 : 7;
                end
                `UART_RST: begin 
                    MMapSel = ex_state == `STORE ? 5 : 7;
                end
                default: begin
                    MMapSel = 7;
                end
            endcase    
    end


    always @(*) begin
        case (ex_state)
        `LOAD: begin
            ASel = 0;
            BSel = 1;
            // BrUn = 0; // Doesn't matter
            ALUSel = `ADD;
            // MemRW = 1;
            SSel = 3; // Not SW, SB, or SH
            InstSel = 0;
            PCSel = 0;

            CSREn = 0;
            CSRSel = 0;

            // data_in_valid = 0;

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

        end
        `BRANCH: begin
            ASel = 1;
            BSel = 1;
            ALUSel = `ADD;
            SSel = 3;
            InstSel = 1;
            // This encoding can be minimized further
            case (ex_inst_reg[14:12])
                `BEQ: PCSel = BrEq ? 1 : 2;
                `BNE: PCSel = BrEq ? 2 : 1;
                `BLT: PCSel = BrLt ? 1 : 2;
                `BGE: PCSel = !BrLt ? 1 : 2;
                `BLTU: PCSel = BrLt ? 1 : 2;
                `BGEU: PCSel = !BrLt ? 1 : 2;
                default: PCSel = 0;
            endcase

            CSREn = 0;
            CSRSel = 0;

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
                    ALU_out_mem == `UART_RX || ALU_out_mem == `UART_CTRL || 
                    ALU_out_mem == `UART_CC ||  ALU_out_mem == `UART_IC) ? 1 : 0;

            MMap_DMem_Sel = ALU_out_mem == `UART_RX ? 
                            1 : (ALU_out_mem == `UART_CTRL || 
                                ALU_out_mem == `UART_CC || 
                                ALU_out_mem == `UART_IC ? 2 : 0);

        end
        `STORE: begin
            LdSel = 7;
            WBSel = `WBSEL_X; // Doesn't matter, since RegWrEn == 0
            RegWrEn = 0;

            MMap_DMem_Sel = 0;
            

        end
        `BRANCH: begin
            LdSel = 7;
            WBSel = `WBSEL_X;
            RegWrEn = 0;

            MMap_DMem_Sel = 0;

        end
        `JALR: begin
            LdSel = 7;
            WBSel = 2;
            RegWrEn = 1;

            MMap_DMem_Sel = 0;

        end
        `JAL: begin
            LdSel = 7;
            WBSel = 2;
            RegWrEn = 1;

            MMap_DMem_Sel = 0;

        end
        `R: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;

            MMap_DMem_Sel = 0;

        end
        `I: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;

            MMap_DMem_Sel = 0;

        end
        `AUIPC: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;

            MMap_DMem_Sel = 0;

        end
        `LUI: begin
            LdSel = 7;
            WBSel = 1;
            RegWrEn = 1;

            MMap_DMem_Sel = 0;

        end
        `CSRW: begin
            LdSel = 7;
            WBSel = `WBSEL_X;
            RegWrEn = 0;

            MMap_DMem_Sel = 0;

        end
        `RST: begin
            LdSel = `LOAD_X;
            WBSel = 0;
            RegWrEn = 0;

            MMap_DMem_Sel = 0;
        end
        default: begin
            LdSel = `LOAD_X;
            WBSel = 0;
            RegWrEn = 0;

            MMap_DMem_Sel = 0;

        end
        endcase
    end

endmodule
