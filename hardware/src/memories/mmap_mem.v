module mmap_mem (
  input clk,
  input rst,
  input [2:0] MMap_Sel,
  input data_in_ready,
  input data_in_valid,
  input data_out_ready,
  input data_out_valid,
  input [7:0] IO_mem_din_rx,
  input [7:0] IO_mem_din_tx,
  output reg [31:0] MMap_dout
);
    
    reg [31:0] UART_control;
    reg [31:0] UART_recv;
    reg [31:0] UART_tx;
    reg [31:0] cycle_counter;
    reg [31:0] inst_counter;

    always @(posedge clk) begin
        if (MMap_Sel == 0)
            MMap_dout <= UART_control;
        else if (MMap_Sel == 1)
            MMap_dout <= UART_recv;
        else if (MMap_Sel == 3)
            MMap_dout <= cycle_counter;
        else if (MMap_Sel == 4)
            MMap_dout <= inst_counter;
  end
  
    always @(posedge clk) begin
        if (rst) begin
            UART_control <= 0;
            UART_recv <= 0;
            UART_tx <= 0;
            cycle_counter <= 0;
            inst_counter <= 0;
        end
        if (data_out_ready && data_out_valid) begin
            UART_recv <= {{24{1'b0}}, IO_mem_din_rx};
        end
        if (MMap_Sel == 2) begin
            MMap_dout <= UART_tx;
        end

        UART_control <= {{30{1'b0}}, data_out_valid, data_in_ready};
    end


    always @(posedge clk) begin
        if (MMap_Sel == 2) 
            UART_tx = {{24{1'b0}}, IO_mem_din_tx};
        
        // cycle_counter <= cycle_counter + 1;
    end



//   always @(posedge clk) begin
//     if (en)
//       dout <= mem[addr];
//   end

//   genvar i;
//   generate for (i = 0; i < 4; i = i+1) begin
//     always @(posedge clk) begin
//       if (we[i] && en)
//           mem[addr][i*8 +: 8] <= din[i*8 +: 8];
//     end
//   end endgenerate
endmodule
