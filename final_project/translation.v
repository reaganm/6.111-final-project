`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:11:50 11/29/2015 
// Design Name: 
// Module Name:    translation 
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
module translation(
    input clk,
	 input reset,
	 input signed [4:0] dist,
    input signed [11:0] x,
    input signed [11:0] y,
    output signed [11:0] x_trans,
    output signed [10:0] y_trans
    );
	
	reg signed [11:0] x_reg;
	reg signed [11:0] y_reg;
	
	always@(posedge clk) begin
		x_reg <= x +dist;
		y_reg <= y +dist;
	end

	assign x_trans = x_reg[11:0];
	assign y_trans = y_trans[10:0];
	
endmodule
