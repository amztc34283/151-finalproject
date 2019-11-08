`timescale 1ns/100ps

`define CLK_PERIOD 8
`define DATA_WIDTH 32
`define FIFO_DEPTH 8

module ld_sel_testbench();

    reg [2:0] sel = 0;
    reg [31:0] din = 0;
    wire [31:0] dout;

    ld_sel DUT(.sel(sel),
               .din(din),
               .dout(dout));

    initial begin
        //Load Byte
        sel = 0;
        din = 32'hffffffff;
        #1;
        if (dout != 32'h000000ff) begin
            $display("Failed Load Byte Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'h00000012) begin
            $display("Failed Load Byte Test Case");
        end

        //Load Halfword
        sel = 1;
        din = 32'hffffffff;
        #1;
        if (dout != 32'h0000ffff) begin
            $display("Failed Load Halfword Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'h0000ef12) begin
            $display("Failed Load Halfword Test Case");
        end

        //Load Word
        sel = 2;
        din = 32'hffffffff;
        #1;
        if (dout != 32'hffffffff) begin
            $display("Failed Load Word Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'habcdef12) begin
            $display("Failed Load Word Test Case");
        end

        //Default case should be zero
        sel = 3;
        #1;
        if (dout != 32'h00000000) begin
            $display("Failed Default Sel Test Case");
        end

        $finish();
    end

endmodule
