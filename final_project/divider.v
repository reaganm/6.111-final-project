`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:51:31 11/28/2015 
// Design Name: 
// Module Name:    divider 
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
module divider #(parameter WIDTH = 13)
	(input clk, sign, start,
	 input [WIDTH-1:0] dividend,
	 input [WIDTH-1:0] divider,
	 output reg [WIDTH-1:0] quotient,
	 output [WIDTH-1:0] remainder,
	 output ready);
	 
	reg [WIDTH-1:0] quotient_temp;
	reg [WIDTH*2-1:0] dividend_copy, divider_copy, diff;
	reg negative_output;

	assign remainder = (!negative_output) ? dividend_copy[WIDTH-1:0] : ~dividend_copy[WIDTH-1:0] + 1'b1;

	reg [6:0] bit;
	reg del_ready = 1;
	assign ready = (!bit) & ~del_ready;

	wire [WIDTH-2:0] zeros = 0;
	initial bit = 0;
	initial negative_output = 0;
	
	always @( posedge clk ) begin
		del_ready <= !bit;
		
		if( start ) begin
			bit = WIDTH;
			quotient = 0;
			quotient_temp = 0;
			dividend_copy = (!sign || !dividend[WIDTH-1]) ? {1'b0,zeros,dividend} : {1'b0,zeros,~dividend + 1'b1};
			divider_copy = (!sign || !divider[WIDTH-1]) ? {1'b0,divider,zeros} : {1'b0,~divider + 1'b1,zeros};
			negative_output = sign &&  ((divider[WIDTH-1] && !dividend[WIDTH-1]) ||(!divider[WIDTH-1] && dividend[WIDTH-1]));
		end
			
		else if ( bit > 0 ) begin
			diff = dividend_copy - divider_copy;
			quotient_temp = quotient_temp << 1;
				
			if( !diff[WIDTH*2-1] ) begin
				dividend_copy = diff;
				quotient_temp[0] = 1'd1;
			end
			
			quotient = (!negative_output) ?	quotient_temp : ~quotient_temp + 1'b1;
			divider_copy = divider_copy >> 1;
			bit = bit - 1'b1;
		end
	end
 endmodule
