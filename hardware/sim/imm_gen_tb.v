`timescale 1ns/100ps

`define I_TYPE 1
`define S_TYPE 2
`define B_TYPE 3
`define U_TYPE 4
`define J_TYPE 5


module imm_gen_tb();
    reg [31:0] imm_in;
    reg [31:0] inst;
    wire [24:0] inst_in;
    reg [1:0] select;
    wire [31:0] out;

    assign inst_in = inst[31:7];
    imm_gen DUT_imm_gen(.inst_in(inst_in), .imm_sel(select), .imm_out(out));

    initial begin
        imm_in = 0;
        inst = 0;
        select = 0;

        // Test I Type
        #(5);
        select = `I_TYPE;
        inst = $random;
        #(1)
        inst[31:20] = 1;
        #(1)
        if (out != 1)
            $display("I type failed; output=%d, expected=%d", out, 1);

        #(5)
        inst = $random;
        #(1)
        inst[31:20] = -100;
        #(1)
        if (out != -100)
            $display("I type failed; output=%d, expected=%d", out, -100);

        #(5)
        inst = $random;
        #(1)
        inst[31:20] = -1;
        #(1)
        if (out != -1)
            $display("I type failed; output=%d, expected=%d", out, -1);

        #(5)
        inst = $random;
        #(1)
        inst[31:20] = 2**11;
        #(1)
        if (out != -2**11)
            $display("I type failed; output=%d, expected=%d", out, -2**11);

        #(5)
        inst = $random;
        #(1)
        inst[31:20] = 2**11 + 1;
        #(1)
        if (out != -(2**11 - 1))
            $display("I type failed; output=%d, expected=%d", out, -(2**11 - 1));

        #(5)
        inst = $random;
        #(1)
        inst[31:20] = 2**11 - 1;
        #(1)
        if (out != 2**11 - 1)
            $display("I type failed; output=%d, expected=%d", out, 2**11 - 1);

        #(5)
        inst = $random;
        #(1)
        inst[31:20] = 2**11 / 2;
        #(1)
        if (out !=  2**11 / 2)
            $display("I type failed; output=%d, expected=%d", out,  2**11 / 2);


        // Test S Type
        #(5)
        select = `S_TYPE;
        inst = $random;
        #(1)
        imm_in = 1;
        inst[11:7] = imm_in[4:0];
        inst[31:25] = imm_in[11:5];
        #(1)
        if (out != 1)
            $display("S type failed; output=%d, expected=%d", out, 1);

        #(5)
        inst = $random;
        #(1)
        imm_in = -100;
        inst[11:7] = imm_in[4:0];
        inst[31:25] = imm_in[11:5];
        #(1)
        if (out != -100)
            $display("S type failed; output=%d, expected=%d", out, -100);

        #(5)
        inst = $random;
        #(1)
        imm_in = -1;
        inst[11:7] = imm_in[4:0];
        inst[31:25] = imm_in[11:5];
        #(1)
        if (out != -1)
            $display("S type failed; output=%d, expected=%d", out, -1);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**11;
        inst[11:7] = imm_in[4:0];
        inst[31:25] = imm_in[11:5];
        #(1)
        if (out != -2**11)
            $display("S type failed; output=%d, expected=%d", out, -2**11);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**11 + 1;
        inst[11:7] = imm_in[4:0];
        inst[31:25] = imm_in[11:5];
        #(1)
        if (out != -(2**11 - 1))
            $display("S type failed; output=%d, expected=%d", out, -(2**11 - 1));

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**11 - 1;
        inst[11:7] = imm_in[4:0];
        inst[31:25] = imm_in[11:5];
        #(1)
        if (out != 2**11 - 1)
            $display("S type failed; output=%d, expected=%d", out, 2**11 - 1);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**11 / 2;
        inst[11:7] = imm_in[4:0];
        inst[31:25] = imm_in[11:5];
        #(1)
        if (out !=  2**11 / 2)
            $display("S type failed; output=%d, expected=%d", out,  2**11 / 2);

        // Test B Type
        #(5);
        select = `B_TYPE;
        inst = $random;
        #(1)
        imm_in = 1;
        inst[31] = imm_in[12];
        inst[30:25] = imm_in[10:5];
        inst[11:8] = imm_in[4:1];
        inst[7] = imm_in[11];
        #(1)
        if (out != (1) & (2**32 - 2))
            $display("B type failed; output=%d, expected=%d", out, 1);

        #(5)
        inst = $random;
        #(1)
        imm_in = -100;
        inst[31] = imm_in[12];
        inst[30:25] = imm_in[10:5];
        inst[11:8] = imm_in[4:1];
        inst[7] = imm_in[11];
        #(1)
        if (out != -100 & (2**32 - 2))
            $display("B type failed; output=%d, expected=%d", out, -100);

        #(5)
        inst = $random;
        #(1)
        imm_in = -1;
        inst[31] = imm_in[12];
        inst[30:25] = imm_in[10:5];
        inst[11:8] = imm_in[4:1];
        inst[7] = imm_in[11];
        #(1)
        if (out != (-1) & (2**32 - 2))
            $display("B type failed; output=%d, expected=%d", out, -1);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**11;
        inst[31] = imm_in[12];
        inst[30:25] = imm_in[10:5];
        inst[11:8] = imm_in[4:1];
        inst[7] = imm_in[11];
        #(1)
        if (out != (-2**11) & (2**32 - 2))
            $display("B type failed; output=%d, expected=%d", out, -2**11);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**11 + 1;
        inst[31] = imm_in[12];
        inst[30:25] = imm_in[10:5];
        inst[11:8] = imm_in[4:1];
        inst[7] = imm_in[11];
        #(1)
        if (out != -(2**11 - 1) & (2**32 - 2))
            $display("B type failed; output=%d, expected=%d", out, -(2**11 - 1));

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**11 - 1;
        inst[31] = imm_in[12];
        inst[30:25] = imm_in[10:5];
        inst[11:8] = imm_in[4:1];
        inst[7] = imm_in[11];
        #(1)
        if (out != (2**11 - 1) & (2**32 - 2))
            $display("B type failed; output=%d, expected=%d", out, 2**11 - 1);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**11 / 2;
        inst[31] = imm_in[12];
        inst[30:25] = imm_in[10:5];
        inst[11:8] = imm_in[4:1];
        inst[7] = imm_in[11];
        #(1)
        if (out != (2**11 / 2) & (2**32 - 2))
            $display("B type failed; output=%d, expected=%d", out,  2**11 / 2);


        // Test J Type
        #(5);
        select = `J_TYPE;
        inst = $random;
        #(1)
        imm_in = 2**19;
        inst[31] = imm_in[20];
        inst[30:21] = imm_in[10:1];
        inst[20] = imm_in[11];
        inst[19:12] = imm_in[19:12];
        #(1)
        if (out != imm_in)
            $display("J type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**19 - 1;
        inst[31] = imm_in[20];
        inst[30:21] = imm_in[10:1];
        inst[20] = imm_in[11];
        inst[19:12] = imm_in[19:12];
        #(1)
        if (out != imm_in)
            $display("J type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**18;
        inst[31] = imm_in[20];
        inst[30:21] = imm_in[10:1];
        inst[20] = imm_in[11];
        inst[19:12] = imm_in[19:12];
        #(1)
        if (out != imm_in)
            $display("J type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = -2**18;
        inst[31] = imm_in[20];
        inst[30:21] = imm_in[10:1];
        inst[20] = imm_in[11];
        inst[19:12] = imm_in[19:12];
        #(1)
        if (out != imm_in)
            $display("J type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = -2**19;
        inst[31] = imm_in[20];
        inst[30:21] = imm_in[10:1];
        inst[20] = imm_in[11];
        inst[19:12] = imm_in[19:12];
        #(1)
        if (out != imm_in)
            $display("J type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = -2**19 + 1;
        inst[31] = imm_in[20];
        inst[30:21] = imm_in[10:1];
        inst[20] = imm_in[11];
        inst[19:12] = imm_in[19:12];
        #(1)
        if (out != imm_in)
            $display("J type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = 1;
        inst[31] = imm_in[20];
        inst[30:21] = imm_in[10:1];
        inst[20] = imm_in[11];
        inst[19:12] = imm_in[19:12];
        #(1)
        if (out != imm_in)
            $display("J type failed; output=%d, expected=%d", out, imm_in);


        // Test U Type
        #(5);
        select = `J_TYPE;
        inst = $random;
        #(1)
        imm_in = 2**31 - 1;
        inst[31:12] = imm_in[31:12];
        #(1)
        if (out != {imm_in[31:12], {12{1'b0}}})
            $display("U type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = -2**30 - 1;
        inst[31:12] = imm_in[31:12];
        #(1)
        if (out != {imm_in[31:12], {12{1'b0}}})
            $display("U type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = 1000;
        inst[31:12] = imm_in[31:12];
        #(1)
        if (out != {imm_in[31:12], {12{1'b0}}})
            $display("U type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = -1000;
        inst[31:12] = imm_in[31:12];
        #(1)
        if (out != {imm_in[31:12], {12{1'b0}}})
            $display("U type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**20;
        inst[31:12] = imm_in[31:12];
        #(1)
        if (out != {imm_in[31:12], {12{1'b0}}})
            $display("U type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**19;
        inst[31:12] = imm_in[31:12];
        #(1)
        if (out != {imm_in[31:12], {12{1'b0}}})
            $display("U type failed; output=%d, expected=%d", out, imm_in);

        #(5)
        inst = $random;
        #(1)
        imm_in = 2**19 - 1;
        inst[31:12] = imm_in[31:12];
        #(1)
        if (out != {imm_in[31:12], {12{1'b0}}})
            $display("U type failed; output=%d, expected=%d", out, imm_in);


        $finish();

    end
endmodule
