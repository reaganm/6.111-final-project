`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:13:38 11/18/2015 
// Design Name: 
// Module Name:    address_generator 
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
module address_generator(
	 input clk,
    input [10:0] x,
    input [9:0] y,
    output [20:0] address
    );
	 reg addr;
	 
	always@(posedge clk) begin
		addr = x*y;
	end
	
	assign address = addr;
	
endmodule
