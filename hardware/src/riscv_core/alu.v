`define ALU_ADDI 0
`define ALU_SLTI 1
`define ALU_SLTIU 2
`define ALU_XORI 3
`define ALU_ORI 4
`define ALU_ANDI 5
`define ALU_SLLI 6
`define ALU_SRAI 7 
`define ALU_ADD 8
`define ALU_SUB 9
`define ALU_SLL 10
`define ALU_SLA 11
`define ALU_SLT 12
`define ALUT_SLTU 13
`define ALU_XOR 14
`define ALU_SRL 15
`define ALU_SRA 16
`define ALU_OR 17
`define ALU_AND 18


module alu (
    input [31:0] op1, op2,
    input [4:0] sel,
    output reg [31:0] res
);

    always @(*) begin
        case(sel)
            `ALU_ADDI:  res = ($signed(op1)) + ($unsigned(op2));                // 0
            `ALU_SLTI:  res = ($signed(op1)) < ($signed(op2)) ? 1 : 0;          // 1
            `ALU_SLTIU: res = ($unsigned(op1)) < ($unsigned(op2)) ? 1 : 0;      // 2
            `ALU_XORI:  res = ($unsigned(op1)) ^ ($unsigned(op2));              // 3
            `ALU_ORI:   res = ($unsigned(op1)) | ($unsigned(op2));              // 4
            `ALU_ANDI:  res = ($unsigned(op1)) & ($unsigned(op2));              // 5
            `ALU_SLLI:  res = ($unsigned(op1))  << ($unsigned(op2[5:0]));       // 6
            `ALU_SRLI:  res = ($unsigned(op1)) >> ($unsigned(op2[5:0]));        // 7
            `ALU_SRAI:  res = ($signed(op1)) >>> ($unsigned(op2[5:0]));         // 8
            `ALU_ADD:   res = ($signed(op1)) + ($signed(op2));                  // 9
            `ALU_SUB:   res = ($signed(op1)) - ($signed(op2));                  // 10
            `ALU_SLL:   res = ($unsigned(op1)) << op2[5:0];                     // 11
            `ALU_SLT:   res = ($signed(op1)) < ($signed(op2)) ? 1 : 0;          // 13
            `ALUT_SLTU: res = ($unsigned(op1)) < ($unsigned(op2)) ? 1 : 0;      // 14
            `ALU_XOR:   res = ($unsigned(op1)) ^ ($unsigned(op2));              // 15
            `ALU_SRL:   res = ($unsigned(op1)) >> op2[5:0];                     // 16
            `ALU_SRA:   res = ($signed(op1)) >>> op2[5:0];                      // 17
            `ALU_OR:    res = ($unsigned(op1)) | ($unsigned(op2));              // 18
            `ALU_AND:   res = ($unsigned(op1)) & ($unsigned(op2));              // 19
        endcase
    end
endmodule


// pc	program counter
// rd	integer register destination
// rsN	integer register source N
// imm	immediate operand value
// offset	immediate program counter relative offset
// ux(reg)	unsigned XLEN-bit integer (32-bit on RV32, 64-bit on RV64)
// sx(reg)	signed XLEN-bit integer (32-bit on RV32, 64-bit on RV64)
// uN(reg)	zero extended N-bit integer register value
// sN(reg)	sign extended N-bit integer register value
// uN[reg + imm]	unsigned N-bit memory reference
// sN[reg + imm]	signed N-bit memory reference



