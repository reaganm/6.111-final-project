module AudioProcessingUnit
    (input clk, reset, ready, 
	 input signed [7:0]bandx,
    output wire signed [7:0]comb60,comb90,comb120,comb180,comb210,comb240,
	 output signed [7:0] hann_clip,diff_out,fw_rect_band,hw_rect_band);
	 
	//define signals
	wire signed [27:0]hann_out;
//	wire signed [7:0]diff_out;
//	wire signed [7:0]fw_rect_band;
//	wire signed [7:0]hw_rect_band;
	
	assign hann_clip = hann_out[21:14];
	
	//full wave rectify to make positive
	assign fw_rect_band = (bandx>0)?bandx:(-bandx);
	//low pass filter to get envelope
	hannfilter HannWindow1(.clk(clk),.reset(reset),.ready(ready),.x(fw_rect_band),.y(hann_out));
	//differentiate to find sudden jumps
	Differentiator diff1(.clk(clk),.reset(reset),.ready(ready),.x(hann_clip),.y(diff_out));
	//half wave rectify to only get positive jumps
	assign hw_rect_band = (diff_out>0)?diff_out:(8'd0);
	//comb signal for different tempos
	CombFilter comb1(.clk(clk),.reset(reset),.ready(ready),.x(hw_rect_band),
	.comb60(comb60),.comb90(comb90),.comb120(comb120),.comb180(comb180),.comb210(comb210),.comb240(comb240));

endmodule
