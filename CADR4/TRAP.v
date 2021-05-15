// TRAP --- PARITY ERROR TRAP
//
// ---!!! Remove this module; we don't need parity.
//
// History:
//
//   (1978-05-08 07:19:04 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module TRAP
  (input wire  boot_trap,
   output wire trap,

   input wire  clk,
   input wire  reset);

   ////////////////////////////////////////////////////////////////////////////////

   assign trap = boot_trap;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
