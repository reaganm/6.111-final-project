
`default_nettype none

///////////////////////////////////////////////////////////////////////////////
//
// Switch Debounce Module
//
///////////////////////////////////////////////////////////////////////////////

module debounce (
  input wire reset, clock, noisy,
  output reg clean
);
  reg [18:0] count;
  reg new;

  always @(posedge clock)
    if (reset) begin
      count <= 0;
      new <= noisy;
      clean <= noisy;
    end
    else if (noisy != new) begin
      // noisy input changed, restart the .01 sec clock
      new <= noisy;
      count <= 0;
    end
    else if (count == 270000)
      // noisy input stable for .01 secs, pass it along!
      clean <= new;
    else
      // waiting for .01 sec to pass
      count <= count+1;

endmodule

///////////////////////////////////////////////////////////////////////////////
//
// bi-directional monaural interface to AC97
//
///////////////////////////////////////////////////////////////////////////////

module lab5audio (
  input wire clock_27mhz,
  input wire reset,
  input wire [4:0] volume,
  output wire [7:0] audio_in_data,
  input wire [7:0] audio_out_data,
  output wire ready,
  output reg audio_reset_b,   // ac97 interface signals
  output wire ac97_sdata_out,
  input wire ac97_sdata_in,
  output wire ac97_synch,
  input wire ac97_bit_clock
);

  wire [7:0] command_address;
  wire [15:0] command_data;
  wire command_valid;
  wire [19:0] left_in_data, right_in_data;
  wire [19:0] left_out_data, right_out_data;

  // wait a little before enabling the AC97 codec
  reg [9:0] reset_count;
  always @(posedge clock_27mhz) begin
    if (reset) begin
      audio_reset_b = 1'b0;
      reset_count = 0;
    end else if (reset_count == 1023)
      audio_reset_b = 1'b1;
    else
      reset_count = reset_count+1;
  end

  wire ac97_ready;
  ac97 ac97(.ready(ac97_ready),
            .command_address(command_address),
            .command_data(command_data),
            .command_valid(command_valid),
            .left_data(left_out_data), .left_valid(1'b1),
            .right_data(right_out_data), .right_valid(1'b1),
            .left_in_data(left_in_data), .right_in_data(right_in_data),
            .ac97_sdata_out(ac97_sdata_out),
            .ac97_sdata_in(ac97_sdata_in),
            .ac97_synch(ac97_synch),
            .ac97_bit_clock(ac97_bit_clock));

  // ready: one cycle pulse synchronous with clock_27mhz
  reg [2:0] ready_sync;
  always @ (posedge clock_27mhz) ready_sync <= {ready_sync[1:0], ac97_ready};
  assign ready = ready_sync[1] & ~ready_sync[2];

  reg [7:0] out_data;
  always @ (posedge clock_27mhz)
    if (ready) out_data <= audio_out_data;
  assign audio_in_data = left_in_data[19:12];
  assign left_out_data = {out_data, 12'b000000000000};
  assign right_out_data = left_out_data;

  // generate repeating sequence of read/writes to AC97 registers
  ac97commands cmds(.clock(clock_27mhz), .ready(ready),
                    .command_address(command_address),
                    .command_data(command_data),
                    .command_valid(command_valid),
                    .volume(volume),
                    .source(3'b000));     // mic
endmodule

// assemble/disassemble AC97 serial frames
module ac97 (
  output reg ready,
  input wire [7:0] command_address,
  input wire [15:0] command_data,
  input wire command_valid,
  input wire [19:0] left_data,
  input wire left_valid,
  input wire [19:0] right_data,
  input wire right_valid,
  output reg [19:0] left_in_data, right_in_data,
  output reg ac97_sdata_out,
  input wire ac97_sdata_in,
  output reg ac97_synch,
  input wire ac97_bit_clock
);
  reg [7:0] bit_count;

  reg [19:0] l_cmd_addr;
  reg [19:0] l_cmd_data;
  reg [19:0] l_left_data, l_right_data;
  reg l_cmd_v, l_left_v, l_right_v;

  initial begin
    ready <= 1'b0;
    // synthesis attribute init of ready is "0";
    ac97_sdata_out <= 1'b0;
    // synthesis attribute init of ac97_sdata_out is "0";
    ac97_synch <= 1'b0;
    // synthesis attribute init of ac97_synch is "0";

    bit_count <= 8'h00;
    // synthesis attribute init of bit_count is "0000";
    l_cmd_v <= 1'b0;
    // synthesis attribute init of l_cmd_v is "0";
    l_left_v <= 1'b0;
    // synthesis attribute init of l_left_v is "0";
    l_right_v <= 1'b0;
    // synthesis attribute init of l_right_v is "0";

    left_in_data <= 20'h00000;
    // synthesis attribute init of left_in_data is "00000";
    right_in_data <= 20'h00000;
    // synthesis attribute init of right_in_data is "00000";
  end

  always @(posedge ac97_bit_clock) begin
    // Generate the sync signal
    if (bit_count == 255)
      ac97_synch <= 1'b1;
    if (bit_count == 15)
      ac97_synch <= 1'b0;

    // Generate the ready signal
    if (bit_count == 128)
      ready <= 1'b1;
    if (bit_count == 2)
      ready <= 1'b0;

    // Latch user data at the end of each frame. This ensures that the
    // first frame after reset will be empty.
    if (bit_count == 255) begin
      l_cmd_addr <= {command_address, 12'h000};
      l_cmd_data <= {command_data, 4'h0};
      l_cmd_v <= command_valid;
      l_left_data <= left_data;
      l_left_v <= left_valid;
      l_right_data <= right_data;
      l_right_v <= right_valid;
    end

    if ((bit_count >= 0) && (bit_count <= 15))
      // Slot 0: Tags
      case (bit_count[3:0])
        4'h0: ac97_sdata_out <= 1'b1;      // Frame valid
        4'h1: ac97_sdata_out <= l_cmd_v;   // Command address valid
        4'h2: ac97_sdata_out <= l_cmd_v;   // Command data valid
        4'h3: ac97_sdata_out <= l_left_v;  // Left data valid
        4'h4: ac97_sdata_out <= l_right_v; // Right data valid
        default: ac97_sdata_out <= 1'b0;
      endcase
    else if ((bit_count >= 16) && (bit_count <= 35))
      // Slot 1: Command address (8-bits, left justified)
      ac97_sdata_out <= l_cmd_v ? l_cmd_addr[35-bit_count] : 1'b0;
    else if ((bit_count >= 36) && (bit_count <= 55))
      // Slot 2: Command data (16-bits, left justified)
      ac97_sdata_out <= l_cmd_v ? l_cmd_data[55-bit_count] : 1'b0;
    else if ((bit_count >= 56) && (bit_count <= 75)) begin
      // Slot 3: Left channel
      ac97_sdata_out <= l_left_v ? l_left_data[19] : 1'b0;
      l_left_data <= { l_left_data[18:0], l_left_data[19] };
    end
    else if ((bit_count >= 76) && (bit_count <= 95))
      // Slot 4: Right channel
      ac97_sdata_out <= l_right_v ? l_right_data[95-bit_count] : 1'b0;
    else
      ac97_sdata_out <= 1'b0;

    bit_count <= bit_count+1;
  end // always @ (posedge ac97_bit_clock)

  always @(negedge ac97_bit_clock) begin
    if ((bit_count >= 57) && (bit_count <= 76))
      // Slot 3: Left channel
      left_in_data <= { left_in_data[18:0], ac97_sdata_in };
    else if ((bit_count >= 77) && (bit_count <= 96))
      // Slot 4: Right channel
      right_in_data <= { right_in_data[18:0], ac97_sdata_in };
  end
endmodule

// issue initialization commands to AC97
module ac97commands (
  input wire clock,
  input wire ready,
  output wire [7:0] command_address,
  output wire [15:0] command_data,
  output reg command_valid,
  input wire [4:0] volume,
  input wire [2:0] source
);
  reg [23:0] command;

  reg [3:0] state;
  initial begin
    command <= 4'h0;
    // synthesis attribute init of command is "0";
    command_valid <= 1'b0;
    // synthesis attribute init of command_valid is "0";
    state <= 16'h0000;
    // synthesis attribute init of state is "0000";
  end

  assign command_address = command[23:16];
  assign command_data = command[15:0];

  wire [4:0] vol;
  assign vol = 31-volume;  // convert to attenuation

  always @(posedge clock) begin
    if (ready) state <= state+1;

    case (state)
      4'h0: // Read ID
        begin
          command <= 24'h80_0000;
          command_valid <= 1'b1;
        end
      4'h1: // Read ID
        command <= 24'h80_0000;
      4'h3: // headphone volume
        command <= { 8'h04, 3'b000, vol, 3'b000, vol };
      4'h5: // PCM volume
        command <= 24'h18_0808;
      4'h6: // Record source select
        command <= { 8'h1A, 5'b00000, source, 5'b00000, source};
      4'h7: // Record gain = max
        command <= 24'h1C_0F0F;
      4'h9: // set +20db mic gain
        command <= 24'h0E_8048;
      4'hA: // Set beep volume
        command <= 24'h0A_0000;
      4'hB: // PCM out bypass mix1
        command <= 24'h20_8000;
      default:
        command <= 24'h80_0000;
    endcase // case(state)
  end // always @ (posedge clock)
endmodule // ac97commands



/////////////////////////////////////////////////////////////////////////////////
////
//// 6.111 FPGA Labkit -- Template Toplevel Module
////
//// For Labkit Revision 004
//// Created: October 31, 2004, from revision 003 file
//// Author: Nathan Ickes, 6.111 staff
////
/////////////////////////////////////////////////////////////////////////////////

module final_project   (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,
	       
	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

	       ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,
	       
	       user1, user2, user3, user4,
	       
	       daughtercard,

	       systemace_data, systemace_address, systemace_ce_b,
	       systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
	       
	       analyzer1_data, analyzer1_clock,
 	       analyzer2_data, analyzer2_clock,
 	       analyzer3_data, analyzer3_clock,
 	       analyzer4_data, analyzer4_clock);

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	  tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;
   
   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;
   
   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   

   // Audio Input and Output
   assign beep= 1'b0;
   //lab5 assign audio_reset_b = 1'b0;
   //lab5 assign ac97_synch = 1'b0;
   //lab5 assign ac97_sdata_out = 1'b0;
   // ac97_sdata_in is an input

   // VGA Output
//   assign vga_out_red = 10'h0;
//   assign vga_out_green = 10'h0;
//   assign vga_out_blue = 10'h0;
//   assign vga_out_sync_b = 1'b1;
//   assign vga_out_blank_b = 1'b1;
//   assign vga_out_pixel_clock = 1'b0;
//   assign vga_out_hsync = 1'b0;
//   assign vga_out_vsync = 1'b0;

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b0;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b0;
   assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = 1'b0;
   assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs
	/* enable RAM pins */

   assign ram0_ce_b = 1'b0;
   assign ram0_oe_b = 1'b0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_bwe_b = 4'h0;
/*
   assign ram1_data = 36'hZ; 
   assign ram1_address = 19'h0;*/
   assign ram1_adv_ld = 1'b0;
   //assign ram1_clk = 1'b0;
   
   //These values has to be set to 0 like ram0 if ram1 is used.
   //assign ram1_cen_b = 1'b1; 
   assign ram1_ce_b = 1'b0;
   assign ram1_oe_b = 1'b0;
   //assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'h0;
	
//   assign ram0_data = 36'hZ;
//   assign ram0_address = 19'h0;
//   assign ram0_adv_ld = 1'b0;
//   assign ram0_clk = 1'b0;
//   assign ram0_cen_b = 1'b1;
//   assign ram0_ce_b = 1'b1;
//   assign ram0_oe_b = 1'b1;
//   assign ram0_we_b = 1'b1;
//   assign ram0_bwe_b = 4'hF;
//   assign ram1_data = 36'hZ; 
//   assign ram1_address = 19'h0;
//   assign ram1_adv_ld = 1'b0;
//   assign ram1_clk = 1'b0;
//   assign ram1_cen_b = 1'b1;
//   assign ram1_ce_b = 1'b1;
//   assign ram1_oe_b = 1'b1;
//   assign ram1_we_b = 1'b1;
//   assign ram1_bwe_b = 4'hF;
//   assign clock_feedback_out = 1'b0;
   // clock_feedback_in is an input
   
   // Flash ROM
   assign flash_data = 16'hZ;
   assign flash_address = 24'h0;
   assign flash_ce_b = 1'b1;
   assign flash_oe_b = 1'b1;
   assign flash_we_b = 1'b1;
   assign flash_reset_b = 1'b0;
   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
   assign disp_blank = 1'b1;
   assign disp_clock = 1'b0;
   assign disp_rs = 1'b0;
   assign disp_ce_b = 1'b1;
   assign disp_reset_b = 1'b0;
   assign disp_data_out = 1'b0;
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
   assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   //assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
   //lab5 assign analyzer1_data = 16'h0;
   //lab5 assign analyzer1_clock = 1'b1;
   //assign analyzer2_data = 16'h0;
   //assign analyzer2_clock = 1'b1;
   //lab5 assign analyzer3_data = 16'h0;
   //lab5 assign analyzer3_clock = 1'b1;
//   assign analyzer4_data = 16'h0;
	  assign analyzer4_clock = 1'b1;
			    
//   wire [7:0] from_ac97_data, to_ac97_data;
//   wire ready;

   ////////////////////////////////////////////////////////////////////////////
   //
   // Reset Generation
   //
   // A shift register primitive is used to generate an active-high reset
   // signal that remains high for 16 clock cycles after configuration finishes
   // and the FPGA's internal clocks begin toggling.
   //
   ////////////////////////////////////////////////////////////////////////////
   wire reset;
   SRL16 #(.INIT(16'hFFFF)) reset_sr(.D(1'b0), .CLK(clock_27mhz), .Q(reset),
                                     .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
		    
   wire hard_reset;
	debounce db_reset(.reset(reset),.clock(clock_27mhz),.noisy(button_enter),.clean(hard_reset));
	
	wire [7:0] from_ac97_data, to_ac97_data;
   wire ready;
	wire [7:0]volume = 0;
	
   // AC97 driver
   lab5audio a(clock_27mhz, reset, volume, from_ac97_data, to_ac97_data, ready,
	       audio_reset_b, ac97_sdata_out, ac97_sdata_in,
	       ac97_synch, ac97_bit_clock);  
	
	// ZBT clock
	wire clk;
	
	wire clock_40mhz_unbuf,clock_40mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_40mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 2
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 3
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_40mhz),.I(clock_40mhz_unbuf));

   wire locked;
	//assign clock_feedback_out = 0; // gph 2011-Nov-10
   
   ramclock1 rc(.ref_clock(clock_40mhz), .fpga_clock(clk),
					.ram0_clock(ram0_clk), 
					.ram1_clock(ram1_clk),   //uncomment if ram1 is used
					.clock_feedback_in(clock_feedback_in),
					.clock_feedback_out(clock_feedback_out), .locked(locked));
	// Enter button reset
	wire reset1,user_reset1;
// power-on reset generation
   wire power_on_reset1;    // remain high for first 16 clocks
   SRL16 reset_sr1 (.D(1'b0), .CLK(clk), .Q(power_on_reset1),
		   .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   defparam reset_sr.INIT = 16'hFFFF;

   // ENTER button is user reset
   
   debounce db1(power_on_reset1, clk, ~button_enter, user_reset1);
   assign reset1 = user_reset1 | power_on_reset1;
	
	////my code/////
	
	//declare connections
	wire signed [17:0]lowpassed;
	wire signed [7:0]filtband0;
	wire signed [7:0]filtband1;
	wire signed [7:0]filtband2;
	wire signed [7:0]filtband3;
	wire signed [7:0]filtband4;
	wire signed [7:0]filtband5;
	wire signed [7:0]comb00;
	wire signed [7:0]comb01;
	wire signed [7:0]comb02;
	wire signed [7:0]comb03;
	wire signed [7:0]comb04;
	wire signed [7:0]comb05;
	wire signed [7:0]comb10;
	wire signed [7:0]comb11;
	wire signed [7:0]comb12;
	wire signed [7:0]comb13;
	wire signed [7:0]comb14;
	wire signed [7:0]comb15;
	wire signed [7:0]comb20;
	wire signed [7:0]comb21;
	wire signed [7:0]comb22;
	wire signed [7:0]comb23;
	wire signed [7:0]comb24;
	wire signed [7:0]comb25;
	wire signed [7:0]comb30;
	wire signed [7:0]comb31;
	wire signed [7:0]comb32;
	wire signed [7:0]comb33;
	wire signed [7:0]comb34;
	wire signed [7:0]comb35;
	wire signed [7:0]comb40;
	wire signed [7:0]comb41;
	wire signed [7:0]comb42;
	wire signed [7:0]comb43;
	wire signed [7:0]comb44;
	wire signed [7:0]comb45;
	wire [7:0]tempo;
	wire beat;
	
	wire sixk_ready;
	wire signed [7:0]fw_rect_band0;
	wire signed [7:0]hann_out0;
	wire signed [7:0]diff_out0;
	wire signed [7:0]hw_rect_band0;
	wire signed [7:0]fw_rect_band1;
	wire signed [7:0]hann_out1;
	wire signed [7:0]diff_out1;
	wire signed [7:0]hw_rect_band1;
	wire signed [7:0]fw_rect_band2;
	wire signed [7:0]hann_out2;
	wire signed [7:0]diff_out2;
	wire signed [7:0]hw_rect_band2;
	wire signed [7:0]fw_rect_band3;
	wire signed [7:0]hann_out3;
	wire signed [7:0]diff_out3;
	wire signed [7:0]hw_rect_band3;
	wire signed [7:0]fw_rect_band;
	wire signed [7:0]hann_out;
	wire signed [7:0]diff_out;
	wire signed [7:0]hw_rect_band;
	wire [15:0]eng60;
	wire [15:0]eng90;
	wire [15:0]eng120;
	wire [15:0]eng180;
	wire [15:0]eng210;
	wire [15:0]eng240;
	
	// output useful things to the logic analyzer connectors
   assign analyzer3_clock = clock_27mhz;
   assign analyzer3_data = {lowpassed,filtband4};
	assign analyzer1_clock = ready;
	assign analyzer1_data = {hann_out,diff_out};
	//assign analyzer4_clock = sixk_ready;
	assign analyzer4_data = {comb40,comb41};
	assign analyzer2_clock = sixk_ready;
   assign analyzer2_data = {eng60};
	
	//lowpass audio by half of sampling frequency as it comes in
	lowpass3k LP(.clock(clock_27mhz),.reset(hard_reset),.ready(ready),.x(from_ac97_data),.y(lowpassed));

	//sample audio input and split into frequency bands
	Filterbank fbank1(.clk(clock_27mhz),.reset(hard_reset),.ready(ready),.sixk_ready(sixk_ready),.x(lowpassed[17:10]),
   .band0(filtband0),.band1(filtband1),.band2(filtband2),.band3(filtband3),.band4(filtband4));
	
	//process audio in freq bands
	AudioProcessingUnit APU0(.clk(clock_27mhz),.reset(hard_reset),.ready(sixk_ready),.bandx(filtband0),
	.comb60(comb00),.comb90(comb01),.comb120(comb02),.comb180(comb03),.comb210(comb04),.comb240(comb05),
	.hann_clip(hann_out0),.diff_out(diff_out0),.fw_rect_band(fw_rect_band0),.hw_rect_band(hw_rect_band0));
	AudioProcessingUnit APU1(.clk(clock_27mhz),.reset(hard_reset),.ready(sixk_ready),.bandx(filtband1),
	.comb60(comb10),.comb90(comb11),.comb120(comb12),.comb180(comb13),.comb210(comb14),.comb240(comb15),
	.hann_clip(hann_out1),.diff_out(diff_out1),.fw_rect_band(fw_rect_band1),.hw_rect_band(hw_rect_band1));
	AudioProcessingUnit APU2(.clk(clock_27mhz),.reset(hard_reset),.ready(sixk_ready),.bandx(filtband2),
	.comb60(comb20),.comb90(comb21),.comb120(comb22),.comb180(comb23),.comb210(comb24),.comb240(comb25),
	.hann_clip(hann_out2),.diff_out(diff_out2),.fw_rect_band(fw_rect_band2),.hw_rect_band(hw_rect_band2));
	AudioProcessingUnit APU3(.clk(clock_27mhz),.reset(hard_reset),.ready(sixk_ready),.bandx(filtband3),
	.comb60(comb30),.comb90(comb31),.comb120(comb32),.comb180(comb33),.comb210(comb34),.comb240(comb35),
	.hann_clip(hann_out3),.diff_out(diff_out3),.fw_rect_band(fw_rect_band3),.hw_rect_band(hw_rect_band3));
	AudioProcessingUnit APU4(.clk(clock_27mhz),.reset(hard_reset),.ready(sixk_ready),.bandx(filtband4),
	.comb60(comb40),.comb90(comb41),.comb120(comb42),.comb180(comb43),.comb210(comb44),.comb240(comb45),
	.hann_clip(hann_out),.diff_out(diff_out),.fw_rect_band(fw_rect_band),.hw_rect_band(hw_rect_band));
	
//	//find which tempo has highest energy
	Peakfinder peakfinder1(.clk(clock_27mhz),.ready(sixk_ready),.reset(hard_reset),
	.comb00(comb00),.comb01(comb01),.comb02(comb02),.comb03(comb03),.comb04(comb04),.comb05(comb05),
	.comb10(comb10),.comb11(comb11),.comb12(comb12),.comb13(comb13),.comb14(comb14),.comb15(comb15),
	.comb20(comb20),.comb21(comb21),.comb22(comb22),.comb23(comb23),.comb24(comb24),.comb25(comb25),
	.comb30(comb30),.comb31(comb31),.comb32(comb32),.comb33(comb33),.comb34(comb34),.comb35(comb35),
	.comb40(comb40),.comb41(comb41),.comb42(comb42),.comb43(comb43),.comb44(comb44),.comb45(comb45),
	.energy60(eng60),.energy90(eng90),.energy120(eng120),.energy180(eng180),
	.energy210(eng210),.energy240(eng240),.tempo(tempo),.beat(beat));

	   // generate basic SVGA video signals
   wire [10:0] hcount;
   wire [9:0]  vcount;
   wire hsync,vsync,blank;
   svga1 svga1(clk,hcount,vcount,hsync,vsync,blank);

   // wire up to ZBT ram
	wire [35:0] vram_write_data, vram_write_data_init, vram_write_data1;
   wire [35:0] vram0_read_data, vram1_read_data, vram_read_data;
   wire [18:0] vram_addr, vram0_addr, vram1_addr, vram_addr0, vram_addr3, vram_addr2;
	wire        vram_we, vram0_we, vram1_we;
   reg we_render;
   reg currentram;

	reg init;
	reg [2:0] addr_count;
   wire ram0_clk_not_used;
	
	wire [31:0] angle;
	wire [11:0] x_rot;
	wire [10:0] y_rot;	
	wire [11:0] x_trans;
	wire [10:0] y_trans;
	wire [11:0] x_in;
	wire [10:0] y_in;
	
	// generate pixel value from reading ZBT memory
   wire [23:0] 	vr_pixel;
	wire [23:0] 	circle_pixel;
	
   wire [18:0] 	vram_addr1;
	wire [23:0] pixel_out;
		
	reg circle = 1;
	wire [7:0] temp = switch[7:0];
		
	wire [18:0] vram_addr_init = {hcount[10:0] + vcount[9:0]*800};
	
	assign vram_addr0 = currentram ? vram_addr2 : vram_addr3;	
	
   wire [18:0] write_addr = circle ? vram_addr_init : vram_addr0;
	
	assign vram0_addr = ~init ? vram_addr_init : (currentram ? write_addr: vram_addr1);	
	assign vram0_we = currentram ? 1 : we_render;
	
	assign vram1_addr = ~currentram ? write_addr : vram_addr1;	
	assign vram1_we = currentram ? we_render : 1;
	
	assign vram_read_data = currentram ? vram1_read_data : vram0_read_data;
	
	assign vram_write_data1 = vram_read_data;
	
   zbt_6111 zbt0(clk, 1'b1, vram0_we, vram0_addr,
		   vram_write_data, vram0_read_data,
		   ram0_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
		   ram0_we_b, ram0_address, ram0_data, ram0_cen_b);
			
	wire ram1_clk_not_used;
	
   zbt_6111 zbt1(clk, 1'b1, vram1_we, vram1_addr,
		   vram_write_data, vram1_read_data,
		   ram1_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
		   ram1_we_b, ram1_address, ram1_data, ram1_cen_b);
			
	graphics_rotation g1(.clk(clk),.reset(reset1), .circle(circle),.addr_count(addr_count), .hcount(hcount), .vcount(vcount),
			.tempo(temp), .vram_addr2(vram_addr2), .vram_addr3(vram_addr3));
	
	image_init im0(.clk(clk), .tempo(temp), .circle(circle),.hcount(hcount), .vcount(vcount), .vsync(vsync),.pixel(circle_pixel));

	assign vram_write_data = (circle ? circle_pixel : vram_write_data1);
			 
	vram_display1 vd1(reset1,clk, ~init, hcount,vcount,vr_pixel,
		    vram_addr1,vram_read_data); 

	always@(posedge clk) begin
		we_render <= ~init ? 1 : 0;	
		
	end
		
	reg shift = 0;
	
	color_shft color(.reset(reset1), .shft(shift), .vr(vr_pixel), .pixel(pixel_out));
	
	
	reg beat_state;
	parameter RESET = 0;
	parameter BEAT = 1;
	reg old_vsync;
	reg vs_pulse;
	
	always@(posedge clk) begin 
		old_vsync <= vsync;
		vs_pulse <= !old_vsync && vsync;
		case(beat_state)
			RESET: if (beat) beat_state <= BEAT;
			BEAT: if (vs_pulse) beat_state <= RESET;
		endcase
	end
	
	
		
	reg [9:0] count= 0;	
	reg reset_circ = 0;	
	reg [8:0] max_tempo = 300;
	reg [9:0] col_count = 0;
	
	always@(posedge vsync) begin
		if (reset1 | (reset_circ != circle))  begin 
			init <= 0;
			shift <= 0;
			currentram <= 0; 
			addr_count <= 0; 
			reset_circ <= 0;
			col_count <= 0; end
		else begin
			init <= 1;
			currentram <= ~currentram;			
			if (count< temp) begin				
			   count <= count + 1;				
			end			
			if (count == temp) begin
				count <= 0;
			end
			if (col_count == 6) begin
				shift <= 1;
				col_count <=0;	end
			if (col_count < 6) begin
				col_count <= col_count + 1; 
				shift <= 0; end
			addr_count <= addr_count+1;			
		end	
				
		circle <= switch[0] ? 1 : 0;		
		reset_circ <= circle; 
	end
		
   reg 	b,hs,vs;
   
   always @(posedge clk)
     begin	
		b <= blank;
		hs <= hsync;
		vs <= vsync;
   end
	
   // VGA Output.  In order to meet the setup and hold times of the
   // AD7125, we send it ~clk.
	assign vga_out_red = pixel_out[23:16];
   assign vga_out_green = pixel_out[15:8];
   assign vga_out_blue = pixel_out[7:0];
   assign vga_out_sync_b = 1'b1;    // not used
   assign vga_out_pixel_clock = ~clk;
   assign vga_out_blank_b = ~b;
   assign vga_out_hsync = hs;
   assign vga_out_vsync = vs;
	
endmodule


module svga1(vclock,hcount,vcount,hsync,vsync,blank);
   input vclock;
   output [10:0] hcount;
   output [9:0] vcount;
   output 	vsync;
   output 	hsync;
   output 	blank;

   reg 	  hsync,vsync,hblank,vblank,blank;
   reg [10:0] 	 hcount;    // pixel number on current line
   reg [9:0] vcount;	 // line number

   // horizontal: 1056 pixels total
   // display 800 pixels per line
   wire      hsyncon,hsyncoff,hreset,hblankon;
   assign    hblankon = (hcount == 799);    
   assign    hsyncon = (hcount == 839);
   assign    hsyncoff = (hcount == 967);
   assign    hreset = (hcount == 1055);

   // vertical: 628 lines total
   // display 600 lines
   wire      vsyncon,vsyncoff,vreset,vblankon;
   assign    vblankon = hreset & (vcount == 599);
   assign    vsyncon = hreset & (vcount == 600);
   assign    vsyncoff = hreset & (vcount == 604);
   assign    vreset = hreset & (vcount == 627);

   // sync and blanking
   wire      next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always @(posedge vclock) begin
      hcount <= hreset ? 0 : hcount + 1;
      hblank <= next_hblank;
      hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync;  // active low

      vcount <= hreset ? (vreset ? 0 : vcount + 1) : vcount;
      vblank <= next_vblank;
      vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;  // active low

      blank <= next_vblank | (next_hblank & ~hreset);
   end
endmodule 

module vram_display1(reset,clk, init, hcount,vcount,vr_pixel,
		    vram_addr,vram_read_data);

   input reset, clk;
   input [10:0] hcount;
   input [9:0] 	vcount;
	input init;
   output [23:0] vr_pixel;
   output [18:0] vram_addr;
   input [35:0]  vram_read_data;
	
	//forecast hcount & vcount 2 clock cycle ahead to get data from ZBT
   wire [10:0] hcount_f = (hcount >= 1054) ? (hcount - 1054) : (hcount + 2);
   wire [9:0] vcount_f = (hcount >= 1054) ? ((vcount == 627) ? 0 : vcount+1) : vcount;
      
   wire [18:0] 	 vram_addr =  {hcount_f[10:0] + vcount_f[9:0]*800};

   wire [1:0] 	 hc4 = hcount[1:0];
   reg [23:0] 	 vr_pixel;
   reg [35:0] 	 vr_data_latched;
   reg [35:0] 	 last_vr_data;

   always @(posedge clk)
     vr_pixel <= vram_read_data[23:0];   

   	 
endmodule // vram_display

module ramclock1(ref_clock, fpga_clock, ram0_clock, ram1_clock, 
	        clock_feedback_in, clock_feedback_out, locked);
   
   input ref_clock;                 // Reference clock input
   output fpga_clock;               // Output clock to drive FPGA logic
   output ram0_clock, ram1_clock;   // Output clocks for each RAM chip
   input  clock_feedback_in;        // Output to feedback trace
   output clock_feedback_out;       // Input from feedback trace
   output locked;                   // Indicates that clock outputs are stable
   
   wire  ref_clk, fpga_clk, ram_clk, fb_clk, lock1, lock2, dcm_reset, ram_clock;

   ////////////////////////////////////////////////////////////////////////////
   
   //To force ISE to compile the ramclock, this line has to be removed.
   //IBUFG ref_buf (.O(ref_clk), .I(ref_clock));
	
	assign ref_clk = ref_clock;
   
   BUFG int_buf (.O(fpga_clock), .I(fpga_clk));

   DCM int_dcm (.CLKFB(fpga_clock),
		.CLKIN(ref_clk),
		.RST(dcm_reset),
		.CLK0(fpga_clk),
		.LOCKED(lock1));
   // synthesis attribute DLL_FREQUENCY_MODE of int_dcm is "LOW"
   // synthesis attribute DUTY_CYCLE_CORRECTION of int_dcm is "TRUE"
   // synthesis attribute STARTUP_WAIT of int_dcm is "FALSE"
   // synthesis attribute DFS_FREQUENCY_MODE of int_dcm is "LOW"
   // synthesis attribute CLK_FEEDBACK of int_dcm  is "1X"
   // synthesis attribute CLKOUT_PHASE_SHIFT of int_dcm is "NONE"
   // synthesis attribute PHASE_SHIFT of int_dcm is 0
   
   BUFG ext_buf (.O(ram_clock), .I(ram_clk));
   
   IBUFG fb_buf (.O(fb_clk), .I(clock_feedback_in));
   
   DCM ext_dcm (.CLKFB(fb_clk), 
		    .CLKIN(ref_clk), 
		    .RST(dcm_reset),
		    .CLK0(ram_clk),
		    .LOCKED(lock2));
   // synthesis attribute DLL_FREQUENCY_MODE of ext_dcm is "LOW"
   // synthesis attribute DUTY_CYCLE_CORRECTION of ext_dcm is "TRUE"
   // synthesis attribute STARTUP_WAIT of ext_dcm is "FALSE"
   // synthesis attribute DFS_FREQUENCY_MODE of ext_dcm is "LOW"
   // synthesis attribute CLK_FEEDBACK of ext_dcm  is "1X"
   // synthesis attribute CLKOUT_PHASE_SHIFT of ext_dcm is "NONE"
   // synthesis attribute PHASE_SHIFT of ext_dcm is 0

   SRL16 dcm_rst_sr (.D(1'b0), .CLK(ref_clk), .Q(dcm_reset),
		     .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   // synthesis attribute init of dcm_rst_sr is "000F";
   

   OFDDRRSE ddr_reg0 (.Q(ram0_clock), .C0(ram_clock), .C1(~ram_clock),
		      .CE (1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0));
   OFDDRRSE ddr_reg1 (.Q(ram1_clock), .C0(ram_clock), .C1(~ram_clock),
		      .CE (1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0));
   OFDDRRSE ddr_reg2 (.Q(clock_feedback_out), .C0(ram_clock), .C1(~ram_clock),
		      .CE (1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0));

   assign locked = lock1 && lock2;
   
endmodule