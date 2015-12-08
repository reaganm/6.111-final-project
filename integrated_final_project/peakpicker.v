module Peakfinder(
	input clk, ready, reset,
	input signed [7:0]comb00,comb01,comb02,comb03,comb04,comb05,
	input signed [7:0]comb10,comb11,comb12,comb13,comb14,comb15,
	input signed [7:0]comb20,comb21,comb22,comb23,comb24,comb25,
	input signed [7:0]comb30,comb31,comb32,comb33,comb34,comb35,
	input signed [7:0]comb40,comb41,comb42,comb43,comb44,comb45,
	output reg signed [15:0]energy60,energy90,energy120,energy180,energy210,energy240,
	output reg [7:0]tempo,
	output reg beat);
	
	parameter THRESHOLD_ENERGY = 580;
	reg [2:0]tap = 2'd0;
	reg signed [15:0]energy;
	
//	reg signed [15:0]energy60 = 16'd0;
//	reg signed [15:0]energy90 = 16'd0;
//	reg signed [15:0]energy120 = 16'd0;
//	reg signed [15:0]energy180 = 16'd0;
//	reg signed [15:0]energy210 = 16'd0;
//	reg signed [15:0]energy240 = 16'd0;
	
	initial tempo = 8'd120;
	
	always @(posedge clk)
		begin
		if (ready)
			begin
			//calculate energy this byte for each tempo
			energy60 <= (comb00*comb00) + (comb10*comb10) 
			+ (comb20*comb20) + (comb30*comb30) 
			+ (comb40*comb40);
			
			energy90 <= (comb01*comb01) + (comb11*comb11) 
			+ (comb21*comb21) + (comb31*comb31) 
			+ (comb41*comb41);
				
			energy120 <= (comb02*comb02) + (comb12*comb12) 
			+ (comb22*comb22) + (comb32*comb32) 
			+ (comb42*comb42);
			
			energy180 <= (comb03*comb03) + (comb13*comb13) 
			+ (comb23*comb23) + (comb33*comb33) 
			+ (comb43*comb43);
			
			energy210 <= (comb04*comb04) + (comb14*comb14) 
			+ (comb24*comb24) + (comb34*comb34) 
			+ (comb44*comb44);
			
			energy240 <= (comb05*comb05) + (comb15*comb15) 
			+ (comb25*comb25) + (comb35*comb35) 
			+ (comb45*comb45);
			
			tap <= 1;
			end
		if (tap == 1)
			begin
			energy <= energy60+energy90+energy120+energy180+energy210+energy240;
			tap <= 2;
			end
		if (tap == 2)
			begin
			if (energy > THRESHOLD_ENERGY)
				begin
				beat <= 1;
				tap <= 3;
				end
			end
		if (tap==3)
			begin
			tap <= 4;
			end
		if (tap==4)
			begin
			tap <= 0;
			beat <= 0;
			end
		end
endmodule

module Peakpicker(
	input clk, ready, reset,
	input signed [7:0]comb00,comb01,comb02,comb03,comb04,comb05,
	input signed [7:0]comb10,comb11,comb12,comb13,comb14,comb15,
	input signed [7:0]comb20,comb21,comb22,comb23,comb24,comb25,
	input signed [7:0]comb30,comb31,comb32,comb33,comb34,comb35,
	input signed [7:0]comb40,comb41,comb42,comb43,comb44,comb45,
	output reg signed [21:0]byte_energy60,byte_energy90,byte_energy120,byte_energy180,byte_energy210,byte_energy240,
	output reg [7:0]tempo,
	output reg beat);
	
	
	reg signed [21:0]energy60 = 0;
	reg signed [21:0]energy90 = 0;
	reg signed [21:0]energy120 = 0;
	reg signed [21:0]energy180 = 0;
	reg signed [21:0]energy210 = 0;
	reg signed [21:0]energy240 = 0;
	
