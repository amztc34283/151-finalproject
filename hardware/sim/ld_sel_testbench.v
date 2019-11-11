`timescale 1ns/100ps

`define CLK_PERIOD 8
`define DATA_WIDTH 32
`define FIFO_DEPTH 8

module ld_sel_testbench();

    reg [2:0] sel = 0;
    reg [31:0] din = 0;
    reg [1:0] offset = 0;
    wire [31:0] dout;

    ld_sel DUT(.sel(sel),
               .din(din),
               .dout(dout),
               .offset(offset));

    /**
    2.9.2
    Unaligned Memory Accesses
    In the official RISC-V specification, unaligned loads and stores are supported. However, in your
    project, you can ignore instructions that request an unaligned access. Assume that the compiler
    will never generate unaligned accesses.
    **/

    initial begin
        //Load Byte
        sel = 0;
        offset = 0;
        din = 32'hffffffff;
        #1;
        if (dout != 32'hffffffff) begin
            $display("Failed Load Byte with zero offset Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'h00000012) begin
            $display("Failed Load Byte with zero offset Test Case");
        end

        //Load Halfword
        sel = 1;
        offset = 0;
        din = 32'hffffffff;
        #1;
        if (dout != 32'hffffffff) begin
            $display("Failed Load Halfword with zero offset Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'hffffef12) begin
            $display("Failed Load Halfword with zero offset Test Case");
        end

        //Load Word
        sel = 2;
        offset = 0;
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

        //Load unsigned byte
        sel = 3;
        offset = 0;
        din = 32'hffffffff;
        #1;
        if (dout != 32'h000000ff) begin
            $display("Failed Load Byte with zero offset Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'h00000012) begin
            $display("Failed Load Byte with zero offset Test Case");
        end

        //Load unsigned halfword
        sel = 4;
        offset = 0;
        din = 32'hffffffff;
        #1;
        if (dout != 32'h0000ffff) begin
            $display("Failed Load Byte with zero offset Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'h0000ef12) begin
            $display("Failed Load Byte with zero offset Test Case");
        end


        //With Offset
        //Load Byte
        sel = 0;
        offset = 1;
        din = 32'hffffffff;
        #1;
        if (dout != 32'hffffffff) begin
            $display("Failed Load Byte with zero offset Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'hffffffef) begin
            $display("Failed Load Byte with zero offset Test Case");
        end

        //Load Halfword
        sel = 1;
        offset = 2;
        din = 32'hffffffff;
        #1;
        if (dout != 32'hffffffff) begin
            $display("Failed Load Halfword with zero offset Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'hffffabcd) begin
            $display("Failed Load Halfword with zero offset Test Case");
        end

        //Load unsigned byte
        sel = 3;
        offset = 2;
        din = 32'hffffffff;
        #1;
        if (dout != 32'h000000ff) begin
            $display("Failed Load unsigned Byte with zero offset Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'h000000cd) begin
            $display("Failed Load unsigned Byte with zero offset Test Case");
        end

        //Load unsigned halfword
        sel = 4;
        offset = 0;
        din = 32'hffffffff;
        #1;
        if (dout != 32'h0000ffff) begin
            $display("Failed Load unsigned Halfword with zero offset Test Case");
        end
        din = 32'habcdef12;
        #1;
        if (dout != 32'h0000ef12) begin
            $display("Failed Load unsigned Halfword with zero offset Test Case");
        end

        //Default case should be zero (4 < sel)
        sel = 5;
        offset = 0;
        #1;
        if (dout != 32'h00000000) begin
            $display("Failed Default Sel Test Case");
        end
        sel = 6;
        offset = 1;
        #1;
        if (dout != 32'h00000000) begin
            $display("Failed Default Sel Test Case");
        end
        sel = 7;
        offset = 0;
        #1;
        if (dout != 32'h00000000) begin
            $display("Failed Default Sel Test Case");
        end

        $finish();
    end

endmodule
