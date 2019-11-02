module reg_file (
    input clk,
    input we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] registers [0:31];

    //Initialize all registers to zero
    integer i;
    initial begin
        for (i = 1; i < 32; i = i + 1)
            registers[i] = 0;
    end

    //Synchronous Write
    //x0 is always 0 in RISC-V
    always @ (posedge clk) begin
        if (we && wa != 0) begin
            registers[wa] <= wd;
        end
    end

    //Asynchronous Read
    assign rd1 = registers[ra1];
    assign rd2 = registers[ra2];

endmodule
