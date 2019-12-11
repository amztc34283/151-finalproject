`define MM_UART_CTRL 16'h0000  // 0
`define MM_UART_RX 16'h0004    // 1
`define MM_UART_TX 16'h0008    // 2
`define MM_UART_CC 16'h0010    // 3
`define MM_UART_IC 16'h0014    // 4
`define MM_UART_RST 16'h0018   // 5
// Control Injected Nop         // 6
// Don't Care Value             // 7
// User I/O
`define GPIO_FIFO_EMPTY 16'h0020
`define GPIO_FIFO_READ 16'h0024
`define SWITCHES 16'h0028
`define GPIO_LEDS 16'h0030

`define PWM_DUTY_CYCLE 16'h0034
`define PWM_TX_REQ 16'h0038
`define PWM_TX_ACK 16'h0040

`define MMAP_LOAD 3'd1
`define MMAP_STORE 3'd2
`define MMAP_NO_NOP 3'd6
`define MMAP_X 3'd7

`define NCO_SINE 16'h0200
`define NCO_SQUARE 16'h0204
`define NCO_TRIANGLE 16'h0208
`define NCO_SAWTOOTH 16'h020c
`define FCW 16'h1000

`define GLOBAL_GAIN_SHIFT 16'h0104
`define PWM_DAC_SOURCE 16'h0044

