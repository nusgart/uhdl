// vga_display.v --- VGA interface to VRAM

`timescale 1ns/1ps
`default_nettype none

module vga_display
  (output wire [14:0] vram_addr,
   input wire [31:0]  vram_data,
   input wire	      vram_ready,
   output wire	      vram_req,

   output wire	      vga_r,
   output wire	      vga_b,
   output wire	      vga_g,
   output wire	      vga_hsync,
   output wire	      vga_vsync,
   output wire	      vga_blank,

   input wire	      vga_clk,	// VGA clock.
   input wire	      reset);

   `define FULLSCR
   `ifndef FULLSCR
   `ifdef LOWRES
   parameter H_DISP = 640;//1920;//1280;
   parameter H_FPORCH = 16;//110;
   parameter H_SYNC = 96;//40;
   parameter H_BPORCH = 48;//20;

   parameter V_DISP = 480;//1080;//1024;
   parameter V_FPORCH = 11;//5;
   parameter V_SYNC = 2;//5;
   parameter V_BPORCH = 33;//30;
   `define NEG_POL
   `else
   parameter H_DISP = 1920;
   parameter H_FPORCH = 88;
   parameter H_SYNC = 44;
   parameter H_BPORCH = 148;

   parameter V_DISP = 1080;
   parameter V_FPORCH = 4;
   parameter V_SYNC = 5;
   parameter V_BPORCH = 36;
   `define POS_POL
   `endif
   `else
   parameter H_DISP = 1280;
   parameter H_FPORCH = 110;
   parameter H_SYNC = 40;
   parameter H_BPORCH = 220;

   parameter V_DISP = 720;
   parameter V_FPORCH = 5;
   parameter V_SYNC = 5;
   parameter V_BPORCH = 20;
   `define POS_POL
   `endif
   parameter BOX_WIDTH = 768;
   parameter BOX_HEIGHT = 896;

   reg localreset;
   reg r_pipe;
   
   always @(posedge vga_clk, posedge reset)
	if (reset)
		{ localreset, r_pipe } <= 2'b01;
	else
		{ localreset, r_pipe } <= { r_pipe, 1'b0 };

   ////////////////////////////////////////////////////////////////////////////////

   localparam H_COUNTER_MAX = (H_DISP + H_FPORCH + H_SYNC + H_BPORCH);
   localparam V_COUNTER_MAX = (V_DISP + V_FPORCH + V_SYNC + V_BPORCH);

   localparam H_BOX_OFFSET = (H_DISP - BOX_WIDTH) / 2;
   localparam V_BOX_OFFSET = 0;//(V_DISP - BOX_HEIGHT) / 2;

   reg [10:0] h_counter;
   reg [10:0] h_pos;
   reg [10:0] v_counter;
   reg [10:0] v_pos;
   reg [14:0] v_addr;

   wire h_in_border;
   wire v_in_border;
   wire in_border;

   wire h_in_box;
   wire v_in_box;
   wire in_box;

   wire valid;
   wire vclk;

   wire hsync;
   wire vsync;

   ////////////////////////////////////////////////////////////////////////////////
   `define VGA_CORRECT
   `ifndef VGA_CORRECT
   assign hsync = h_counter >= (H_DISP + H_FPORCH) &&
		  h_counter < (H_DISP + H_FPORCH + H_SYNC);

   assign vsync = v_counter >= (V_DISP + V_FPORCH) &&
		  v_counter < (V_DISP + V_FPORCH + V_SYNC);

   assign valid = (h_counter <= H_DISP) &&
		  (v_counter <= V_DISP);
   `else
   localparam HS_START = H_DISP + H_FPORCH;
   localparam HS_END = HS_START + H_SYNC;
   localparam HA_END = H_DISP;
   
   localparam VS_START = V_DISP + V_FPORCH;
   localparam VS_END = VS_START + V_SYNC;
   localparam VA_END = V_DISP;
   
   assign hsync = (h_counter >= HS_START) && (h_counter < HS_END);
   assign vsync = (v_counter >= VS_START) && (v_counter < VS_END);
   assign valid = (h_counter < HA_END) && (v_counter < VA_END);
   `endif

   assign h_in_box = h_counter >= H_BOX_OFFSET &&
		     h_counter < (H_BOX_OFFSET + BOX_WIDTH);

   assign v_in_box = v_counter >= V_BOX_OFFSET &&
		     v_counter < (V_BOX_OFFSET + BOX_HEIGHT);

   assign in_box = valid && h_in_box && v_in_box;


   assign h_in_border = (h_counter == H_BOX_OFFSET - 1) ||
			(h_counter == (H_BOX_OFFSET + BOX_WIDTH));

   assign v_in_border = (v_counter == V_BOX_OFFSET - 1) ||
			(v_counter == (V_BOX_OFFSET + BOX_HEIGHT));

   assign in_border = valid && (h_in_border || v_in_border);

   assign vclk = h_counter == H_COUNTER_MAX;

   ////////////////////////////////////////////////////////////////////////////////
   // Horizontal and vertical counters

   always @(posedge vga_clk)
     if (localreset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	h_counter <= 11'h0;
	// End of automatics
     end else if (h_counter >= H_COUNTER_MAX)
       h_counter <= 0;
     else
       h_counter <= h_counter + 1;

   always @(posedge vga_clk)
     if (localreset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	v_counter <= 11'h0;
	// End of automatics
     end else if (vclk) begin
	if (v_counter >= V_COUNTER_MAX)
	  v_counter <= 0;
	else
	  v_counter <= v_counter + 1;
     end

   ////////////////////////////////////////////////////////////////////////////////
   // Horizontal and vertical position

   always @(posedge vga_clk)
     if (localreset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	h_pos <= 11'h0;
	// End of automatics
     end else if (h_in_box) begin
	if (h_pos >= BOX_WIDTH)
	  h_pos <= 0;
	else
	  h_pos <= h_pos + 1;
     end else
       h_pos <= 0;

   always @(posedge vga_clk)
     if (localreset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	v_pos <= 11'h0;
	// End of automatics
     end else if (vclk) begin
	if (v_in_box) begin
	   if (v_pos >= BOX_HEIGHT - 1)
	     v_pos <= 0;
	   else
	     v_pos <= v_pos + 1;
	end else
	  v_pos <= 0;
     end

   ////////////////////////////////////////////////////////////////////////////////
   // Grab data from VRAM

   reg [31:0] ram_data_hold;
   reg [31:0] ram_shift;
   reg ram_data_hold_empty;
   wire ram_data_hold_req;
   wire ram_shift_load;
   reg ram_req;

   // Grab VRAM data when ready.
   always @(posedge vga_clk)
     if (localreset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	ram_data_hold <= 32'h0;
	// End of automatics
     end else if (vram_ready && ram_data_hold_empty)
       //ram_data_hold <= {1'b1, vram_data[30:0]};
       ram_data_hold <= vram_data;

   // Ask for new VRAM data when hold empty.
   always @(posedge vga_clk)
     if (localreset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	ram_req <= 1'h0;
	// End of automatics
     end else
       ram_req <= ram_data_hold_req && ram_data_hold_empty;

   reg pixel;

   // Pixel shift register.
   always @(posedge vga_clk)
     if (localreset) begin
	   /*AUTORESET*/
	   // Beginning of autoreset for uninitialized flops
	   pixel <= 1'h0;
	   ram_data_hold_empty <= 1'h0;
	   ram_shift <= 32'h0;
	 // End of automatics
     end else if (ram_shift_load) begin
	   ram_shift <= ram_data_hold;
	   ram_data_hold_empty <= 1'b1;
	   pixel <= ram_shift[0];
     end else begin
	   ram_shift <= { 1'b0, ram_shift[31:1] };
	   pixel <= ram_shift[0];
	 if (vram_ready)
	  ram_data_hold_empty <= 0;
     end

   wire v_addr_inc;

   // VRAM address.
   always @(posedge vga_clk)
     if (localreset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	v_addr <= 15'h0;
	// End of automatics
     end else begin
	if (~v_in_box)
	  v_addr <= 0;
	else if (v_addr_inc)
	  v_addr <= v_addr + 1;
     end

   wire preload, preload1, preload2;

   // Increment once before visable, don't increment after last load.
   assign v_addr_inc = ram_shift_load &&
		       (in_box || preload2) &&
		       (h_pos != BOX_WIDTH - 2);
   assign preload1 = h_counter == (H_BOX_OFFSET - 33);
   assign preload2 = h_counter == (H_BOX_OFFSET - 2);
   assign preload = preload1 || preload2;
   assign ram_shift_load = (h_pos[4:0] == 5'h1e) || preload;
   assign ram_data_hold_req = (h_pos[4:0] >= 5'h0f) ||
			      (h_counter >= (H_BOX_OFFSET - 16) && h_counter < H_BOX_OFFSET);

   ////////////////////////////////////////////////////////////////////////////////

   assign vram_addr = v_addr;
   assign vram_req = ram_req;

   assign vga_r = in_box ? pixel : in_border;
   assign vga_b = in_box ? pixel : in_border;
   assign vga_g = in_box ? pixel : in_border;
   assign vga_vsync = vsync;
   assign vga_hsync = hsync;
   assign vga_blank = ~valid;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
