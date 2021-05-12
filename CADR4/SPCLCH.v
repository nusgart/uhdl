// SPCLCH --- SPC MEMORY LATCH
//
// ---!!! Remove this module.
//
// History:
//
//   (1978-02-03 04:44:10 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module SPCLCH
  (input wire [18:0]  spco,
   output wire [18:0] spc,

   input wire	      clk,
   input wire	      reset);

   ////////////////////////////////////////////////////////////////////////////////

   assign spc = spco;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
