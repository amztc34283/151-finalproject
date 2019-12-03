module pwm_controller #(
    parameter RESET_PC = 12'h000,
    parameter BUS_WIDTH = 12
)(
    //clk1 is cpu clk
    //clk2 is pwm_clk_g
    //rst is pwm_rst
    input clk1,
    input clk2,
    input rst,
    input [11:0] duty_cycle,
    input req,
    output ack,
    output [11:0] pwm_duty_cycle
);

    wire [11:0] duty_cycle_clk2;

    d_ff #(.BUS_WIDTH(BUS_WIDTH), .RESET_PC(RESET_PC)) DUTY_CYCLE_FF_CLK1(
        .d(duty_cycle),
        .clk(clk1),
        .rst(rst),
        .q(duty_cycle_clk2)
    );

    wire req_clk2_1;

    d_ff #(.BUS_WIDTH(1), .RESET_PC(0)) REQ_FF_CLK1(
        .d(req),
        .clk(clk1),
        .rst(rst),
        .q(req_clk2_1)
    );

    wire req_clk2_2;

    d_ff #(.BUS_WIDTH(1), .RESET_PC(0)) REQ_FF_CLK2_1(
        .d(req_clk2_1),
        .clk(clk2),
        .rst(rst),
        .q(req_clk2_2)
    );

    wire req_clk2_2_out;

    d_ff #(.BUS_WIDTH(1), .RESET_PC(0)) REQ_FF_CLK2_2(
        .d(req_clk2_2),
        .clk(clk2),
        .rst(rst),
        .q(req_clk2_2_out)
    );

    wire [11:0] duty_cycle_pwm;
    wire [11:0] pwm_duty_cycle_final;

    //This mux is before DUTY_CYCLE_FF_CLK2
    twoonemux #(.BUS_WIDTH(BUS_WIDTH)) gate_pwm_in(
        .sel(req_clk2_2_out),
        .s0(duty_cycle_pwm), //from DUTY_CYCLE_FF_CLK2 output
        .s1(duty_cycle_clk2),
        .out(pwm_duty_cycle_final)
    );

    d_ff #(.BUS_WIDTH(BUS_WIDTH), .RESET_PC(RESET_PC)) DUTY_CYCLE_FF_CLK2(
        .d(pwm_duty_cycle_final),
        .clk(clk2),
        .rst(rst),
        .q(duty_cycle_pwm)
    );
    // Only send duty cycle to pwm when req_clk2_2_out is high; see below for implementation
    // Instead of creating another special register for the pwm controller,
    // Consider adding a twoonemux that the sel is req_clk2_2_out; see gate_pwm_in

    assign pwm_duty_cycle = duty_cycle_pwm;

    wire ack_clk1_1;

    d_ff #(.BUS_WIDTH(1), .RESET_PC(0)) ACK_FF_CLK1_1(
        .d(req_clk2_2_out),
        .clk(clk1),
        .rst(rst),
        .q(ack_clk1_1)
    );

    d_ff #(.BUS_WIDTH(1), .RESET_PC(0)) ACK_FF_CLK1_2(
        .d(ack_clk1_1),
        .clk(clk1),
        .rst(rst),
        .q(ack)
    );

endmodule
