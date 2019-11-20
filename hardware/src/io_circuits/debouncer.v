module debouncer #(
    parameter width = 1,
    parameter sample_count_max = 25000,
    parameter pulse_count_max = 150,
    parameter wrapping_counter_width = $clog2(sample_count_max),
    parameter saturating_counter_width = $clog2(pulse_count_max))
(
    input clk,
    input [width-1:0] glitchy_signal,
    output [width-1:0] debounced_signal
);
    // Create your debouncer circuit
    // The debouncer takes in a bus of 1-bit synchronized, but glitchy signals
    // and should output a bus of 1-bit signals that hold high when their respective counter saturates

    // Remove this line once you create your synchronizer
    reg sample_pulse_signal = 0;
    reg [wrapping_counter_width:0] sample_count = 0;
    reg [saturating_counter_width:0] saturating_counters_arr[width-1:0];

    integer k;
    initial begin
        for (k = 0; k < width; k = k + 1) begin
            saturating_counters_arr[k] = 0;
        end
    end


    always @(posedge clk) begin
        if (sample_count < sample_count_max) begin
            sample_count <= sample_count + 1;
        end else begin
            sample_count <= 0;
        end
    end

    genvar i;
    generate
        for (i = 0; i < width; i = i + 1) begin:saturating_counters
            always @(posedge clk) begin
                if ((glitchy_signal[i] && sample_count == sample_count_max) && saturating_counters_arr[i] < pulse_count_max) 
                    saturating_counters_arr[i] <= saturating_counters_arr[i] + 1;
                else if (sample_count == sample_count_max && !glitchy_signal[i]) 
                    saturating_counters_arr[i] <= 0;
            end
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j < width; j = j + 1) begin:debounce_out
            always @(*) begin
                debounced_signal[j] = saturating_counters_arr[j] == pulse_count_max;
            end
        end
    endgenerate

endmodule
