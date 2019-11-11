`timescale 1ns/100ps

`define CLK_PERIOD 8
`define DATA_WIDTH 32
`define FIFO_DEPTH 8

module twoonemux_testbench();
    reg sel = 0;
    reg [31:0] s0 = 0;
    reg [31:0] s1 = 0;
    wire [31:0] out;

    twotoonemux DUT(.sel(sel),
                .s0(s0),
                .s1(s1),
                .out(out));

    initial begin
        sel = 0;
        s0 = 1;
        #1;
        if (out != 1) begin
            $display("select 0 failed");
        end

        sel = 1;
        s1 = 2;
        #1;
        if (out != 2) begin
            $display("select 1 failed");
        end
    end

endmodule
