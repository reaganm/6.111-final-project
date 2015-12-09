`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:30:04 11/30/2015 
// Design Name: 
// Module Name:    mux4 
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

module mux4 (clk, sel, A, B, C, D, Y);
	input clk;
	input [1:0] sel;

	input [18:0] A, B, C, D;
	output [18:0] Y;
	reg [18:0] y;

  always @(posedge clk) begin
		case(sel)
			2'b00: y <= A;
			2'b01: y <= B;
			2'b10: y <= C;
			2'b11: y <= D;
			default: y <= A;
		endcase	
	end
	
	assign Y = y;
endmodule

