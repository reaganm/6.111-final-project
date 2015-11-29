`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:01:18 11/28/2015
// Design Name:   divider
// Module Name:   C:/Users/reaganm/Documents/6.111/final_proj/divider_tf.v
// Project Name:  final_proj
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: divider
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module divider_tf;

	// Inputs
	reg clk;
	reg sign;
	reg start;
	reg [12:0] dividend;
	reg [12:0] divider;

	// Outputs
	wire [12:0] quotient;
	wire [12:0] remainder;
	wire ready;

	// Instantiate the Unit Under Test (UUT)
	divider uut (
		.clk(clk), 
		.sign(sign), 
		.start(start), 
		.dividend(dividend), 
		.divider(divider), 
		.quotient(quotient), 
		.remainder(remainder), 
		.ready(ready)
	);
	always #12 clk = !clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		sign = 0;
		start = 0;
		dividend = 0;
		divider = 0;

		// Wait 100 ns for global reset to finish
		#100;
      divider = 468*3;
		dividend = 5;
		sign = 0;
		start = 1;
		// Add stimulus here

	end
      
endmodule

