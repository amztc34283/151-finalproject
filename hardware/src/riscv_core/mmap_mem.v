`define MM_UART_CTRL 16'h0000  // 0
`define MM_UART_RX 16'h0004    // 1
`define MM_UART_TX 16'h0008    // 2
`define MM_UART_CC 16'h0010    // 3
`define MM_UART_IC 16'h0014    // 4
`define MM_UART_RST 16'h0018   // 5
// Control Injected Nop         // 6
// Don't Care Value             // 7


module mmap_mem #(
    parameter CPU_CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 45_000)
(    
  input clk,
  input rst,
  input en,
  input [15:0] addr,
  input [2:0] MMap_Sel,
  output reg [31:0] MMap_dout,

  input [7:0] data_in,
  input data_in_valid,
  output data_in_ready,

  output [7:0] data_out,
  output data_out_valid,
  input data_out_ready,

  input serial_in,
  output serial_out
);

    reg [31:0] cycle_counter;
    reg [31:0] inst_counter;

    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) on_chip_uart (
        .clk(clk),
        .reset(rst),
        .data_in(data_in),
        .data_in_valid(data_in_valid),         // Memory Mapped IO Write Val, set by store @ 0x8000_0008
        .data_out_ready(data_out_ready),       // Memory Mapped IO Write En, set by load @ 0x8000_0004
        .serial_in(serial_in),

        .data_in_ready(data_in_ready),          // 0x8000_0000 bit 0
        .data_out(data_out),                    // Memory Mapped IO Read Val
        .data_out_valid(data_out_valid),        // 0x8000_0000 bit 1
        .serial_out(serial_out)
    );

    always @(posedge clk) begin
        if (rst) begin
            MMap_dout <= 0;
            cycle_counter <= 0;
            inst_counter <= 0;

        end else begin
            if (addr != `MM_UART_RST) begin
                cycle_counter <= cycle_counter + 1;
                if (MMap_Sel != 6) 
                    inst_counter <= inst_counter + 1;
            end
            
            if (en) begin
                case (addr)
                    `MM_UART_CTRL: begin
                        MMap_dout <= {{30{1'b0}}, data_out_valid, data_in_ready};
                    end
                    `MM_UART_RX: begin
                        MMap_dout <= {{24{1'b0}}, data_out};
                    end
                    `MM_UART_TX: begin
                        MMap_dout <= 32'd0;
                    end
                    `MM_UART_CC: begin
                        MMap_dout <= cycle_counter;
                    end
                    `MM_UART_IC: begin
                        MMap_dout <= inst_counter;
                    end
                    `MM_UART_RST: begin
                        cycle_counter <= 0;
                        inst_counter <= 0;
                    end
                    default: begin
                        MMap_dout <= 0;
                    end
                endcase
            end
        end


  end

endmodule
