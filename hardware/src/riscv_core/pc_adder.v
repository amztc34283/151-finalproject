module pc_addr #(parameter BUS_WIDTH = 32) (
    input [BUS_WIDTH - 1:0] PC,
    output [BUS_WIDTH - 1:0] PC_out
);

    assign PC_out = PC + 1;

endmodule
