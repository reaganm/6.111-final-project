`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:16:09 11/18/2015 
// Design Name: 
// Module Name:    rotation 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module rotation(
	 input clk,
	 input reset,
	 input signed [31:0] angle,
    input signed [11:0] x,
    input signed [11:0] y,
    output signed [11:0] x_rot,
    output signed [10:0] y_rot,
	 output signed [31:0] x_rot_large,
	 output signed [31:0] y_rot_large
    );
	 parameter XSIZE = 12;
	 parameter YSIZE = 12;
	 
	 wire signed [31:0] atan [0:12] ;
	 wire signed [9:0] m;
	 wire signed [10:0] n;
	 
//	 wire signed [31:0] x_rot_large;
//    wire signed [31:0] y_rot_large;
//	 reg signed [31:0] x_rot_large1;
//	 reg signed [31:0] y_rot_large1;
	 
	 //Want a high-precision table of arctan values; however, since our maximum iteration is 11, 
	 //our table needs only 11 entires.  If we wanted more precise x/y values table would be larger.	 
	 assign atan[00] = 32'b00100000000000000000000000000000; // 45 degrees or atan(2^0)
	 assign atan[01] = 32'b00010010111001000000010100011101; // atan(2^-1)
	 assign atan[02] = 32'b00001001111110110011100001011011; // atan(2^-2)
	 assign atan[03] = 32'b00000101000100010001000111010100; // atan(2^-3)
	 assign atan[04] = 32'b00000010100010110000110101000011;
	 assign atan[05] = 32'b00000001010001011101011111100001;
	 assign atan[06] = 32'b00000000101000101111011000011110;
	 assign atan[07] = 32'b00000000010100010111110001010101;
	 assign atan[08] = 32'b00000000001010001011111001010011;
	 assign atan[09] = 32'b00000000000101000101111100101110;
	 assign atan[10] = 32'b00000000000010100010111110011000;
	 assign atan[11] = 32'b00000000000001010001011111001100;
	 assign atan[12] = 32'b00000000000000101000101111100110;
	 
	 // Must create shift register to store value of x, since it takes 11 clock cycles to calculate
	 reg signed [XSIZE:0] x_reg [0:XSIZE-1];
	 reg signed [YSIZE:0] y_reg [0:YSIZE-1];
	 reg signed [31:0] z_reg [0:XSIZE-1];	 
	 
//	 reg signed [XSIZE:0] x_reg1 [0:XSIZE-1];
//	 reg signed [YSIZE:0] y_reg1 [0:YSIZE-1];
//	 reg signed [31:0] z_reg1 [0:XSIZE-1];
	 	 
	 always@(posedge clk) begin
		// Initialize x_reg and y_reg		
		x_reg[0] <= x - 400;
		y_reg[0] <= y - 300;
//		x_reg1[0] <= x - 400;
//		y_reg1[0] <= y - 300;
		z_reg[0] <= angle;
		
	end
	
	// Want to generate new foor loop or each new input

	generate
	genvar i;
		for (i=0; i<(XSIZE-1); i= i+1)
			begin: gen1
				wire z_sign = z_reg[i][31];
				
				wire signed [XSIZE:0] x_shft ;
				wire signed [YSIZE:0] y_shft ;				
				assign x_shft = x_reg[i] >>> i;				
				assign y_shft = y_reg[i] >>> i;
				
				always@(posedge clk) begin
//					x_reg[i+1] <= z_sign ? x_reg[i] + y_shft : x_reg[i] - y_shft;
//				   y_reg[i+1] <= z_sign ? y_reg[i] - x_shft : y_reg[i] + x_shft;
//					z_reg[i+1] <= z_sign ? z_reg[i] + atan[i] : z_reg[i] - atan[i];
					x_reg[i+1] <= x_reg[i];
					y_reg[i+1] <= y_reg[i];
					z_reg[i+1] <= z_reg[i];
				end
			end
	endgenerate
	
	// End result has gain of 1.647, want to multiply by inverse .6072. Can be approximated with 311/512 = .6074.
	assign m = 311;
	assign n = 512;
	
//	always@(posedge clk)begin
//		 x_rot_large <= (x_reg[XSIZE -1] * m) >>> 9;
//		 y_rot_large <= (y_reg[YSIZE -1] * m) >>> 9;
//		 
////		 x_rot_large1 <= (x_reg[XSIZE -1] * 2) >>> 1;
////		 y_rot_large1 <= (y_reg[YSIZE -1] * 2) >>> 1;
//	end
//	assign x_rot_large = x_reg[XSIZE -1] * m / n;
//	assign y_rot_large = y_reg[YSIZE -1] * m / n;
	assign x_rot_large = x_reg[XSIZE -1];
	assign y_rot_large = y_reg[XSIZE -1];
	
	wire [31:0] y_rot_norm = 300 + y_rot_large;
	wire [31:0] x_rot_norm = 400 + x_rot_large;
	
//	wire [31:0] y_rot_norm1 = 300 + y_rot_large1;
//	wire [31:0] x_rot_norm1 = 400 + x_rot_large1;
	
	assign x_rot = {x_rot_norm[31], x_rot_norm[10:0]};
	assign y_rot = {y_rot_norm[31], y_rot_norm[9:0]};
	
endmodule
