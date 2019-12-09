module signal_chain (
    input clk1,
    input clk2,
    input [23:0] fcw,
    input note_reset, // pulse value
    input note_start, // pulse value
    input note_release, // pulse value
    input [4:0] sine_shift, // coming from outside register value
    input [4:0] square_shift, // coming from outside register value
    input [4:0] triangle_shift, // coming from outside register value
    input [4:0] sawtooth_shift, // coming from outside register value
    input [4:0] global_gain, // coming from outside register value
    output note_finished,
    output [11:0] pwm_duty_cycle
);

    wire [23:0] accumulated_value;
    wire valid;
    wire ready;

    phase_accum phase_accum(
        .clk(clk1),
        .fcw(fcw),
        .ready(ready),
        .note_start(note_start),
        .note_release(note_release),
        .note_reset(note_reset),
        .accumulated_value(accumulated_value),
        .valid(valid),
        .note_finished(note_finished));

    wire [19:0] sum_out;

    nco_scaler_summer nco_scaler_summer(
        .accumulated_value(accumulated_value),
        .sine_shift(sine_shift),
        .square_shift(square_shift),
        .triangle_shift(triangle_shift),
        .sawtooth_shift(sawtooth_shift),
        .sum_out(sum_out)
    );

    wire [11:0] truncated_value;

    global_gain_truncator global_gain_truncator(
        .global_gain(global_gain),
        .summer_value(sum_out),
        .truncated_value(truncated_value)
    );

    wire tx_ack;
    wire tx_req;
    wire [11:0] to_cdc;

    buffer buffer (
        .clk(clk1),
        .valid(valid),
        .rst(note_reset),
        .from_truncator(truncated_value),
        .tx_ack(tx_ack),
        .tx_req(tx_req),
        .to_cdc(to_cdc),
        .ready(ready)
    );

    pwm_controller pwm_controller(
        .clk1(clk1),
        .clk2(clk2),
        .rst(note_reset),
        .duty_cycle(to_cdc),
        .req(tx_req),
        .ack(tx_ack),
        .pwm_duty_cycle(pwm_duty_cycle));

endmodule
