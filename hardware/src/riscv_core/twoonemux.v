module twoonemux (
    input sel,
    input [31:0] s0,
    input [31:0] s1,
    input rst,
    output [31:0] out
);
    assign out = rst ? 0 : sel ? s1 : s0;
endmodule
