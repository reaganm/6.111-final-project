`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:48:33 12/04/2015 
// Design Name: 
// Module Name:    color_shft 
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
module color_shft(
	 input reset,
	 input shft,	
    input [23:0] vr,
    output [23:0] pixel	 
    );
	
	reg [4:0] i = 0;
	wire [7:0] shifted_red;
	wire  [7:0] shifted_green;
	wire  [7:0] shifted_blue;
	
	always@(posedge shft) begin
		if (reset) i <= 0;
		else i <= i + 1;
	end
	
	assign shifted_red = (i == 0) ? vr[23:16] : vr[23:16]*(i+3)*i;
	assign shifted_green = (i == 0) ? vr[15:8] : vr[15:8]*(i+2)*i;
	assign shifted_blue = (i == 0) ? vr[7:0] : vr[7:0]*i*i;		
//	assign shifted_red = vr[23:16];
//	assign shifted_green = vr[15:8];
//	assign shifted_blue = vr[7:0];			
//	
	
	assign pixel = {shifted_red, shifted_green, shifted_blue};
	
endmodule
