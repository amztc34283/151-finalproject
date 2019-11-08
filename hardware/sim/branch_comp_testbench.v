`timescale 1ns/100ps

`define CLK_PERIOD 8
`define DATA_WIDTH 32
`define FIFO_DEPTH 8

module branch_comp_testbench ();

    reg [31:0] ra1 = 0;
    reg [31:0] ra2 = 0;
    reg BrUn = 0;
    wire BrEq;
    wire BrLT;

    branch_comp DUT(.ra1(ra1),
                    .ra2(ra2),
                    .BrUn(BrUn),
                    .BrEq(BrEq),
                    .BrLT(BrLT));

    initial begin
        //Zero unsigned and signed comparison
        ra1 = 0;
        ra2 = 0;
        BrUn = 0;
        #1;
        if (BrEq != 1 || BrLT != 0) begin
            $display("BrEq should be 1.");
        end
        BrUn = 1;
        #1;
        if (BrEq != 1 || BrLT != 0) begin
            $display("BrEq should be 1.");
        end

        //-1 and -2 comparison
        ra1 = 32'hffffffff; //-1
        ra2 = 32'hfffffffe; //-2
        BrUn = 0;
        #1;
        if (BrEq != 0 || BrLT != 0) begin
            $display("BrEq and BrLT should be 0");
        end
        //MAX and MAX-1 comparison
        BrUn = 1;
        #1;
        if (BrEq != 0 || BrLT != 0) begin
            $display("BrEq and BrLT should be 0");
        end

        //-1 and 1 comparison
        ra1 = 32'hffffffff; //-1
        ra2 = 32'h00000001; //1
        BrUn = 0;
        #1;
        if (BrEq != 0 || BrLT != 1) begin
            $display("BrEq should be 0 and BrLT should be 1");
        end
        //MAX and 1 comparison
        BrUn = 1;
        #1;
        if (BrEq != 0 || BrLT != 0) begin
            $display("BrEq and BrLT should be 0");
        end
        $finish();
    end

endmodule
