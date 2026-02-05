
module cordic_pipeline_32_tb;

    parameter CLK_PERIOD = 10;
    parameter NUM_INPUTS = 100;

    reg clk, rst_n;
    reg signed [8:0] x_in, y_in;
    reg signed [31:0] phase_in;
    wire signed [8:0] x_out, y_out;
    wire signed [31:0] phase_out;

    reg [8:0] x_mem [0:NUM_INPUTS-1];
    reg [8:0] y_mem [0:NUM_INPUTS-1];
    reg [31:0] phase_mem [0:NUM_INPUTS-1];

    integer x_file, y_file, p_file;
    integer i;


    pipeline i_pipeline (
        .clk(clk),
        .rst_n(rst_n),
        .x_in(x_in),
        .y_in(y_in),
        .phase_in(phase_in),
        .x_out(x_out),
        .y_out(y_out),
        .phase_out(phase_out)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        x_in = 0;
        y_in = 0;
        phase_in = 0;

        $readmemh("x_in.mem", x_mem);
        $readmemh("y_in.mem", y_mem);
        $readmemh("p_in.mem", phase_mem);

        x_file = $fopen("x_out.txt", "w");
        y_file = $fopen("y_out.txt", "w");
        p_file = $fopen("p_out.txt", "w");

        #(2*CLK_PERIOD);
        rst_n = 1;
    end

    integer input_idx = 0;
    always @(posedge clk) begin
        if (rst_n) begin
            if (input_idx < NUM_INPUTS) begin
                x_in     <= x_mem[input_idx];
                y_in     <= y_mem[input_idx];
                phase_in <= phase_mem[input_idx];
                input_idx = input_idx + 1;
            end else begin
                x_in     <= 0;
                y_in     <= 0;
                phase_in <= 0;
            end
        end
    end

    integer cycle_count = 0;
    reg signed [15:0] x_out_norm, y_out_norm;
    always @(posedge clk) begin
        if (rst_n) begin
            cycle_count = cycle_count + 1;
            if (cycle_count > 32) begin
                x_out_norm = $rtoi($itor(x_out) * 0.61);
                y_out_norm = $rtoi($itor(y_out) * 0.61);

                $fwrite(x_file, "%02X\n", x_out_norm[7:0]);
                $fwrite(y_file, "%02X\n", y_out_norm[7:0]);
                $fwrite(p_file, "%X\n", phase_out);
            end

            if (cycle_count == NUM_INPUTS + 32) begin
                $fclose(x_file);
                $fclose(y_file);
                $fclose(p_file);
                $finish;
            end
        end
    end

endmodule
