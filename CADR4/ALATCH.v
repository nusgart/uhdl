// ALATCH --- A MEMORY LATCH
//
// ---!!! Remove this module.
//
// History:
//
//   (1978-02-03 04:25:37 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module ALATCH
  (input wire [31:0]  amem,
   output wire [31:0] a,

   input wire	      clk,
   input wire	      reset);

   ////////////////////////////////////////////////////////////////////////////////

   assign a = amem;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
