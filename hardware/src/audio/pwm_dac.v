`timescale 1ns/1ns
module pwm_dac (
    //clk is pwm_clk_g
    input clk,
    input [11:0] duty_cycle,
    output reg square_wave_out
);

    //This pwm will be running at 150MHz/2^12 Hz = 36621.09Hz
    //In order to generate lower frequency, this pwm can output 100% duty cycle
    //for desired frequency.
    //Example: Creating 18310Hz frequency would use one 100% duty cycle
    //to represent the high and one 0% duty cycle to represent the low.

    //should the pwm_rst goes in here directly?
    //No, they will be going to the registers at four-way handshake.
    reg [11:0] counter = 0;
    initial square_wave_out = 0;

    always @ (posedge clk) begin
        if (counter == 12'hffe) begin
            counter <= 0;
        end else if (duty_cycle > 0) begin
            counter <= counter + 1;
        end else if (duty_cycle == 0) begin
            counter <= 0;
        end
    end

    //What if duty_cycle is xxxx; never happen as the register before pwm
    //is reset to output 0

    always @(posedge clk) begin
        if (counter >= duty_cycle) begin
            square_wave_out <= 0;
        end else if (counter < duty_cycle) begin
            square_wave_out <= 1;
        end
    end

endmodule
