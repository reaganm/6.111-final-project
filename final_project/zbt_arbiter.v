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
  
   parameter INITIALIZING = 2'b0;
	parameter READING = 2'b01;
	parameter HOLDING = 2'b10;
	
	
   wire [35:0] vram_write_data;
   wire [35:0] vram0_read_data, vram1_read_data, vram_read_data;
   wire [20:0] vram_addr, vram0_addr, vram1_addr;
   wire        vram_we, vram0_we, vram1_we;

   wire ram0_clk_not_used;
	
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
	
	delayN #(.NDELAY(11)) vram_delay(.in(vram_read_data), .out(vram_write_data));
	
   // generate pixel value from reading ZBT memory
   wire [15:0] 	vr_pixel;
   wire [20:0] 	vram_addr1;

   vram_display vd1(reset,clk,hcount,vcount,vr_pixel,
		    vram_addr1,vram_read_data);   

   // code to write pattern to ZBT memory
   
	wire [20:0] vram_addr2 = (x_rot > -1 && y_rot > -1 && x_rot < 800 && y_rot < 600) ? {y_rot[9:0], x_rot[10:0]} : 21'b1;
   	
   wire [20:0] write_addr = vram_addr2;	

	assign 	vram0_addr = currentram ? write_addr : vram_addr1;
   assign 	vram0_we = currentram ? we_render : 0;

   assign 	vram1_addr = ~currentram ? write_addr : vram_addr1;
   assign 	vram1_we = ~currentram ? we_render : 0;
	
	always@(posedge vclock) begin
		we_render <= 1;
		if (x == 1055 && y == 627) currentram <= ~current_ram;
	end
	
endmodule
