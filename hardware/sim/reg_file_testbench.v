`timescale 1ns/100ps

`define CLK_PERIOD 8
`define DATA_WIDTH 32
`define FIFO_DEPTH 8

module reg_file_testbench();

    reg clk = 0;
    reg we = 0;
    reg [4:0] ra1 = 0;
    reg [4:0] ra2 = 0;
    reg [4:0] wa = 0;
    reg [31:0] wd = 0;
    wire [31:0] rd1;
    wire [31:0] rd2;

    //Running 125MHz
    always #(`CLK_PERIOD/2) clk <= ~clk;

    reg_file DUT(.clk(clk),
                 .we(we),
                 .ra1(ra1),
                 .ra2(ra2),
                 .wa(wa),
                 .wd(wd),
                 .rd1(rd1),
                 .rd2(rd2));

    initial begin
        //Basic Asynchronous Read
        we = 0;
        ra1 = 1;
        ra2 = 2;
        #1;
        if (rd1 != 0 && rd2 != 0) begin
            $display("Failed First Test Case");
        end
        //x0 = 0, x1 = 0, x2 = 0

        //Write something to x0 and check it is still zero
        we = 1;
        wd = 1;
        wa = 0;
        @(posedge clk);
        ra1 = 0;
        #1;
        if (rd1 != 0) begin
            $display("Failed Second Test Case");
        end
        //x0 = 0, x1 = 0, x2 = 0

        //Write something to register then read
        we = 1;
        wd = 1;
        wa = 1;
        @(posedge clk);
        ra1 = 1;
        #1;
        if (rd1 != 1) begin
            $display("Failed Third Test Case");
        end
        //x0 = 0, x1 = 1, x2 = 0

        $finish();
    end

endmodule
