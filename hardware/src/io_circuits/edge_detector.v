module edge_detector #(
    parameter width = 1
)(
    input clk,
    input [width-1:0] signal_in,
    output reg [width-1:0] edge_detect_pulse
);
    // The edge detector takes a bus of 1-bit signals and looks for a low to high (0 -> 1)
    // logic transition. It outputs a 1 clock cycle wide pulse if a transition is detected.
    reg [width-1:0] q = 0 ;

    // Mealy FSM; @(posedge clk), signal_in == 0, then q[i] == 0
    // After epsilon delay, signal_in[i] == 1 && q[i] == 0
    // So edge_detect_pulse == 1
    genvar i;
    generate
        for (i = 0; i < width; i = i + 1) begin:catch_low_to_high
            always @(posedge clk) begin
                q[i] <= signal_in[i];
            end

            always @(*) begin   
                edge_detect_pulse[i] = signal_in[i] & ~q[i];
            end
        end
    endgenerate
endmodule
