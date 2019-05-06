// L --- A CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-01-24 13:36:04 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module L(/*AUTOARG*/
   // Outputs
   l,
   // Inputs
   clk, reset, state_alu, state_write, ob, vmaenb
   );

   input clk;
   input reset;

   input state_alu;
   input state_write;

   input [31:0] ob;
   input vmaenb;
   output [31:0] l;

   ////////////////////////////////////////////////////////////////////////////////

   reg [31:0] l;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       l <= 0;
     else
       // VMA is latched during STATE_ALU, so this must be too.
       if ((vmaenb && (state_write || state_alu)) || (~vmaenb && state_alu))
	 l <= ob;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
