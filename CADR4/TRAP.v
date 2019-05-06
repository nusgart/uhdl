// TRAP --- PARITY ERROR TRAP
//
// ---!!! Remove this module; we don't need parity.
//
// History:
//
//   (1978-05-08 07:19:04 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module TRAP(/*AUTOARG*/
   // Outputs
   trap,
   // Inputs
   boot_trap
   );

   input boot_trap;
   output trap;

   ////////////////////////////////////////////////////////////////////////////////

   assign trap = boot_trap;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
