module d_ff #(parameter BUS_WIDTH = 32) (
    input [`BUS_WIDTH - 1:0] d,
    input clk,
    input rst,
    output reg [`BUS_WIDTH - 1:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= 0;
        else
            q <= d;

    end
endmodule