//	reg signed [21:0]byte_energy60 = 0;
//	reg signed [21:0]byte_energy90 = 0;
//	reg signed [21:0]byte_energy120 = 0;
//	reg signed [21:0]byte_energy180 = 0;
//	reg signed [21:0]byte_energy210 = 0;
//	reg signed [21:0]byte_energy240 = 0;	
	initial tempo = 8'd0;
	reg [3:0]tap = 0;

	reg signed [21:0]max_energy = 0;
	reg [12:0]counter_max;
	reg [12:0]counter;


		always @(posedge clk)
			begin
			if (reset)
				begin
				energy60 <= 0;
				energy90 <= 0;
				energy120 <= 0;
				energy180 <= 0;
				energy210 <= 0;
				energy240 <= 0;
				tempo <= 0;
				max_energy <= 0;
				counter_max <= 0;
				counter <= 0;
				end
			else if (ready)
				begin
				//calculate energy this byte for each tempo
				byte_energy60 <= (comb00*comb00) + (comb10*comb10) 
				+ (comb20*comb20) + (comb30*comb30) 
				+ (comb40*comb40);
				
				byte_energy90 <= (comb01*comb01) + (comb11*comb11) 
				+ (comb21*comb21) + (comb31*comb31) 
				+ (comb41*comb41);
					
				byte_energy120 <= (comb02*comb02) + (comb12*comb12) 
				+ (comb22*comb22) + (comb32*comb32) 
				+ (comb42*comb42);
				
				byte_energy180 <= (comb03*comb03) + (comb13*comb13) 
				+ (comb23*comb23) + (comb33*comb33) 
				+ (comb43*comb43);
				
				byte_energy210 <= (comb04*comb04) + (comb14*comb14) 
				+ (comb24*comb24) + (comb34*comb34) 
				+ (comb44*comb44);
				
				byte_energy240 <= (comb05*comb05) + (comb15*comb15) 
				+ (comb25*comb25) + (comb35*comb35) 
				+ (comb45*comb45);
				
				tap <= 1;
				end
				
			if (tap==1)
				begin
				//add energy for byte to sum reg
				energy60 <= energy60 + byte_energy60;
				energy90 <= energy90 + byte_energy90;
				energy120 <= energy120 + byte_energy120;
				energy180 <= energy180 + byte_energy180;
				energy210 <= energy210 + byte_energy210;
				energy240 <= energy240 + byte_energy240;
				tap <= 2;
				end
			
				//test if any of these energies is a max, start with higher BPM
				//to prevent picking harmonics
			if (tap==2)
				begin
				if (energy240>max_energy) 
					begin
					tempo <= 240;
					max_energy <= energy240;
					end
				tap <= 3;
				end
				
			if (tap==3)
				begin
				if (energy210>max_energy)
					begin
					tempo <=210;
					max_energy <= energy210;
					end
				tap <= 4;
				end
				
			if (tap==4)
				begin
				if (energy180>max_energy)
					begin
					tempo <=180;
					max_energy <= energy180;
					end
				tap <= 5;
				end
			
			if (tap==5)
				begin
				if (energy120>max_energy)
					begin
					tempo <=120;
					max_energy <= energy120;
					end
				tap <= 6;
				end
			
			if (tap==6)
				begin
				if (energy90>max_energy)
					begin
					tempo <=90;
					max_energy <= energy90;
					end
				tap <= 7;
				end
			
			if (tap==7)
				begin
				if (energy60>max_energy)
					begin
					tempo <=60;
					max_energy <= energy60;
					end
				tap <= 8;
				end
			
			if (tap==8)
				begin
				//set counter max based on current tempo
				case(tempo)
					60: counter_max <= 6000;
					90: counter_max <= 4000;
					120: counter_max <= 3000;
					180: counter_max <= 2000;
					210: counter_max <= 1714;
					240: counter_max <= 1500;
				endcase
				tap <= 9;
				end
				
			//set beat high at given tempo
			if (counter == 0)
				begin
				beat <= 1;
				counter <= counter_max;
				end
			else
				begin
				counter <= counter - 1;
				beat <= 0;
				end
				
			end
	
endmodule


	
//	reg [21:0]high_energy = 0;

	

	
	//for now implement non-rolling
	//mybram #(.LOGSIZE(MEM_LOGSIZE),.WIDTH(MEM_WIDTH))
	//	mybram1(.addr(addr),.clk(clock),.din(memin),.dout(memout),.we(we));
		
				
				//pick tempo with highest energy
//				if (energy60>energy90 && energy60>energy120 && energy60>energy180 && energy60>energy210 && energy60>energy240)
//					tempo <= 60;
//				if (energy90>energy60 && energy90>energy120 && energy90>energy180 && energy90>energy210 && energy90>energy240)
//					tempo <= 90;
//				if (energy120>energy60 && energy120>energy90 && energy120>energy180 && energy120>energy210 && energy120>energy240)
//					tempo <= 120;
//				if (energy180>energy60 && energy180>energy90 && energy180>energy120 && energy180>energy210 && energy180>energy240)
//					tempo <= 180;
//				if (energy210>energy60 && energy210>energy90 && energy210>energy120 && energy210>energy180 && energy210>energy240)
//					tempo <= 210;
//				if (energy240>energy60 && energy240>energy90 && energy240>energy120 && energy240>energy180 && energy240>energy210)
//					tempo <= 240;
//				
//				case(tempo)
//					60: high_energy <= byte_energy60;
//					90: high_energy <= byte_energy90;
//					120: high_energy <= byte_energy120;
//					180: high_energy <= byte_energy180;
//					210: high_energy <= byte_energy210;
//					240: high_energy <= byte_energy240;
//				endcase
//				
//				if (high_energy > max_energy) beat <= 1;
//				else beat <= 0;

