`timescale 1ns/10ps

module s_sel_testbench ();
    reg [1:0] sel = 0;
    reg [1:0] offset = 0;
    reg [31:0] rs2 = 0;
    wire [3:0] dmem_we;
    wire [31:0] dmem_din;

    s_sel DUT(
        .sel(sel),
        .offset(offset),
        .rs2(rs2),
        .dmem_we(dmem_we),
        .dmem_din(dmem_din)
    );

    initial begin
        $display("Test begin");

        sel = 0; //store byte
        offset = 0;
        rs2 = 32'hffffffff;
        #1;
        if (dmem_we != 4'b0001 || dmem_din != 32'hffffffff) begin
            $display("dmem_we should be 0001 but got %b", dmem_we);
            $display("dmem_din should be ffffffff but got %b", dmem_din);
        end

        sel = 0;
        offset = 1;
        rs2 = 32'hffffffff;
        #1;
        if (dmem_we != 4'b0010 || dmem_din != 32'hffffff00) begin
            $display("dmem_we should be 0010 but got %b", dmem_we);
            $display("dmem_din should be ffffff00 but got %b", dmem_din);
        end

        sel = 0;
        offset = 2;
        rs2 = 32'hffffffff;
        #1;
        if (dmem_we != 4'b0100 || dmem_din != 32'hffff0000) begin
            $display("dmem_we should be 0100 but got %b", dmem_we);
            $display("dmem_din should be ffff0000 but got %b", dmem_din);
        end

        sel = 0;
        offset = 3;
        rs2 = 32'hffffffff;
        #1;
        if (dmem_we != 4'b1000 || dmem_din != 32'hff000000) begin
            $display("dmem_we should be 1000 but got %b", dmem_we);
            $display("dmem_din should be ff000000 but got %b", dmem_din);
        end

        sel = 1; //store halfword
        offset = 0;
        rs2 = 32'h1f2f3f4f;
        #1;
        if (dmem_we != 4'b0011 || dmem_din != 32'h1f2f3f4f) begin
            $display("dmem_we should be 0011 but got %b", dmem_we);
            $display("dmem_din should be 1f2f3f4f but got %b", dmem_din);
        end

        sel = 1;
        offset = 1;
        rs2 = 32'h1f2f3f4f;
        #1;
        if (dmem_we != 4'b0110 || dmem_din != 32'h2f3f4f00) begin
            $display("dmem_we should be 0110 but got %b", dmem_we);
            $display("dmem_din should be 2f3f4f00 but got %b", dmem_din);
        end

        sel = 1;
        offset = 2;
        rs2 = 32'h1f2f3f4f;
        #1;
        if (dmem_we != 4'b1100 || dmem_din != 32'h3f4f0000) begin
            $display("dmem_we should be 1100 but got %b", dmem_we);
            $display("dmem_din should be 3f4f0000 but got %b", dmem_din);
        end

        sel = 2; //store word
        offset = 0;
        rs2 = 32'h1f2f3f4f;
        #1;
        if (dmem_we != 4'b1111 || dmem_din != 32'h1f2f3f4f) begin
            $display("dmem_we should be 1111 but got %b", dmem_we);
            $display("dmem_din should be 1f2f3f4f but got %b", dmem_din);
        end

        $display("Test end");
        $finish();
    end
endmodule
