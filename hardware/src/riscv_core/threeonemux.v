module threeonemux (
    input [1:0] sel,
    input [31:0] s0,
    input [31:0] s1,
    input [31:0] s2,
    output [31:0] out
);
    assign out = (sel == 0) ? s0 : (sel == 1) ? s1 : s2;
endmodule
