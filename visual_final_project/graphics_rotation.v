`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:00:01 12/06/2015 
// Design Name: 
// Module Name:    graphics_rotation 
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
module graphics_rotation(
	 input clk,
	 input reset,
	 input init,
	 input circle,
	 input [2:0] addr_count,
	 input [9:0] tempo,
    input [10:0] hcount,
	 input [9:0] vcount,
	 output [18:0] vram_addr2,
	 output [18:0] vram_addr3	 
	 );
	
	wire [23:0] init_pixel;	
	wire [31:0] angle;
	wire [11:0] x_rot;
	wire [10:0] y_rot;	
	wire [11:0] x_trans;
	wire [10:0] y_trans;
	wire [11:0] x_in;
	wire [10:0] y_in;
	 
	wire [10:0] hcount_f = (hcount >= 1045) ? (hcount - 1045) : (hcount + 11);
   wire [9:0] vcount_f = (hcount >= 1045) ? ((vcount == 627) ? 0 : vcount +1) : vcount;
	
	coordinate_controller c1(.clk(clk), .tempo(tempo), .angle(angle));
	
	translation t1(.clk(clk), .reset(reset), .dist(10), .x({1'b0, hcount_f[10:0]}), .y({2'b0, vcount_f[9:0]}),
			.x_trans(x_trans), .y_trans(y_trans));
			
	rotation r1(.clk(clk), .reset(reset), .angle(angle), .x({1'b0, hcount_f[10:0]}), .y({2'b0, vcount_f[9:0]}),
			.x_rot(x_rot), .y_rot(y_rot));
	

	wire [18:0] vram_addr_init = {hcount[10:0] + vcount[9:0]*800};
	
	wire [18:0] vram_addrA = {x_rot[10:0] + y_rot[9:0]*800};  
	wire [18:0] vram_addrB = {x_rot[10:0] - 1 + y_rot[9:0]*800};
	wire [18:0] vram_addrC = {x_rot[10:0] + (y_rot[9:0]-1)*800};
	wire [18:0] vram_addrD = {x_rot[10:0] - 1 + (y_rot[9:0]-1)*800};
	
	wire [18:0] vram_addrA1 = {x_rot[10:0] + y_rot[9:0]*800};  
	wire [18:0] vram_addrB1 = {x_rot[10:0] + 1 + y_rot[9:0]*800};
	wire [18:0] vram_addrC1 = {x_rot[10:0] + (y_rot[9:0]+1)*800};
	wire [18:0] vram_addrD1 = {x_rot[10:0] + 1 + (y_rot[9:0]+1)*800};
	
	wire [18:0] vram_addrTrans = {x_trans[10:0] + y_trans[9:0]*800};
	
	mux4 addr_mux(.clk(clk), .sel(addr_count), .A(vram_addrA), .B(vram_addrB),
			.C(vram_addrC), .D(vram_addrD), .Y(vram_addr2));	
	
	mux4 addr_mux1(.clk(clk), .sel(addr_count), .A(vram_addrA1), .B(vram_addrB1),
			.C(vram_addrC1), .D(vram_addrD1), .Y(vram_addr3));
	
	image_init im0(.clk(clk), .tempo(tempo), .circle(circle),.hcount(hcount), .vcount(vcount), .pixel(init_pixel));

endmodule
