module d_ff #(
    parameter BUS_WIDTH = 32,
    parameter RESET_PC = 32'h4000_0000) 
(
    input [BUS_WIDTH - 1:0] d,
    input clk,
    input rst,
    output reg [BUS_WIDTH - 1:0] q
);


    always @(posedge clk) begin
        if (rst)
            q <= RESET_PC;
        else
            q <= d;
    end
endmodule
