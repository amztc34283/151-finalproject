module mmap_mem (
  input clk,
  input rst,
  input [2:0] MMap_Sel,
  input data_in_ready,
  input data_out_valid,
  output reg [31:0] MMap_dout
);
    
    reg [31:0] cycle_counter;
    reg [31:0] inst_counter;

    always @(posedge clk) begin
        if (rst) begin
            MMap_dout <= 0;
            cycle_counter <= 0;
            inst_counter <= 0;
        end
        else if (MMap_Sel == 0)
            MMap_dout <= {{30{1'b0}}, data_out_valid, data_in_ready};
        else if (MMap_Sel == 3)
            MMap_dout <= cycle_counter;
        else if (MMap_Sel == 4)
            MMap_dout <= inst_counter;
  end

endmodule
