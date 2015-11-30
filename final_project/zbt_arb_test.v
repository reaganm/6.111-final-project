`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:40:25 11/29/2015 
// Design Name: 
// Module Name:    zbt_arb_test 
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
module zbt_arb_test(
	input clk,
	input reset,
	input signed [11:0] x,
	input signed [11:0] y,
	input signed [11:0] x_rot,
	input signed [10:0] y_rot,
	input [10:0] hcount,
	input [9:0] vcount,	
	output[15:0] pixel
  );
  
  // wire up to ZBT ram
	wire [35:0] vram_write_data, vram_write_data_init, vram_write_data1;
   wire [35:0] vram0_read_data, vram1_read_data, vram_read_data;
   wire [18:0] vram_addr, vram0_addr, vram1_addr;
   wire        vram_we, vram0_we, vram1_we;
   reg we_render;
   reg currentram;
	reg init;
   wire ram0_clk_not_used;
	wire [9:0] tempo;
	wire [31:0] angle;
	//wire [11:0] x_rot;
	//wire [10:0] y_rot;
	
	// generate pixel value from reading ZBT memory
   wire [15:0] 	vr_pixel;
	wire [15:0] 	init_pixel;
   wire [18:0] 	vram_addr1;
	
	assign tempo = 0;
	
	wire [18:0] vram_addr_init = {hcount[10:0] + vcount[9:0]*800};
	
	
	assign vram0_addr = (~init ? vram_addr_init : vram_addr1);
	assign vram_read_data = vram0_read_data;
	assign vram0_we = we_render;
	
	
   zbt_6111 zbt0(clk, 1'b1, vram0_we, vram0_addr,
		   vram_write_data, vram0_read_data,
		   ram0_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
		   ram0_we_b, ram0_address, ram0_data, ram0_cen_b);
	
	assign vram_write_data = ~init ? init_pixel : 0;
	
	image_init im1(.clk(clk), .hcount(hcount), .vcount(vcount), .pixel(init_pixel));
	
   vram_display vd1(reset,clk, ~init, hcount,vcount,vr_pixel,
		    vram_addr1,vram_read_data); 

		
	always@(posedge clk) begin
		we_render <= ~init ? 1 : 0;		
	end
	
	always@(posedge vsync) begin
		if (reset) init <= 0;
		else init <= 1;
	end
	
	
endmodule
