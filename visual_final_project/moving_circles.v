`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:15:46 12/06/2015 
// Design Name: 
// Module Name:    moving_circles 
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
module moving_circles #(parameter COLOR = 24'hFFFFFF, parameter RAD = 100, 
	parameter START= 0, parameter X = 400, parameter Y = 300)(
	 input clk,
	 input reset,
	 input vsync,
	 input [9:0] tempo,
	 input [10:0] hcount, 
	 input [9:0] vcount,	 
	 output [23:0] pixel,
	 output [9:0] count
	 );
	 	
	 parameter RAD_in = RAD-15;	

	 reg [7:0] rad_count = 0;
	 reg [12:0] counter = 0;
	 reg [23:0] r_sq_out;
	 reg [23:0] r_sq_in;
	 
	 reg [10:0] deltax;
	 reg [9:0] deltay;
	 
	 
	 reg [23:0] pix;
	 reg [23:0] dist_out;
	 reg [23:0] dist_in;
	 reg [10:0] radius_out;
	 reg [10:0] radius_in;
	 
	 always@(posedge clk) begin
			radius_out <= RAD + rad_count;
			radius_in <= RAD_in + rad_count;
			r_sq_out <= radius_out*radius_out;
			r_sq_in <= radius_in*radius_in;
			
			deltax <= (hcount > X) ? (hcount-X) : (X-hcount); 
			deltay <= (vcount > Y) ? (vcount-Y) : (Y-vcount);
			
			dist_out <= deltax*deltax+deltay*deltay;			
			
			if(dist_out <= r_sq_out && dist_out >= r_sq_in) pix <= COLOR; 
			else pix <= 0;
	 end	
	 
	 
	 always@(posedge vsync) begin						
			if (reset) begin
				rad_count <= 0;
				counter <= 0; end			
			if (rad_count == 256) counter <= 0;
			else counter <= counter + 1;			
			rad_count <= ((counter + tempo/16) < START) ? 0 : rad_count + tempo/16; 
	 end
	 
	 assign count = rad_count;
	 assign pixel = pix;

endmodule
