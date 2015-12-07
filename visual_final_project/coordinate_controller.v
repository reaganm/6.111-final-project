`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:52:06 11/28/2015 
// Design Name: 
// Module Name:    coordinate_controller 
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
module coordinate_controller(
	 input clk,
	 input [9:0] tempo,
	 output [31:0] angle
    );
	
	// Table of angles to choose from: -16 to 16 degrees
	// Only need 0-15 actually in table
	
	parameter TEMPO_MIN = 59;
	parameter TEMPO_MAX = 240;
	parameter TEMPO_STEP = (TEMPO_MAX-TEMPO_MIN);
	
	wire signed [31:0] ang_table [0:16];
	reg signed [31:0] angle_reg;
	
	assign ang_table[00] = 32'b0;
	assign ang_table[01] = 32'b00000000101101100000101101100000; // 1 degree
	assign ang_table[02] = 32'b00000001011011000001011011000001; // 2 degrees
	assign ang_table[03] = 32'b00000010001000100010001000100010; // 3 degrees
	assign ang_table[04] = 32'b00000010110110000010110110000011; // etc...
	assign ang_table[05] = 32'b00000011100011100011100011100011;
	assign ang_table[06] = 32'b00000100010001000100010001000100;
	assign ang_table[07] = 32'b00000100111110100100111110100100;
	assign ang_table[08] = 32'b00000101101100000101101100000101;
	assign ang_table[09] = 32'b00000110011001100110011001100110;
	assign ang_table[10] = 32'b00000111000111000111000111000111;
	assign ang_table[11] = 32'b00000111110100100111110100100111;
	assign ang_table[12] = 32'b00001000100010001000100010001000;
	assign ang_table[13] = 32'b00001001001111101001001111101001;
	assign ang_table[14] = 32'b00001001111101001001111101001010;
	assign ang_table[15] = 32'b00001010101010101010101010101010;
	assign ang_table[16] = 32'b00001010101010101010101010101010;
	
	reg [4:0] i;
	
	always@(posedge clk) begin	
		if (tempo == 0) angle_reg <= ang_table[00];
		else begin
			for (i = 0; i < 16; i = i+1) begin			
				if ((tempo > TEMPO_MIN+TEMPO_STEP*i/16) && tempo < TEMPO_MIN+TEMPO_STEP*(i+1)/16)
				angle_reg <= ang_table[i+1];
			end
		end
	end
		
  assign angle = angle_reg;
	//assign angle = 0;
	
endmodule
