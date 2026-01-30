//DEFINE THE FIRST CORDIC WITH INPUTS X_IN, Y_IN, P_IN
//SHIRSUR TO PIPLINE IN GENERATE MODULE 30 TIMES
//DEFINE THE LAST CORDIC WITH OUPUTS X_OUT, Y_OUT, P_OUT
//DEVIDE BY 1.6764


//IN THE PIPELINE, EVERY STAGE HAS ITS OWN PHASE.
//THERFORE: THE SECOND STAGE'S PHASE IS 45
//THE THIRD SSTAGE'S PHASE IS 22.5
//MEANING THAT THE INPUT PHASE OF THE UNITCELL'S CORDIC 
//IS 2^(-i) DETERMINED BY IT'S STAGE NUMBER IN THE PIPLINE i


module pipeline(

// INPUT PORTS
input clk,
input rst_n,
input signed [8:0] x_in,
input signed [8:0] y_in,
input signed [31:0] phase_in,

// OUTPUT PORTS
output signed [8:0] x_out,
output signed [8:0] y_out,
output signed [31:0] phase_out
);

    wire signed [8:0] x_stage [0:31]; //WHY 32 AND NOT 31?
    wire signed [8:0] y_stage [0:31];
    wire signed [31:0] phase_stage [0:31];

    assign x_stage[0] = x_in;
    assign y_stage[0] = y_in;
    assign phase_stage[0] = phase_in;


genvar i;
generate
        for (i = 0; i < 31; i = i + 1) begin : cordic_stages
            cordic_phase_shifter #(
                .DEPTH(i),
                .LOG2_PHASE_SCALE(0)  // לשנות אם נדרש שינוי קנה מידה
            ) stage_inst (
                .clk(clk),
                .rst_n(rst_n),
                .x_in(x_stage[i]),
                .y_in(y_stage[i]),
                .p(phase_stage[i]), // קלט מטרה זהה לכולם
                .x_out(x_stage[i+1]),
                .y_out(y_stage[i+1]),
                .phase_final(phase_stage[i+1])
            );
        end
endgenerate

    assign x_out = x_stage[31];
    assign y_out = y_stage[31];
    assign phase_out = phase_stage[31];


endmodule