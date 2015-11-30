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
	output[15:0] pixel
  );
  	

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
	wire [11:0] x_rot;
	wire [10:0] y_rot;
	
	assign tempo = 0;
	
	
	coordinate_controller c1(.clk(clk), .tempo(tempo), .angle(angle));
	rotation r1(.clk(clk), .reset(reset), .angle(angle), .x({1'b0, hcount[10:0]}), .y({2'b0, vcount[9:0]}),
			.x_rot(x_rot), .y_rot(y_rot));
	
   zbt_6111 zbt0(clk, 1'b1, vram0_we, vram0_addr,
		   vram_write_data, vram0_read_data,
		   ram0_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
		   ram0_we_b, ram0_address, ram0_data, ram0_cen_b);
			
	wire ram1_clk_not_used;
	
   zbt_6111 zbt1(clk, 1'b1, vram1_we, vram1_addr,
		   vram_write_data, vram1_read_data,
		   ram1_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
		   ram1_we_b, ram1_address, ram1_data, ram1_cen_b);
	
	assign vram_read_data = currentram ? vram1_read_data : vram0_read_data;
	assign vram_read_data_render = currentram ? vram0_read_data : vram1_read_data;
	
	delayN #(.NDELAY(9)) vram_delay(.in(vram_read_data), .out(vram_write_data1));
	
   // generate pixel value from reading ZBT memory
   wire [15:0] 	vr_pixel;
	wire [15:0] 	init_pixel;
   wire [18:0] 	vram_addr1;
	
	image_init im1(.clk(clk), .hcount(hcount), .vcount(vcount), .pixel(init_pixel));
	
   vram_display vd1(reset,clk, ~init, hcount,vcount,vr_pixel,
		    vram_addr1,vram_read_data);   

	assign vram_write_data = ~init ? init_pixel : vram_write_data1;
	
   // code to write pattern to ZBT memory
   
	wire [18:0] vram_addr2 = (x_rot > -1 && y_rot > -1 && x_rot < 800 && y_rot < 600) ? {x_rot[10:0] + y_rot[9:0]*800} : 19'b1;
   	
   wire [18:0] write_addr = vram_addr2;	

	assign 	vram0_addr = currentram ? write_addr : vram_addr1;
	//assign 	vram0_we = currentram ? we_render : (~init ? 1: 0);
	assign 	vram0_we = currentram ? we_render : 0;

   assign 	vram1_addr = ~currentram ? write_addr : vram_addr1;
	//assign 	vram1_we = ~currentram ? we_render : (~init ? 1: 0);
	assign 	vram1_we = ~currentram ? we_render : 0;
	
	always@(posedge clk) begin
		if(reset) init <= 0;
		else begin
			we_render <= ~init ? 0: 1;
			init <= 1;
			//if (hcount == 1055 && vcount == 627) currentram <= ~currentram;
		end
	end
	
	always@(posedge vsync) begin
		currentram <= ~currentram;
	end
	
endmodule
