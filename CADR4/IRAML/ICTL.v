// ICTL --- I RAM CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-07 05:36:00 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module ICTL(/*AUTOARG*/
   // Outputs
   iwe,
   // Inputs
   state_write, idebug, iwrited, promdisabled
   );

   input wire state_write;

   input wire idebug;
   input wire iwrited;
   input wire promdisabled;
   output wire iwe;

   ////////////////////////////////////////////////////////////////////////////////

   wire ramdisable;

   ////////////////////////////////////////////////////////////////////////////////

   assign ramdisable = idebug | ~(promdisabled | iwrited);
   assign iwe = iwrited & state_write;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
