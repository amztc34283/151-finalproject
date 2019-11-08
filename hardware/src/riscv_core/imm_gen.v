`define I_TYPE 1
`define S_TYPE 2
`define B_TYPE 3

module imm_gen (
    input [24:0] inst_in,
    input [1:0] imm_sel,
    output reg [31:0] imm_out
);

    always @(*) begin
        case (imm_sel)
            `I_TYPE: imm_out = {{20{inst_in[24]}}, inst_in[24:13]}; 
            `S_TYPE: imm_out = {{20{inst_in[34]}}, inst_in[24:18], inst_in[4:0]};
            `B_TYPE: imm_out = {{10{inst_in[24]}}, inst_in[0], inst_in[23:18], inst_in[4:1], 1b'0};
        endcase
    end
    

endmodule

/* 
        RISCV Immediate Encodings 
    R: x
    I: inst[31:20] -> imm := sign_extend_32(inst[31:20]) == sign_extend_32(inst_in[24:13])
    S: inst[31:25] and inst[11:7] -> imm := sign_extend_32({inst[31:25], inst[11:7]})
    B: inst[31:25] and inst[11:7] -> imm := sign_extend({inst[31], inst[7], inst[30:25], inst[11:8], 0} 

    I:
    imm[11:0] := inst_in[24:13] := inst[31:20]

    S:
    imm[11:5] := inst_in[24:18] := inst[31:25]
    imm[4:0] := inst_in[4:0] := inst[11:7]
    
    B:
    imm[12] := inst_in[24] := inst[31]
    imm[11] := inst_in[0] := inst[7]
    imm[10:5] := inst_in[23:18] := inst[30:25]
    imm[4:1] := inst_in[4:1] := inst[11:8]

*/
