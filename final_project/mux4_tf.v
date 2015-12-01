`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:12:19 11/30/2015
// Design Name:   mux4
// Module Name:   /afs/athena.mit.edu/user/r/e/reaganm/6.111-final-project/6.111-final-project/final_project/mux4_tf.v
// Project Name:  final_project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mux4
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mux4_tf;

	// Inputs
	reg clk;
	reg [1:0] sel;
	reg [18:0] A;
	reg [18:0] B;
	reg [18:0] C;
	reg [18:0] D;

	// Outputs
	wire [18:0] Y;

	// Instantiate the Unit Under Test (UUT)
	mux4 uut (
		.clk(clk), 
		.sel(sel), 
		.A(A), 
		.B(B), 
		.C(C), 
		.D(D), 
		.Y(Y)
	);
	always #12 clk = !clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		sel = 0;
		A = 0;
		B = 1;
		C = 2;
		D = 3;

		// Wait 100 ns for global reset to finish
		#100;
      sel = 1;
		// Add stimulus here

	end
      
endmodule

