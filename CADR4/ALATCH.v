// ALATCH --- A MEMORY LATCH
//
// ---!!! Remove this module.
//
// History:
//
//   (1978-02-03 04:25:37 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module ALATCH(/*AUTOARG*/
   // Outputs
   a,
   // Inputs
   amem
   );

   input [31:0] amem;
   output [31:0] a;

   ////////////////////////////////////////////////////////////////////////////////

   assign a = amem;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
