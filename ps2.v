// ps2.v --- ---!!!
//
// Monitor the serial datastream and clock from a PS/2 keyboard or
// mouse and output each byte received.
//
// The clock from the PS/2 keyboard is sampled at the frequency of the
// main clock input; edges are extracted.  The main clock must be
// substantially faster than the 10 KHz PS/2 clock - 200 KHz or more.
//
// The code is only valid when the ready signal is high.  The scancode
// should be registered by an external circuit on the first clock edge
// after the ready signal goes high.
//
// The error flag is set whenever the PS/2 clock stops pulsing and the
// PS/2 clock is either at a low level or less than 11 bits of serial
// data have been received (start + 8 data + parity + stop).

/* verilator lint_off WIDTH */

`timescale 1ns/1ps
`default_nettype none

module ps2(/*AUTOARG*/
   // Outputs
   code, parity, busy, rdy, error,
   // Inputs
   clk, reset, ps2_clk, ps2_data
   );

   parameter FREQ = 50000;	// Main clock frequency (KHz).
   parameter PS2_FREQ = 10;	// Keyboard clock frequency (KHz).

   input wire clk;			// Main clock.
   input wire reset;			// Asynchronous reset.

   input wire ps2_clk;		// Clock from keyboard.
   input wire ps2_data;		// Data from keyboard.

   output [7:0] code;		// Received byte.
   output wire parity;		// Parity bit for scancode.
   output wire busy;			// Busy receiving scancode.
   output wire rdy;			// Scancode ready pulse.
   output wire error;		// Error receiving scancode.

   ////////////////////////////////////////////////////////////////////////////////

   localparam TIMEOUT = FREQ / PS2_FREQ; // Quiet timeout.

   reg [13:0] timer_r;		// Time since last PS/2 clock edge.
   wire [13:0] timer_c;

   reg [3:0] bitcnt_r;		// Number of received scancode bits.
   wire [3:0] bitcnt_c;

   reg [4:0] ps2_clk_r;		// PS/2 clock sync/edge detect.
   wire [4:0] ps2_clk_c;

   reg [9:0] sc_r;		// Scancode shift register.
   wire [9:0] sc_c;

   reg error_r;			// Set when an error occurs.
   wire error_c;

   reg rdy_r;			// Set when scancode ready.
   wire rdy_c;

   wire ps2_clk_edge;	   // On falling edge of PS/2 clock.
   wire ps2_clk_fall_edge; // On rising edge of PS/2 clock.
   wire ps2_clk_quiet;	   // When no edges on PS/2 clock for TIMEOUT.
   wire ps2_clk_rise_edge; // When scancode has been received.

   wire scancode_rdy;

   ////////////////////////////////////////////////////////////////////////////////

   // Sample PS/2 clock.
   assign ps2_clk_c = {ps2_clk_r[3:0], ps2_clk};

   // Find PS/2 clock edges.
   assign ps2_clk_fall_edge = ps2_clk_r[4:1] == 4'b1100;
   assign ps2_clk_rise_edge = ps2_clk_r[4:1] == 4'b0011;
   assign ps2_clk_edge = ps2_clk_fall_edge || ps2_clk_rise_edge;

   // Sample PS/2 data line on falling edge of PS/2 clock.
   assign sc_c = ps2_clk_fall_edge ? {ps2_data, sc_r[9:1]} : sc_r;

   // Clear edge timer when we see a clock edge.
   assign timer_c = ps2_clk_edge ? 0 : (timer_r + 1);

   // Notice when PS/2 clock is idle
   assign ps2_clk_quiet = timer_r == TIMEOUT && ps2_clk_r[1];

   // Increment bit counter on falling edge of the PS/2 clock.  Reset
   // bit counter if the PS/2 clock is idle or there was an error
   // receiving the scancode.
   assign bitcnt_c = ps2_clk_fall_edge ? (bitcnt_r + 1) :
		     (ps2_clk_quiet || error_r) ? 0 :
		     bitcnt_r;

   // Detect ready - bit counter = 11 & PS/2 clock idle.
   assign scancode_rdy = bitcnt_r == 4'd11 && ps2_clk_quiet;

   assign rdy_c = scancode_rdy;

   // Detect error - clock low too long or idle during scancode RX.
   assign error_c = (timer_r == TIMEOUT && ps2_clk_r[1] == 0) ||
		    (ps2_clk_quiet && bitcnt_r != 4'd11 && bitcnt_r != 4'd0) ?
		    ///---!!!		    1 : error_r;		    
		    1 : (ps2_clk_quiet ? 0 : error_r);

   // Update various registers.
   always @(posedge clk)
     if (reset) begin
	ps2_clk_r <= 5'b11111;  // Assume PS/2 clock has been high.
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	bitcnt_r <= 4'h0;
	error_r <= 1'h0;
	rdy_r <= 1'h0;
	sc_r <= 10'h0;
	timer_r <= 14'h0;
	// End of automatics
     end else begin
	ps2_clk_r <= ps2_clk_c;
	sc_r <= sc_c;
	rdy_r <= rdy_c;
	timer_r <= timer_c;
	bitcnt_r <= bitcnt_c;
	error_r <= error_c;
     end

   ////////////////////////////////////////////////////////////////////////////////
   // Outputs

   assign code = sc_r[7:0];	   // Scancode.
   assign parity = sc_r[8];	   // Parity bit for the scancode.
   assign busy = bitcnt_r != 4'd0; // Busy when receiving scancode.
   assign rdy = rdy_r;		   // Scancode ready flag.
   assign error = error_r;	   // Error flag.

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
