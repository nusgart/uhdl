// keyboard.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module keyboard(/*AUTOARG*/
   // Outputs
   data, strobe,
   // Inputs
   clk, reset, ps2_clk, ps2_data
   );

   input clk;
   input reset;

   input ps2_clk;
   input ps2_data;

   output [15:0] data;
   output strobe;

   ////////////////////////////////////////////////////////////////////////////////

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			busy;			// From ps2 of ps2.v
   wire [7:0]		code;			// From ps2 of ps2.v
   wire			error;			// From ps2 of ps2.v
   wire [15:0]		keycode;		// From scancode_convert of scancode_convert.v
   wire			parity;			// From ps2 of ps2.v
   wire			rdy;			// From ps2 of ps2.v
   wire			strobe_out;		// From scancode_convert of scancode_convert.v
   // End of automatics
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [15:0]		data;
   reg			strobe;
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   ps2 ps2(/*AUTOINST*/
	   // Outputs
	   .code			(code[7:0]),
	   .parity			(parity),
	   .busy			(busy),
	   .rdy				(rdy),
	   .error			(error),
	   // Inputs
	   .clk				(clk),
	   .reset			(reset),
	   .ps2_clk			(ps2_clk),
	   .ps2_data			(ps2_data));

   scancode_convert scancode_convert
     (
      .strobe_in(rdy),
      /*AUTOINST*/
      // Outputs
      .strobe_out			(strobe_out),
      .keycode				(keycode[15:0]),
      // Inputs
      .clk				(clk),
      .reset				(reset),
      .code				(code[7:0]));

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	data <= 16'h0;
	strobe <= 1'h0;
	// End of automatics
     end else begin
	data <= keycode;
	strobe <= strobe_out;
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
