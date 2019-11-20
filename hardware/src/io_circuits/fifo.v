module fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = $clog2(fifo_depth)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [data_width-1:0] din,
    output full,

    // Read side
    input rd_en,
    output reg [data_width-1:0] dout,
    output empty
);

    reg [data_width - 1:0] mem [fifo_depth - 1:0];
    integer i;
    initial begin
        for (i = 0; i < fifo_depth; i = i + 1)
            mem[i] = 0;
    end

    // We add an extra bit to the addrs, to disambgiuate full/empty condition
    // Each time address warps, toggle the extra (MSB) bit
    reg [addr_width:0] rd_addr;
    reg [addr_width:0] wr_addr;

    initial dout = 0;
    initial rd_addr = 0;
    initial wr_addr = 0;

    // At the posedge of clock, if write is enabled, write to mem at
    // current pointer addr, then increment pointer
    assign empty = wr_addr == rd_addr;
    assign full = (wr_addr[addr_width] != rd_addr[addr_width]) && 
                    (wr_addr[addr_width - 1 : 0] == rd_addr[addr_width - 1 : 0]);


    always @(posedge clk) begin
        if (rst) begin
        // Set write addr to read addr to zero
            rd_addr <= 0;
            wr_addr <= 0;
            dout <= 0;
        end 
        
        if (rd_en && !empty) begin
            dout <= mem[rd_addr];
            if (rd_addr == fifo_depth - 1) begin
                rd_addr[addr_width] <= rd_addr[addr_width] ^ 1;
                rd_addr[addr_width - 1:0] <= 0;
            end else begin
                rd_addr <= rd_addr + 1;
            end
        end

        if (wr_en && !full) begin
            mem[wr_addr] <= din;
            if (wr_addr == fifo_depth - 1) begin
                wr_addr[addr_width] <= wr_addr[addr_width] ^ 1;
                wr_addr[addr_width - 1:0] <= 0;
            end else begin
                wr_addr <= wr_addr + 1;
            end
        end
    end

endmodule
