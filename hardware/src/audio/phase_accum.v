module phase_accum (
    input clk,
    // This is connected to fcw register
    input [23:0] fcw,
    // These inputs are async
    input ready,
    // Assuming pulse signals
    input note_start,
    input note_release, //
    input note_reset, // reset accumlator
    output reg [23:0] accumulated_value,
    output reg valid,
    output reg note_finished
);

/*
Workflow with Buffer:
1. Ready is high and do the followings at the posedge
  - phase_accum send out the current accumulated value (via pipeline/non-pipeline) first,
    then increment.
  - phase_accum send out valid bit (via pipeline/non-pipeline).
  - phase_accum send out sent bit directly to buffer to notify ready should be low immediately;
    buffer should set the ready signal low asynchronously.
2. Ready is low and do the followings at the posedge
  - phase_accum should never increment its accumulated value.
*/

    reg idle = 1;
    reg [23:0] accumulator = 0;

    always @ (posedge clk) begin
        if (note_reset) begin
            accumulator <= 0;
            valid <= 0;
            idle <= 1;
            note_finished <= 0;
            // accumulated value can be anything as valid is never 1.
        end else if (note_release && !idle) begin
            valid <= 0;
            idle <= 1;
            note_finished <= 1;
        end else if (!idle && ready && !valid) begin
            accumulated_value <= accumulator;
            accumulator <= accumulator + fcw;
            valid <= 1;
        end else if (idle && note_start && ready && !valid) begin
            accumulated_value <= accumulator;
            accumulator <= accumulator + fcw;
            valid <= 1;
            idle <= 0;
        end else if (!idle && !ready) begin
            valid <= 0;
        end
    end

endmodule
