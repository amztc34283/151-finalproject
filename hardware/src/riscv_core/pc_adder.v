module pc_addr (
    input [31:0] PC,
    output [31:0] PC_out
);

    assign PC_out = PC + 4;

endmodule