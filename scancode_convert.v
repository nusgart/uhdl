// scancode_convert.v --- convert PS/2 to Space Cadet scancode
//
// ---!!! Document input/output ports.

/* verilator lint_off CASEINCOMPLETE */

`timescale 1ns/1ps
`default_nettype none

module scancode_convert(/*AUTOARG*/
   // Outputs
   strobe_out, keycode,
   // Inputs
   clk, reset, strobe_in, code
   );

   input wire clk;
   input wire reset;

   input wire strobe_in;
   input [7:0] code;
   output wire strobe_out;
   output [15:0] keycode;

   ////////////////////////////////////////////////////////////////////////////////

   reg [7:0] sc = 0;
   reg e0_prefix = 0;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [7:0]		data;			// From scancode_rom of scancode_rom.v
   // End of automatics
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [15:0]		keycode;
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   wire [8:0] addr = {e0_prefix, sc};
   scancode_rom scancode_rom(/*AUTOINST*/
			     // Outputs
			     .data		(data[7:0]),
			     // Inputs
			     .addr		(addr[8:0]));

   ////////////////////////////////////////////////////////////////////////////////
   // PS/2 State Machine

   localparam [2:0]
     IDLE = 0,
     E0 = 1,
     F0 = 2,
     E0F0 = 3,
     CONVERT_DOWN = 4,
     CONVERT_UP = 5,
     STROBE = 6;

   reg [2:0] state = IDLE;
   wire [2:0] state_ns;

   always @(posedge clk)
     if (reset) begin
	state <= IDLE;
     end else begin
	state <= state_ns;
     end

   assign state_ns =
		    (state == IDLE && strobe_in && code == 8'he0) ? E0 :
		    (state == IDLE && strobe_in && code == 8'hf0) ? F0 :
		    (state == IDLE && strobe_in) ? CONVERT_DOWN :
		    (state == F0 && strobe_in) ? CONVERT_UP :
		    (state == E0 && strobe_in && code == 8'hf0) ? E0F0 :
		    (state == E0 && strobe_in && code != 8'hf0) ? CONVERT_DOWN :
		    (state == E0F0 && strobe_in) ? CONVERT_UP :
		    (state == CONVERT_DOWN) ? STROBE :
		    (state == CONVERT_UP) ? STROBE :
		    (state == STROBE) ? IDLE :
		    state;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	e0_prefix <= 1'h0;
	keycode <= 16'h0;
	sc <= 8'h0;
	// End of automatics
     end else begin
	if (strobe_in) begin
	   sc <= code;
	end else begin
	   case (state)
	     E0: e0_prefix <= 1;
	     CONVERT_DOWN: begin
		keycode <= { 7'b0, 1'b0, data };
		e0_prefix <= 0;
	     end
	     CONVERT_UP: begin
		keycode <= { 7'b0, 1'b1, data };
		e0_prefix <= 0;
	     end
	   endcase
	end
     end

   assign strobe_out = state == STROBE;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