// LUI rd,imm	Load Upper Immediate	rd �? imm
// AUIPC rd,offset	Add Upper Immediate to PC	rd �? pc + offset
// JAL rd,offset	Jump and Link	rd �? pc + length(inst)
// pc �? pc + offset
// JALR rd,rs1,offset	Jump and Link Register	rd �? pc + length(inst)
// pc �? (rs1 + offset) ∧ -2
// BEQ rs1,rs2,offset	Branch Equal	if rs1 = rs2 then pc �? pc + offset
// BNE rs1,rs2,offset	Branch Not Equal	if rs1 ≠ rs2 then pc �? pc + offset
// BLT rs1,rs2,offset	Branch Less Than	if rs1 < rs2 then pc �? pc + offset
// BGE rs1,rs2,offset	Branch Greater than Equal	if rs1 ≥ rs2 then pc �? pc + offset
// BLTU rs1,rs2,offset	Branch Less Than Unsigned	if rs1 < rs2 then pc �? pc + offset
// BGEU rs1,rs2,offset	Branch Greater than Equal Unsigned	if rs1 ≥ rs2 then pc �? pc + offset
// LB rd,offset(rs1)	Load Byte	rd �? s8[rs1 + offset]
// LH rd,offset(rs1)	Load Half	rd �? s16[rs1 + offset]
// LW rd,offset(rs1)	Load Word	rd �? s32[rs1 + offset]
// LBU rd,offset(rs1)	Load Byte Unsigned	rd �? u8[rs1 + offset]
// LHU rd,offset(rs1)	Load Half Unsigned	rd �? u16[rs1 + offset]
// SB rs2,offset(rs1)	Store Byte	u8[rs1 + offset] �? rs2
// SH rs2,offset(rs1)	Store Half	u16[rs1 + offset] �? rs2
// SW rs2,offset(rs1)	Store Word	u32[rs1 + offset] �? rs2
// ADDI rd,rs1,imm	Add Immediate	rd �? rs1 + sx(imm)
// SLTI rd,rs1,imm	Set Less Than Immediate	rd �? sx(rs1) < sx(imm)
// SLTIU rd,rs1,imm	Set Less Than Immediate Unsigned	rd �? ux(rs1) < ux(imm)
// XORI rd,rs1,imm	Xor Immediate	rd �? ux(rs1) ⊕ ux(imm)
// ORI rd,rs1,imm	Or Immediate	rd �? ux(rs1) ∨ ux(imm)
// ANDI rd,rs1,imm	And Immediate	rd �? ux(rs1) ∧ ux(imm)
// SLLI rd,rs1,imm	Shift Left Logical Immediate	rd �? ux(rs1) « ux(imm)
// SRLI rd,rs1,imm	Shift Right Logical Immediate	rd �? ux(rs1) » ux(imm)
// SRAI rd,rs1,imm	Shift Right Arithmetic Immediate	rd �? sx(rs1) » ux(imm)
// ADD rd,rs1,rs2	Add	rd �? sx(rs1) + sx(rs2)
// SUB rd,rs1,rs2	Subtract	rd �? sx(rs1) - sx(rs2)
// SLL rd,rs1,rs2	Shift Left Logical	rd �? ux(rs1) « rs2
// SLT rd,rs1,rs2	Set Less Than	rd �? sx(rs1) < sx(rs2)
// SLTU rd,rs1,rs2	Set Less Than Unsigned	rd �? ux(rs1) < ux(rs2)
// XOR rd,rs1,rs2	Xor	rd �? ux(rs1) ⊕ ux(rs2)
// SRL rd,rs1,rs2	Shift Right Logical	rd �? ux(rs1) » rs2
// SRA rd,rs1,rs2	Shift Right Arithmetic	rd �? sx(rs1) » rs2
// OR rd,rs1,rs2	Or	rd �? ux(rs1) ∨ ux(rs2)
// AND rd,rs1,rs2	And	rd �? ux(rs1) ∧ ux(rs2)

// addi
// sluti
// sltiu
// sltiu
// xori
// ori
// andi
// slli
// srli
// srai
// add
// sub
// sll
// slt
// sltu
// xor
// srl
// sra
// or 
// and

// add
// sub
// logical shift left
// logical shift right
// arithmetic shift left
// arithmetic shift right
// set less than
// set less than unsigned
// and
// or
// xor


// reg [31:0] registers [0:31];
// assign rd1 = 32'd0;
// assign rd2 = 32'd0;

// module rv64_alu(
// input [63:0] a,
// input [63:0] b,
// input [2:0] op,
// output [63:0] c,
// );
// wire [31:0] addw = a[31:0] + b[31:0];
// wire [31:0] subw = a[31:0] - b[31:0];
// wire [31:0] sllw = a[31:0] << b[4:0];
// wire [31:0] sraw = $signed(a[31:0]) >>> b[4:0];
// always @(*) begin
// case (op)
// `ALU_ADD: c = a + b;
// `ALU_ADDW: c = {32{addw[31]}, addw};
// `ALU_SUB: c = a - b;
// `ALU_SUBW: c = {32{subw[31]}, subw};
// `ALU_SLL: c = a << b[5:0];
// `ALU_SLLW: c = {32{sllw[31], sllw};
// `ALU_SRA: c = $signed(a) >>> b[5:0];
// `ALU_SRAW: c= {32{sraw[31]}, sraw};
// endcase
// end
// endmodule
