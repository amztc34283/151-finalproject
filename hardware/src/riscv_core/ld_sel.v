module ld_sel(
    input [2:0] sel,
    input [31:0] din,
    output reg [31:0] dout
);

    always @( * ) begin
        case (sel)
            //Load Byte
            2'b000  : dout = din[0 +: 8];
            //Load Half
            2'b001  : dout = din[0 +: 16];
            //Load Word
            2'b010  : dout = din[0 +: 32];
            default : dout = 0;
        endcase
    end

endmodule
