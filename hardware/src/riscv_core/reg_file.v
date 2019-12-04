module reg_file (
    input clk,
    input we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] registers [0:31];

    reg [4:0] ex_wa;
    reg [4:0] wb_wa;

    // initial begin
    //     for (i = 0; i < 32; i = i + 1)
    //         registers[i] = 0;
    // end

    //Synchronous Write
    always @ (posedge clk) begin
        if (we) begin
            registers[wb_wa] <= wd;
        end
        ex_wa <= wa;
        wb_wa <= ex_wa;
    end

    //Asynchronous Read
    assign rd1 = ra1 != 5'd0 ? registers[ra1] : 32'd0;
    assign rd2 = ra2 != 5'd0 ? registers[ra2] : 32'd0;

endmodule
