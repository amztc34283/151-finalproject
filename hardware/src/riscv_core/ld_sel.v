`define LOAD_BYTE 0
`define LOAD_HALFWORD 1
`define LOAD_WORD 2

module ld_sel(
    input [2:0] sel,
    input [31:0] din,
    output reg [31:0] dout
);

    always @( * ) begin
        case (sel)
            //Load Byte
            `LOAD_BYTE  : dout = din[0 +: 8];
            //Load Half
            `LOAD_HALFWORD  : dout = din[0 +: 16];
            //Load Word
            `LOAD_WORD  : dout = din[0 +: 32];
            default : dout = 0;
        endcase
    end

endmodule
