module mybram #(parameter LOGSIZE=14, WIDTH=1)
              (input wire [LOGSIZE-1:0] addr,
               input wire clk,
               input wire [WIDTH-1:0] din,
               output reg [WIDTH-1:0] dout,
               input wire we);
   // let the tools infer the right number of BRAMs
   (* ram_style = "block" *)
   reg [WIDTH-1:0] mem[LOGSIZE-1:0];
   always @(posedge clk) begin
     if (we) mem[addr] <= din;
     dout <= mem[addr];
   end
endmodule

module CombFilter
	(input clk, reset, ready,
	input signed [7:0]x,
	output reg signed [7:0]comb60,comb90,comb120,comb180,comb210,comb240);
	
	parameter SHIFTSIZE = 12000;
	reg [13:0]addr = 0;
	reg signed [7:0]memin;
	wire signed [7:0]memout;
	reg we = 0;
	reg [13:0]offset = 0;
	reg [4:0]tap = 0;
	
	reg signed [7:0]buffer_0 = 0;
	reg signed [7:0]buffer_1499 = 0;
	reg signed [7:0]buffer_1713 = 0;
	reg signed [7:0]buffer_1999 = 0;
	reg signed [7:0]buffer_2999 = 0;
	reg signed [7:0]buffer_3427 = 0;
	reg signed [7:0]buffer_3999 = 0;
	reg signed [7:0]buffer_5999 = 0;
	reg signed [7:0]buffer_7999 = 0;
	reg signed [7:0]buffer_11999 = 0;
	
	mybram #(.LOGSIZE(14),.WIDTH(8))
		mybram1(.addr(addr),.clk(clk),.din(memin),.dout(memout),.we(we));
	
//	assign memin = x;
//	
	always @(posedge clk)
		begin
		if (ready && tap==0)
			begin
			we <= 1;
			memin <= x;
			addr <= offset;
			buffer_0 <= x;
			tap <= 1;
			end
		if (tap==1)
			begin
			we <= 0;
			addr <= (offset>1500)?(offset-1499):(SHIFTSIZE+offset-1499);
			tap <= 2;
			end
		if (tap==2)
			begin
			buffer_1499 <= memout;
			addr <= (offset>1714)?(offset-1713):(SHIFTSIZE+offset-1713);
			tap <= 3;
			end
		if (tap==3)
			begin
			buffer_1713 <= memout;
			addr <= (offset>2000)?(offset-1999):(SHIFTSIZE+offset-1999);
			tap <= 4;
			end
		if (tap==4)
			begin
			buffer_1999 <= memout;
			addr <= (offset>3000)?(offset-2999):(SHIFTSIZE+offset-2999);
			tap <= 5;
			end
		if (tap==5)
			begin
			buffer_2999 <= memout;
			addr <= (offset>3428)?(offset-3427):(SHIFTSIZE+offset-3427);
			tap <= 6;
			end
		if (tap==6)
			begin
			buffer_3427 <= memout;
			addr <= (offset>4000)?(offset-3999):(SHIFTSIZE+offset-3999);
			tap <= 7;
			end
		if (tap==7)
			begin
			buffer_3999 <= memout;
			addr <= (offset>6000)?(offset-5999):(SHIFTSIZE+offset-5999);
			tap <= 8;
			end
		if (tap==8)
			begin
			buffer_5999 <= memout;
			addr <= (offset>8000)?(offset-7999):(SHIFTSIZE+offset-7999);
			tap <= 9;
			end
		if (tap==9)
			begin
			buffer_7999 <= memout;
			addr <= (offset>12000)?(offset-11999):(SHIFTSIZE+offset-11999);
			tap <= 10;
			end
		if (tap==10)
			begin
			tap <= 0;
			comb60 <= buffer_0 + buffer_5999 + memout;
			comb90 <= buffer_0 + buffer_3999 + buffer_7999;
			comb120 <= buffer_0 + buffer_2999 + buffer_5999;
			comb180 <= buffer_0 + buffer_1999 + buffer_3999;
			comb210 <= buffer_0 + buffer_1713 + buffer_3427;
			comb240 <= buffer_0 + buffer_1499 + buffer_2999;
			offset <= offset<SHIFTSIZE-2?offset+1:0;
			end
		end
		
	
		
endmodule