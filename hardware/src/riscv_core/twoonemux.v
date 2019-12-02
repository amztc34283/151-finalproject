module twoonemux #(
    parameter BUS_WIDTH = 32
)(
    input sel,
    input [BUS_WIDTH-1:0] s0,
    input [BUS_WIDTH-1:0] s1,
    output [BUS_WIDTH-1:0] out
);
    assign out = sel ? s1 : s0;
endmodule
