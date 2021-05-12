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

module L
  (input wire	     state_alu,
   input wire	     state_write,

   input wire [31:0] ob,
   input wire	     vmaenb,
   output reg [31:0] l,

   input wire	     clk,
   input wire	     reset);

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
