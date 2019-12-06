module phase_accum (
    input clk,
    // This is connected to fcw register
    input [23:0] fcw,
    // These inputs are async
    input ready,
    // Either one of the following inputs will be high
    input note_start,
    input note_release, // 
    input note_reset, // reset accumlator
    output reg [23:0] accumulated_value,
    // output sent, (possibly for pipeline version)
    output reg valid
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

    reg [23:0] accumulator = 0;

    always @ (posedge clk) begin
        if (note_reset) begin
            accumulator <= 0;
            valid <= 0;
            // accumulated value can be anything as valid is never 1.
            // sent <= 0; (possibly for pipeline version)
        end else if (note_release || !ready) begin
            valid <= 0;
        end else if (note_start && ready) begin
            accumulated_value <= accumulator;
            accumulator <= accumulator + fcw;
            valid <= 1;
            // sent <= 1; (possibly for pipeline version)
        end
    end

endmodule
