`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:31:12 11/29/2015
// Design Name:   coordinate_controller
// Module Name:   /afs/athena.mit.edu/user/r/e/reaganm/6.111-final-project/6.111-final-project/final_project/coordinate_controller_tf.v
// Project Name:  final_project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: coordinate_controller
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module coordinate_controller_tf;

	// Inputs
	reg clk;
	reg [9:0] tempo;

	// Outputs
	wire [31:0] angle;

	// Instantiate the Unit Under Test (UUT)
	coordinate_controller uut (
		.clk(clk), 
		.tempo(tempo), 
		.angle(angle)
	);
	always #12 clk = !clk; // 25 ns clock
	
	initial begin
		// Initialize Inputs
		clk = 0;
		tempo = 0;

		// Wait 100 ns for global reset to finish
		#108;
      
		tempo = 120;
		// Add stimulus here
		
		#24
		tempo = 200;

	end
      
endmodule

