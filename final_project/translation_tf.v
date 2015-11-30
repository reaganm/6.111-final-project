`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:48:16 11/30/2015
// Design Name:   translation
// Module Name:   /afs/athena.mit.edu/user/r/e/reaganm/6.111-final-project/6.111-final-project/final_project/translation_tf.v
// Project Name:  final_project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: translation
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module translation_tf;

	// Inputs
	reg clk;
	reg reset;
	reg [4:0] dist;
	reg [11:0] x;
	reg [11:0] y;

	// Outputs
	wire [11:0] x_trans;
	wire [10:0] y_trans;

	// Instantiate the Unit Under Test (UUT)
	translation uut (
		.clk(clk), 
		.reset(reset), 
		.dist(dist), 
		.x(x), 
		.y(y), 
		.x_trans(x_trans), 
		.y_trans(y_trans)
	);
	
	always #12 clk = !clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		dist = 0;
		x = 0;
		y = 0;

		// Wait 100 ns for global reset to finish
		#100;
      x=100;
		y=100;
		dist = 6;
		// Add stimulus here

	end
      
endmodule

