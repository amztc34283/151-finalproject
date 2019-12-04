`define LOAD_BYTE 0
`define LOAD_HALFWORD 1
`define LOAD_WORD 2
`define LOAD_UNSIGNED_BYTE 4
`define LOAD_UNSIGNED_HALFWORD 5

/**
sel - select the correct format of data to be loaded
offset - DMEM address last two bits
**/
module ld_sel(
    input [2:0] sel,
    input [31:0] din,
    input [4:0] offset,
    output reg [31:0] dout
);
    wire [31:0] offset_din;
    wire [4:0] offset_extend;

    //offset * 8
    assign offset_extend = (offset << 3);

    //shift right din by offset_extend
    assign offset_din = din >> offset_extend;

    // 1010 1111 0000 1100 1100 1111 0000 0011
    // offset 3
    // sel 0
    // 1111 1111 1111 1111 1111 1111 1010 1111
    // offset 3
    // sel 3
    // 0000 0000 0000 0000 0000 0000 1010 1111

    always @( * ) begin
        case (sel)
            `LOAD_BYTE : dout = {{24{offset_din[7]}}, offset_din[0 +: 8]};
            `LOAD_HALFWORD : dout = {{16{offset_din[15]}}, offset_din[0 +: 16]};
            `LOAD_WORD : dout = offset_din[0 +: 32];
            `LOAD_UNSIGNED_BYTE : dout = {{24{1'b0}}, offset_din[0 +: 8]};
            `LOAD_UNSIGNED_HALFWORD : dout = {{16{1'b0}}, offset_din[0 +: 16]};
            default : dout = 0;
        endcase
    end

endmodule