`define GLOBAL_SYNTH_RESET 16'h0100
`define NOTE_START 16'h1004
`define NOTE_RELEASE 16'h1008
`define NOTE_FINISHED 16'h100c
`define NOTE_RESET 16'h1010



module mmap_mem #(
    parameter CPU_CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 45_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BUS_WIDTH = 12)
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
  output serial_out,

  // User I/O
  output reg [5:0] leds,
  input [31:0] data,
  input [1:0] switches,
  input [2:0] buttons,
  output [2:0] fifo_buttons,

  // PWM
  input clk_rx,
  input pwm_rst,
  output square_wave_out

  // Signal Chain
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

    wire wr_en;
    assign wr_en = |buttons;
    wire empty;
    wire [2:0] fifo_out;
    wire rd_en;

    // For User I/O Buttons
    fifo #(
        .data_width(3),
        .fifo_depth(32)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en), // wr_en is high when either of the buttons are pressed
        .din(buttons), // all buttons status
        .full(), // full can be ignored for now
        .rd_en(rd_en), // address
        // TODO: FIFO_BUTTONS has to be muxed with MMap_dout
        .dout(fifo_buttons), // 32'h80000024
        .empty(empty) // output
    );

    reg [11:0] duty_cycle_cpu;

    wire [11:0] pwm_duty_cycle_cpu;
    wire [11:0] pwm_duty_cycle_synth;
    wire [11:0] duty_cycle;

    reg source;

    assign duty_cycle = source ? pwm_duty_cycle_synth : pwm_duty_cycle_cpu;

    reg tx_req;
    wire tx_ack;

    pwm_controller #(
        .RESET_PC(RESET_PC),
        .BUS_WIDTH(BUS_WIDTH)
    ) pwm_controller (
        .clk1(clk),
        .clk2(clk_rx),
        .rst(pwm_rst),
        .duty_cycle(duty_cycle_cpu),
        .req(tx_req),
        .ack(tx_ack),
        .pwm_duty_cycle(pwm_duty_cycle_cpu)
    );

    reg [4:0] sine_shift, square_shift, triangle_shift, sawtooth_shift, global_gain;
    reg [23:0] fcw_reg;
    wire note_finished;
    wire note_reset;
    wire note_start;
    wire note_release;

    // signal_chain signal_chain (
    //     .clk1(clk),
    //     .clk2(clk_rx),
    //     .fcw(fcw_reg),
    //     .note_reset(note_reset),
    //     .note_start(note_start),
    //     .note_release(note_release),
    //     .sine_shift(sine_shift),
    //     .square_shift(square_shift),
    //     .triangle_shift(triangle_shift),
    //     .sawtooth_shift(sawtooth_shift),
    //     .global_gain(global_gain),
    //     .note_finished(note_finished),
    //     .pwm_duty_cycle(pwm_duty_cycle_synth)
    // );

    pwm_dac pwm_dac (
        .clk(clk_rx),
        .duty_cycle(duty_cycle),
        .square_wave_out(square_wave_out)
    );

    assign note_reset = (addr == `GLOBAL_SYNTH_RESET || addr == `NOTE_RESET) ? 1 : 0;
    assign note_start = addr == `NOTE_START ? 1 : 0;
    assign note_release = addr == `NOTE_RELEASE ? 1 : 0;

    // input clk1,
    // input clk2,
    // input [23:0] fcw, // coming from outside register value
    // input note_reset, // pulse value
    // input note_start, // pulse value
    // input note_release, // pulse value
    // input [4:0] sine_shift, // coming from outside register value
    // input [4:0] square_shift, // coming from outside register value
    // input [4:0] triangle_shift, // coming from outside register value
    // input [4:0] sawtooth_shift, // coming from outside register value
    // input [4:0] global_gain, // coming from outside register value
    // output note_finished, // going to write back
    // output [11:0] pwm_duty_cycle // going to mux

    // reg [23:0] fcw_reg;
    // wire [23:0] accumulated_value;
    // wire ready;
    // wire valid;
    //
    // // ?? 'Note' Encoding ?? reg note_reset, note_start, note_release, glbl_synth_rst;
    // phase_accum phase_accum (
    //     .clk(clk),
    //     .fcw(fcw_reg),
    //     .ready(ready),
    //     .note_start(), // pulse
    //     .note_release(), // pulse
    //     .note_reset(), //pulse
    //     .accumulated_value(accumulated_value),
    //     .valid(valid)
    // );
    //
    // reg [4:0] sine_shift, square_shift, triangle_shift, sawtooth_shift;
    // wire [19:0] sum_out;
    // nco_scaler_summer nco_scaler_summer (
    //     .accumulated_value(accumulated_value),
    //     .sine_shift(sine_shift),
    //     .square_shift(square_shift),
    //     .triangle_shift(triangle_shift),
    //     .sawtooth_shift(sawtooth_shift),
    //     .sum_out(sum_out)
    //
    //     // .sine_out(),
    //     // .square_out(),
    //     // .triangle_out(),
    //     // .sawtooth_out()
    // );
    //
    //
    // reg [4:0] global_gain;
    // wire [11:0] truncated_value;
    // global_gain_truncator global_gain_truncator(
    //     .global_gain(global_gain),
    //     .summer_value(sum_out),
    //     .truncated_value(truncated_value)
    // );
    //
    //
    // buffer #(
    //     .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ)
    // ) buffer (
    //     .clk(clk),
    //     .valid(valid),
    //     .rst(rst),  // Synth Reset? PWM Reset? Or CPU Reset?
    //     .from_truncator(truncated_value),
    //     .to_cdc(duty_cycle_synth),
    //     .ready(ready)
    // );

    // Seperated cycle/inst counter increment to avoid
    // multiple drivers
    always @(posedge clk) begin

        if (addr == `MM_UART_RST && MMap_Sel == `MMAP_STORE) begin
            cycle_counter <= 0;
            inst_counter <= 0;
        end else begin
            cycle_counter <= cycle_counter + 1;
            if (MMap_Sel != `MMAP_NO_NOP)
                inst_counter <= inst_counter + 1;
        end

    end

    always @(posedge clk) begin
        if (rst) begin
            MMap_dout <= 0;

            duty_cycle_cpu <= 0;
            tx_req <= 0;

            fcw_reg <= 0;
            sine_shift <= 0;
            square_shift <= 0;
            triangle_shift <= 0;
            sawtooth_shift <= 0;

            global_gain <= 0;

            source <= 0;


        end else if (en) begin

            if (MMap_Sel == `MMAP_LOAD) begin
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

                    // Add User I/O
                    `SWITCHES: begin
                        MMap_dout <= {{30{1'b0}}, switches};
                    end
                    `GPIO_FIFO_EMPTY: begin
                        MMap_dout <= {{31{1'b0}}, empty};
                    end

                    // PWM Integration
                    `PWM_TX_ACK: begin
                        MMap_dout <= {31'd0, tx_ack};
                    end

                    `NOTE_FINISHED: begin
                        MMap_dout <= {{31{1'b0}}, note_finished};
                    end

                    default: begin
                        MMap_dout <= 32'd0;
                    end
                endcase


            end else if (MMap_Sel == `MMAP_STORE) begin
                case (addr)
                    `GPIO_LEDS: begin
                        leds <= data[5:0];
                    end

                    `PWM_TX_REQ: begin
                        tx_req <= data[0];
                    end

                    `PWM_DUTY_CYCLE: begin
                        duty_cycle_cpu <= data[11:0];
                    end

                    `NCO_SINE: begin
                        sine_shift <= data[4:0];
                    end

                    `NCO_SQUARE: begin
                        square_shift <= data[4:0];
                    end

                    `NCO_TRIANGLE: begin
                        triangle_shift <= data[4:0];
                    end

                    `NCO_SAWTOOTH: begin
                        sawtooth_shift <= data[4:0];
                    end

                    `FCW: begin
                        fcw_reg <= data[23:0];
                    end

                    `GLOBAL_GAIN_SHIFT: begin
                        global_gain <= data[4:0];
                    end

                    `PWM_DAC_SOURCE: begin
                        source <= data[0];
                    end

                    default: begin
                        MMap_dout <= 32'd0;
                    end
                endcase
            end
        end
    end

  // This is async as fifo is synchronous component.
  assign rd_en = (MMap_Sel == `MMAP_LOAD && addr == `GPIO_FIFO_READ) ? 1 : 0;

endmodule
