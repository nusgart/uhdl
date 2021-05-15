// keyboard.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module keyboard
  (input wire 	     ps2_clk,
   input wire 	     ps2_data,

   output reg [15:0] data,
   output reg 	     strobe,

   input wire 	     clk,
   input wire 	     reset);
   
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

   ////////////////////////////////////////////////////////////////////////////////

   ps2 ps2(/*AUTOINST*/
	   // Outputs
	   .code			(code[7:0]),
	   .parity			(parity),
	   .busy			(busy),
	   .rdy				(rdy),
	   .error			(error),
	   // Inputs
	   .ps2_clk			(ps2_clk),
	   .ps2_data			(ps2_data),
	   .clk				(clk),
	   .reset			(reset));

   scancode_convert scancode_convert
     (
      .strobe_in(rdy),
      /*AUTOINST*/
      // Outputs
      .strobe_out			(strobe_out),
      .keycode				(keycode[15:0]),
      // Inputs
      .code				(code[7:0]),
      .clk				(clk),
      .reset				(reset));

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
// verilog-library-directories: ("." "cores/")
// End:
