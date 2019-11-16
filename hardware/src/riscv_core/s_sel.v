`define STORE_BYTE 0
`define STORE_HALFWORD 1
`define STORE_WORD 2
`define BYTE 4'b0001
`define HALF_WORD 4'b0011
`define WORD 4'b1111

module s_sel (
    input [1:0] sel,
    input [1:0] offset,
    input [31:0] rs2,
    output reg [3:0] dmem_we,
    output [31:0] dmem_din
);

    // sb x1, 2(x2);
    // want to store 1111 1111
    // offset 2
    // sel 0
    // x2 -> 0000 1111 1111 0000 0101 0000 1010 1111
    // shift 0000 0000 1111 1111 0000 0000 0000 0000
    // dmem_we 0 1 0 0
    // x2 -> 0000 1111 1111 1111 0101 0000 1010 1111

    // want to store 0011 1100 1100 0011
    // offset 1
    // sel 1
    // x2 -> 0000 1111 1111 0000 0101 0000 1010 1111
    // shift 0000 0000 0011 1100 1100 0011 0000 0000
    // dmem_we 0 1 1 0
    // x2 -> 0000 1111 0011 1100 1100 0011 1010 1111

    assign dmem_din = rs2 << (offset*8);

    always @ ( * ) begin
        case (sel)
            `STORE_BYTE: dmem_we = 4'b0001 << offset;
            `STORE_HALFWORD: dmem_we = 4'b0011 << offset;
            `STORE_WORD: dmem_we = 4'b1111 << offset;
            default: dmem_we = 4'b0000;
        endcase
    end

endmodule
