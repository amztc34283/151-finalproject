`timescale 1ns/100ps

`define ALU_ADDI 0
`define ALU_SLTI 1
`define ALU_SLTIU 2
`define ALU_XORI 3
`define ALU_ORI 4
`define ALU_ANDI 5
`define ALU_SLLI 6
`define ALU_SRLI 7
`define ALU_SRAI 8 
`define ALU_ADD 9
`define ALU_SUB 10
`define ALU_SLL 11
`define ALU_SLT 12
`define ALUT_SLTU 13
`define ALU_XOR 14
`define ALU_SRL 15
`define ALU_SRA 16
`define ALU_OR 17
`define ALU_AND 18

module alu_tb();
    reg [31:0] in1, in2;
    reg [4:0] select;
    wire [31:0] out;

    alu DUT_alu(.op1(in1), .op2(in2), .sel(select), .res(out));

    initial begin
        select = 0;
        in1 = 0;
        in2 = 0;

        // Test addi
        // ADDI rd,rs1,imm	Add Immediate	rd  <- rs1 + sx(imm)
        #(5);
        select = `ALU_ADDI;
        in1 = 1;
        in2 = -2;
        #(1);
        if (out != -1)
            $display("addi failed; output=%d, expected=%d", $signed(out), -1);

        #(5);
        in1 = -100;
        in2 = -2;
        #(1);
        if (out != -102)
            $display("addi failed; output=%d, expected=%d", $signed(out), -102);

        // addi overflow
        // "Arithmetic overflow is ignored and the result is simply the low XLEN bits of the result" -risc5 spec
        #(5)
        in1 = 2**(32) - 1;
        in2 = 5;
        #(1)
        if (out != 4)
            $display("addi failed; output=%d, expected=%d", $signed(out), 5);

        #(5)
        in1 = 2**(31);
        in2 = 2**(31) + 1;
        #(1)
        if (out != 1)
            $display("addi failed; output=%d, expected=%d", $signed(out), 1);


        #(5)
        in1 = 2**(32) - 1;
        in2 = -1;
        #(1)
        if (out != 2**(32) - 2)
            $display("addi failed; output=%d, expected=%d", $signed(out),  2**(32) - 2);

        // test for slti
        // SLTI rd,rs1,imm	Set Less Than Immediate	rd <- sx(rs1) < sx(imm)

        #(5)
        select = `ALU_SLTI;
        in1 = -3;
        in2 = -4;
        #(1)
        if (out != 0)
             $display("slti failed; output=%d, expected=%d", $signed(out),  0);

        #(5)
        in1 = -5;
        in2 = -4;
        #(1)
        if (out != 1)
             $display("slti failed; output=%d, expected=%d", $signed(out),  1);

        #(5)
        in1 = 1;
        in2 = -4;
        #(1)
        if (out != 0)
             $display("slti failed; output=%d, expected=%d", $signed(out),  0);

        #(5)
        in1 = -4;
        in2 = 1;
        #(1)
        if (out != 1)
             $display("slti failed; output=%d, expected=%d", $signed(out),  1);

        #(5)
        in1 = -2**31;
        in2 = -2**31;
        #(1)
        if (out != 0)
             $display("slti failed; output=%d, expected=%d", $signed(out),  0);

        // test for sltiu
        // SLTIU rd,rs1,imm	Set Less Than Immediate Unsigned	rd <- ux(rs1) < ux(imm)

        // "...compares the values as unsigned numbers (i.e., the immediate is first sign-extended to
        // XLEN bits then treated as an unsigned number) " -riscv spec

        #(5)
        select = `ALU_SLTIU;
        in1 = -3;
        in2 = -4;
        #(1)
        if (out != 0)
             $display("sltiu failed; output=%d, expected=%d", $signed(out),  0);

        #(5)
        in1 = -5;
        in2 = -4;
        #(1)
        if (out != 1)
             $display("sltiu failed; output=%d, expected=%d", $signed(out),  1);

        #(5)
        in1 = 1;
        in2 = -4;
        #(1)
        if (out != 1)
             $display("sltiu failed; output=%d, expected=%d", $signed(out),  1);

        #(5)
        in1 = -4;
        in2 = 1;
        #(1)
        if (out != 0)
             $display("sltiu failed; output=%d, expected=%d", $signed(out),  0);

        #(5)
        in1 = -2**31;
        in2 = -2**31;
        #(1)
        if (out != 0)
             $display("sltiu failed; output=%d, expected=%d", $signed(out),  0);

        // test for xori
        // XORI rd,rs1,imm	Or Immediate	rd <- ux(rs1) ∨ ux(imm)
        #(5)
        select = `ALU_XORI;
        in1 = 0;
        in2 = -1;
        #(1)
        if (out != -1)
            $display("xori failed; output=%d, expected=%d", $signed(out), -1);
        
        #(5)
        in1 = -1;
        in2 = -1;
        #(1)
        if (out != 0)
            $display("xori failed; output=%d, expected=%d", $signed(out), 0);

        #(5)
        in1 = -1;
        in2 = 32'b10101010101010101010101010101010;
        #(1)
        if (out != 32'b01010101010101010101010101010101)
            $display("xori failed; output=%d, expected=%d", $signed(out), 32'b01010101010101010101010101010101);
        

        // test for ori
        // ORI rd,rs1,imm	Or Immediate	rd <- ux(rs1) ∨ ux(imm)
        #(5)
        select = `ALU_ORI;
        in1 = 32'b10101010101010101010101010101010;
        in2 = 32'b10101010101010101010101010101010;
        #(1)
        if (out != 32'b10101010101010101010101010101010)
            $display("ori failed; output=%d, expected=%d", $signed(out), 32'b10101010101010101010101010101010);

        #(5)
        in1 = 0;
        in2 = -1;
        #(1)
        if (out != -1)
            $display("ori failed; output=%d, expected=%d", $signed(out), -1);


        // test for andi
        // ANDI rd,rs1,imm	And Immediate	rd <- ux(rs1) ∧ ux(imm)
        #(5)
        select = `ALU_ANDI;
        in1 = 0;
        in2 = -1;
        #(1)
        if (out != 0)
            $display("andi failed; output=%d, expected=%d", $signed(out), 0);

        #(5)
        in1 = -1;
        in2 = -1;
        #(1)
        if (out != -1)
            $display("andi failed; output=%d, expected=%d", $signed(out), -1);

        #(5)
        in1 = 32'b10101010101010101010101010101010;
        in2 = 32'b01010101010101010101010101010101;
        #(1)
        if (out != 0)
            $display("andi failed; output=%d, expected=%d", $signed(out), 0);


        // test for slli
        // SLLI rd,rs1,imm	Shift Left Logical Immediate	rd <- ux(rs1) « ux(imm)
        #(5)
        select = `ALU_SLLI;
        in1 = -1;
        in2 = 2**5 - 1;
        #(1)
        if (out != 2**31)
            $display("slli failed; output = %d, expected=%d", $signed(out), 2**31);

        in1 = -1;
        in2 = 32;
        #(1)
        if (out != 0)
            $display("slli failed; output = %d, expected=%d", $signed(out), 0);


        #(5)
        in1 = -1;
        in2 = 1;
        #(1)
        if (out != -2)
            $display("slli failed; output = %d, expected=%d", $signed(out), -2);

        #(5)
        in1 = -1;
        in2 = 2;
        #(1)
        if (out != -4)
            $display("slli failed; output = %d, expected=%d", $signed(out), -4);


        // test for srli
        // SRLI rd,rs1,imm	Shift Right Logical Immediate	rd <- ux(rs1) » ux(imm)
        #(5)
        select = `ALU_SRLI;
        in1 = -1;
        in2 = 2**5 - 1;
        #(1)
        if (out != 1)
            $display("slli failed; output = %d, expected=%d", $signed(out), 1);

        #(5)
        in1 = -1;
        in2 = 32;
        #(1)
        if (out != 0)
            $display("slli failed; output = %d, expected=%d", $signed(out), 0);

        #(5)
        in1 = -1;
        in2 = 1;
        #(1)
        if (out != 2**31 - 1)
            $display("slli failed; output = %d, expected=%d", $signed(out), 2**31 - 1);

        #(5)
        in1 = -1;
        in2 = 2;
        #(1)
        if (out != 2**30 - 1)
            $display("slli failed; output = %d, expected=%d", $signed(out),  2**30 - 1);

        // test for srai
        // SRAI rd,rs1,imm	Shift Right Arithmetic Immediate	rd <- sx(rs1) » ux(imm)
        // "...  SRAI is an arithmetic right shift (the original sign bit is copied into the vacated upper bits)."
        #(5)
        select = `ALU_SRAI;
        in1 = -1;
        in2 = 2**5 - 1;
        #(1)
        if (out != -1)
            $display("srai failed; output = %d, expected=%d", $signed(out), -1);

        #(5)
        in1 = -1;
        in2 = 32;
        #(1)
        if (out != -1)
            $display("srai failed; output = %d, expected=%d", $signed(out), -1);

        #(5)
        in1 = -1;
        in2 = 1;
        #(1)
        if (out != -1)
            $display("srai failed; output = %d, expected=%d", $signed(out), -1);

        #(5)
        in1 = -1;
        in2 = 2;
        #(1)
        if (out != -1)
            $display("srai failed; output = %d, expected=%d", $signed(out),  -1);

        // test for add
        // ADD rd,rs1,rs2	Add	rd <- sx(rs1) + sx(rs2)
        // "... Overflows are ignored and the low XLEN bits of results are written to the destination"
        // observe add and addi have the same semantics from the RISCV-ALU perspective, overflow is ignored
        #(5);
        select = `ALU_ADD;
        in1 = 1;
        in2 = -2;
        #(1);
        if (out != -1)
            $display("add failed; output=%d, expected=%d", $signed(out), -1);

        #(5);
        in1 = -100;
        in2 = -2;
        #(1);
        if (out != -102)
            $display("add failed; output=%d, expected=%d", $signed(out), -102);

        // add overflow
        // "Arithmetic overflow is ignored and the result is simply the low XLEN bits of the result" -risc5 spec
        #(5)
        in1 = 2**(32) - 1;
        in2 = 5;
        #(1)
        if (out != 4)
            $display("add failed; output=%d, expected=%d", $signed(out), 4);

        #(5)
        in1 = 2**(31);
        in2 = 2**(31) + 1;
        #(1)
        if (out != 1)
            $display("add failed; output=%d, expected=%d", $signed(out), 1);

        #(5)
        in1 = 2**(32) - 1;
        in2 = -1;
        #(1)
        if (out != 2**(32) - 2)
            $display("add failed; output=%d, expected=%d", $signed(out),  2**(32) - 2);

        #(5)
        in1 = 2**31;
        in2 = 2**31;
        #(1)
        if (out != 0)
            $display("add failed; output=%d, expected=%d", $signed(out),  0);


        // test for sub
        // SUB rd,rs1,rs2	Subtract	rd <- sx(rs1) - sx(rs2)
        #(5);
        select = `ALU_SUB;
        in1 = 1;
        in2 = -2;
        #(1);
        if (out != 3)
            $display("sub failed; output=%d, expected=%d", $signed(out), 3);

        #(5);
        in1 = -100;
        in2 = -2;
        #(1);
        if (out != -98)
            $display("sub failed; output=%d, expected=%d", $signed(out), -98);

        // sub overflow
        // "Arithmetic overflow is ignored and the result is simply the low XLEN bits of the result" -risc5 spec
        #(5)
        in1 = 2**(32) - 1;
        in2 = -5;
        #(1)
        if (out != 4)
            $display("sub failed; output=%d, expected=%d", $signed(out), 4);

        #(5)
        in1 = -1;
        in2 = 1;
        #(1)
        if (out != -2)
            $display("sub failed; output=%d, expected=%d", $signed(out), -2);

        #(5)
        in1 = -1;
        in2 = 2**31 - 1;
        #(1)
        if (out != 2**31)
            $display("sub failed; output=%d, expected=%d", $signed(out), 8);
        //   1111 1111
        // + 1000 0001
        //   1000 0000

        #(5)
        in1 = 0;
        in2 = 2**31;
        #(1)
        if (out != 2**31)
            $display("sub failed; output=%d, expected=%d", $signed(out),  2**31);

        // test for sll
        // SLL rd,rs1,rs2	Shift Left Logical	rd <- ux(rs1) « rs2

        // test for slt
        // SLT rd,rs1,rs2	Set Less Than	rd <- sx(rs1) < sx(rs2)

        // test for sltu
        // SLTU rd,rs1,rs2	Set Less Than Unsigned	rd <- ux(rs1) < ux(rs2)

        // test for xor
        // XOR rd,rs1,rs2	Xor	rd <- ux(rs1) ⊕ ux(rs2)

        // test for srl
        // SRL rd,rs1,rs2	Shift Right Logical	rd <- ux(rs1) » rs2

        // test for sra
        // SRA rd,rs1,rs2	Shift Right Arithmetic	rd <- sx(rs1) » rs2

        // test for or
        // OR rd,rs1,rs2	Or	rd <- ux(rs1) ∨ ux(rs2)

        // test for and
        // AND rd,rs1,rs2	And	rd <- ux(rs1) ∧ ux(rs2)
        $finish();

    end

endmodule



