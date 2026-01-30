module cordic_phase_shifter #(parameter DEPTH = 1, LOG2_PHASE_SCALE = 1)(
// INPUT PORTS
input clk,
input rst_n,
input signed [8:0] x_in,
input signed [8:0] y_in,
input signed [31:0] p,
// OUTPUT PORTS
output reg signed [8:0] x_out,
output reg signed [8:0] y_out,
output reg signed [31:0] phase_final
);

wire signed [31:0] atan_table [0:30];

   assign atan_table[0]  = 32'b00100000000000000000000000000000;//  45.000 degrees -> atan(2^0)  , scaled by (2^32)/360  degree bit resolution
   assign atan_table[1]  = 32'b00010010111001000000010100011101;//  26.565 degrees -> atan(2^-1)
   assign atan_table[2]  = 32'b00001001111110110011100001011011;//  14.036 degrees -> atan(2^-2)
   assign atan_table[3]  = 32'b00000101000100010001000111010100;//  atan(2^-n) ...
   assign atan_table[4]  = 32'b00000010100010110000110101000011;
   assign atan_table[5]  = 32'b00000001010001011101011111100001;
   assign atan_table[6]  = 32'b00000000101000101111011000011110;
   assign atan_table[7]  = 32'b00000000010100010111110001010101;
   assign atan_table[8]  = 32'b00000000001010001011111001010011;
   assign atan_table[9]  = 32'b00000000000101000101111100101110;
   assign atan_table[10] = 32'b00000000000010100010111110011000;
   assign atan_table[11] = 32'b00000000000001010001011111001100;
   assign atan_table[12] = 32'b00000000000000101000101111100110;
   assign atan_table[13] = 32'b00000000000000010100010111110011;
   assign atan_table[14] = 32'b00000000000000001010001011111001;
   assign atan_table[15] = 32'b00000000000000000101000101111101;
   assign atan_table[16] = 32'b00000000000000000010100010111110;
   assign atan_table[17] = 32'b00000000000000000001010001011111;
   assign atan_table[18] = 32'b00000000000000000000101000101111;
   assign atan_table[19] = 32'b00000000000000000000010100011000;
   assign atan_table[20] = 32'b00000000000000000000001010001100;
   assign atan_table[21] = 32'b00000000000000000000000101000110;
   assign atan_table[22] = 32'b00000000000000000000000010100011;
   assign atan_table[23] = 32'b00000000000000000000000001010001;
   assign atan_table[24] = 32'b00000000000000000000000000101000;
   assign atan_table[25] = 32'b00000000000000000000000000010100;
   assign atan_table[26] = 32'b00000000000000000000000000001010;
   assign atan_table[27] = 32'b00000000000000000000000000000101;
   assign atan_table[28] = 32'b00000000000000000000000000000010;
   assign atan_table[29] = 32'b00000000000000000000000000000001;
   assign atan_table[30] = 32'b00000000000000000000000000000000;


reg signed [8:0] next_x_out, next_y_out;
reg signed [31:0] next_phase_final;
wire signed [31:0] atan_val;

always @(posedge clk) begin
    if (!rst_n) begin
        x_out <= x_in;
        y_out <= y_in;
        phase_final <= p;
    end 
    else begin
        x_out <= next_x_out;
        y_out <= next_y_out;
        phase_final <= next_phase_final;
    end
end

// Defining Casted Parameter
localparam [8:0] DEPTH_CASTED = DEPTH[8:0];

assign atan_val = atan_table[DEPTH_CASTED] >>> LOG2_PHASE_SCALE;

always @* begin
    next_x_out = x_in + (y_in >>> DEPTH_CASTED);
    next_y_out = y_in - (x_in >>> DEPTH_CASTED);
    next_phase_final = p + atan_val;

    if (p[31] == 1'b0) begin
        next_x_out = x_in - (y_in >>> DEPTH_CASTED);
        next_y_out = y_in + (x_in >>> DEPTH_CASTED);
        next_phase_final = p - atan_val;
    end
end

endmodule