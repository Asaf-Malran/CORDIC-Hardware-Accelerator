module cordic_phase_shifter_tb ();    // simple counter test-bench 


reg clk ;                     // Testbench clk
reg rst_n;                     // Testbench rst_n

reg signed [8:0] x_in;
reg signed [8:0] y_in;
reg signed [31:0] p;

wire signed [8:0] x_out;
wire signed [8:0] y_out;
wire signed [31:0] phase_final;

localparam An = 320/1.647;

initial begin   // Testbench Wakeup setup
    p = 16'b0011010101010101;
    x_in = An*0.984808;      // Xout = 32000*cos(angle)
    y_in = An*0.173648;      // Yout = 32000*sin(angle)
    //set clock
    clk = 1;
    rst_n = 0;
    #20 rst_n = 1;
    #1000
    $write("Simulation has finished");
    $stop;
end
  
always #5 clk = !clk ;  // Toggle the clk forever every 5 time units

cordic_phase_shifter #(.DEPTH(0), .LOG2_PHASE_SCALE(16)) i_cordic_phase_shifter (
      .clk(clk),
      .rst_n(rst_n),
      .x_in(x_in),
      .y_in(y_in),
      .p(p),
      .x_out(x_out),
      .y_out(y_out),
      .phase_final(phase_final)
  );

endmodule

