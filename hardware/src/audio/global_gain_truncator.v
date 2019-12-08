// Async Block
module global_gain_truncator (
    input [4:0] global_gain,
    input [19:0] summer_value,
    output [11:0] truncated_value
);

    wire [19:0] amplified_value;
    assign amplified_value = $signed(summer_value) >>> global_gain;
    assign truncated_value = {1'b1^{amplified_value[19]},amplified_value[18:8]};

endmodule
