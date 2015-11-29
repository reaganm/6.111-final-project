`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:01:41 11/28/2015
// Design Name:   rotation
// Module Name:   C:/Users/reaganm/Documents/6.111/final_proj/rotation_tf.v
// Project Name:  final_proj
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: rotation
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module rotation_tf;

	// Inputs
	reg clk;
	reg reset;
	reg signed [31:0] angle;
	reg signed [11:0] x;
	reg signed [11:0] y;

	// Outputs
	wire signed [11:0] x_rot;
	wire signed [10:0] y_rot;

	// Instantiate the Unit Under Test (UUT)
	rotation uut (
		.clk(clk), 
		.reset(reset), 
		.angle(angle), 
		.x(x), 
		.y(y), 
		.x_rot(x_rot), 
		.y_rot(y_rot)
	);
		
	always #12 clk = !clk; // 25 ns clock
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		angle = 0;
		x = 0;
		y = 0;		
		
		// Wait 100 ns for global reset to finish
		#100;        
		// Add stimulus here
		
		x = 200;		
		y = 400;
		angle = 32'b00100000000000000000000000000000;
		
		#24
		x = 500;
		y = 300;
		angle = 32'b00100000000000000000000000000000;
		
		
	end
      
endmodule

