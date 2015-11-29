`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:12:12 11/29/2015 
// Design Name: 
// Module Name:    zbt_arbiter 
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
module zbt_arbiter(
	input clk,
	input reset,
	input signed [11:0] x,
   input signed [11:0] y,
   input signed [11:0] x_rot,
   input signed [10:0] y_rot,
	input [10:0] hcount,
	input [9:0] vcount,	
	output[15:0] pixel, 
	output currentram
  );
  
  reg new_addr = 


endmodule
