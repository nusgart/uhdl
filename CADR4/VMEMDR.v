// VMEMDR --- MAP OUTPUT DRIVE
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-16 06:51:31 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module VMEMDR(/*AUTOARG*/
   // Outputs
   pma, lvmo_22, lvmo_23, mapdrive,
   // Inputs
   state_alu, state_fetch, state_mmu, state_write, vmo, srcmap
   );

   input wire state_alu;
   input wire state_fetch;
   input wire state_mmu;
   input wire state_write;

   input [23:0] vmo;
   input wire srcmap;
   output [21:8] pma;
   output wire lvmo_22;
   output wire lvmo_23;
   output wire mapdrive;

   ////////////////////////////////////////////////////////////////////////////////

   assign lvmo_23 = vmo[23];
   assign lvmo_22 = vmo[22];
   assign pma = vmo[13:0];
   assign mapdrive = srcmap & (state_alu || state_write || state_mmu || state_fetch);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
