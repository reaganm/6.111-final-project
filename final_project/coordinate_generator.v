`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:01:40 11/18/2015 
// Design Name: 
// Module Name:    coordinate_generator 
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
module coordinate_generator 
	#(parameter WIDTH = 800, // Image width and height
					HEIGHT = 600)
	(input done,
    input clk,
    input reset,
    output [10:0] x, 
	 output [9:0] y);
	 
	 // counts from 0 to (800,600)
	 always@(posedge clk) begin
		if (reset || done) begin
		x <= 0;
		y <= 0;
		end
		else if (x == WIDTH) x <= 0;
		else if (y == HEIGHT) y <= 0;
		else begin	
		x <= x+1;
		y <= y+1;
		end
	end
endmodule
