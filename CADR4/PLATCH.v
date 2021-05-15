// PLATCH --- PDL BUFFER LATCH
//
// ---!!! Remove this module.
//
// History:
//
//   (1978-01-23 12:31:09 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module PLATCH
  (input wire [31:0]  pdlo,
   output wire [31:0] pdl,

   input wire	      clk,
   input wire	      reset);

   ////////////////////////////////////////////////////////////////////////////////

   assign pdl = pdlo;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
