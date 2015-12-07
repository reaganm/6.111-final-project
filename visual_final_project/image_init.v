`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:19:15 11/29/2015 
// Design Name: 
// Module Name:    image_init 
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
module image_init #(parameter COLOR = 16'hFFFF)(
	input clk,
	input [9:0] tempo,
	input [10:0] hcount,
	input [9:0] vcount,	
	input vsync,
	input circle,
	output[23:0] pixel);
	
	wire [23:0] circle1_pix;
	wire [23:0] circle2_pix;
	wire [23:0] circle3_pix;
	wire [23:0] circle4_pix;
	wire [23:0] circle5_pix;
	wire [23:0] circle6_pix;
	wire [23:0] circle7_pix;
	wire [23:0] circle8_pix;
	wire [23:0] circle9_pix;
	wire [23:0] circle10_pix;
	wire [23:0] circle11_pix;
	wire [23:0] pixel_circle;
	
	wire [23:0] pixel_blob;
	wire [15:0] pixel_top_1;
	wire [15:0] pixel_bot_1;
	wire [15:0] pixel_l_1;
	wire [15:0] pixel_r_1;
	
	wire [15:0] pixel_top_2;
	wire [15:0] pixel_bot_2;
	wire [15:0] pixel_l_2;
	wire [15:0] pixel_r_2;
	
	wire [15:0] pixel_top_3;
	wire [15:0] pixel_bot_3;
	wire [15:0] pixel_l_3;
	wire [15:0] pixel_r_3;
	
	blob #(.WIDTH(500), .HEIGHT(10), .COLOR(24'h0F0309)) top1(.x(150), .y(50), .hcount(hcount), .vcount(vcount), .pixel(pixel_top_1));
	blob #(.WIDTH(510), .HEIGHT(10), .COLOR(24'h0F0309)) bottom1(.x(150), .y(550), .hcount(hcount), .vcount(vcount), .pixel(pixel_bot_1));
	blob #(.WIDTH(10), .HEIGHT(500), .COLOR(24'h0F0309)) left1(.x(150), .y(50), .hcount(hcount), .vcount(vcount), .pixel(pixel_l_1));
	blob #(.WIDTH(10), .HEIGHT(500), .COLOR(24'h0F0309)) right1(.x(650), .y(50), .hcount(hcount), .vcount(vcount), .pixel(pixel_r_1));
	
	
	blob #(.WIDTH(400), .HEIGHT(10), .COLOR(24'h490099)) top2(.x(200), .y(100), .hcount(hcount), .vcount(vcount), .pixel(pixel_top_2));
	blob #(.WIDTH(410), .HEIGHT(10), .COLOR(24'h490099)) bottom2(.x(200), .y(500), .hcount(hcount), .vcount(vcount), .pixel(pixel_bot_2));
	blob #(.WIDTH(10), .HEIGHT(400), .COLOR(24'h490099)) left2(.x(200), .y(100), .hcount(hcount), .vcount(vcount), .pixel(pixel_l_2));
	blob #(.WIDTH(10), .HEIGHT(400), .COLOR(24'h490099)) right2(.x(600), .y(100), .hcount(hcount), .vcount(vcount), .pixel(pixel_r_2));
	
	blob #(.WIDTH(300), .HEIGHT(10), .COLOR(24'h995000)) top3(.x(250), .y(150), .hcount(hcount), .vcount(vcount), .pixel(pixel_top_3));
	blob #(.WIDTH(310), .HEIGHT(10), .COLOR(24'h995000)) bottom3(.x(250), .y(450), .hcount(hcount), .vcount(vcount), .pixel(pixel_bot_3));
	blob #(.WIDTH(10), .HEIGHT(300), .COLOR(24'h995000)) left3(.x(250), .y(150), .hcount(hcount), .vcount(vcount), .pixel(pixel_l_3));
	blob #(.WIDTH(10), .HEIGHT(300), .COLOR(24'h995000)) right3(.x(550), .y(150), .hcount(hcount), .vcount(vcount), .pixel(pixel_r_3));
	
	assign pixel_blob = pixel_top_1 | pixel_bot_1 | pixel_l_1 | pixel_r_1 | 
						pixel_top_2 | pixel_bot_2 | pixel_l_2 | pixel_r_2 |
						pixel_top_3 | pixel_bot_3 | pixel_l_3 | pixel_r_3;
	
	moving_circles #(.COLOR(24'hFF0000)) circle1(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle1_pix));
	
	moving_circles #(.COLOR(24'h999900), .START(200)) circle2(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle2_pix));
				
	moving_circles #(.COLOR(24'h995000), .START(100)) circle3(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle3_pix));
				
	moving_circles #(.COLOR(24'h009900), .START(50)) circle4(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle4_pix));
				
	moving_circles #(.COLOR(24'h000099), .START(150)) circle5(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle5_pix));
	
	moving_circles #(.COLOR(24'h490099), .START(250)) circle6(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle6_pix));
				
	moving_circles #(.COLOR(24'hF03090)) circle7(.clk(clk), .reset(reset), .vsync(vsync), .tempo(0),
				.hcount(hcount), .vcount(vcount), .pixel(circle7_pix));
	
	moving_circles #(.COLOR(24'h0F0309), .X(100), .Y(100)) circle8(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle8_pix));
	
	moving_circles #(.COLOR(24'h0F0309), .X(700), .Y(500)) circle9(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle9_pix));
				
	moving_circles #(.COLOR(24'h0F0309), .X(100), .Y(500)) circle10(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle10_pix));
	
	moving_circles #(.COLOR(24'h0F0309), .X(700), .Y(100)) circle11(.clk(clk), .reset(reset), .vsync(vsync), .tempo(tempo),
				.hcount(hcount), .vcount(vcount), .pixel(circle11_pix));
	
	assign pixel_circle = (circle1_pix | circle2_pix | circle3_pix |
			 circle4_pix | circle5_pix | circle6_pix | circle7_pix |
			 circle8_pix |circle9_pix | circle10_pix | circle11_pix);

	assign pixel = circle ? pixel_circle : pixel_blob;
	
endmodule
	//////////////////////////////////////////////////////////////////////
//
// blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////
module blob
   #(parameter WIDTH = 64,            // default width: 64 pixels
               HEIGHT = 64,           // default height: 64 pixels
               COLOR = 24'hFFFFFF)  // default color: white
   (input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] pixel);

   always @ * begin
      if ((hcount >= x && hcount < (x+WIDTH)) &&
				(vcount >= y && vcount < (y+HEIGHT)))
				pixel = COLOR;
      else pixel = 0;
   end
endmodule


