// OPCD --- OPC, DC, ZERO DRIVE
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-03 02:29:26 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module OPCD
  (input wire  state_alu,
   input wire  state_fetch,
   input wire  state_mmu,
   input wire  state_write,

   input wire  srcdc,
   input wire  srcopc,
   output wire dcdrive,
   output wire opcdrive,

   input wire  clk,
   input wire  reset);

   ////////////////////////////////////////////////////////////////////////////////

   assign dcdrive = srcdc & (state_alu || state_write || state_mmu || state_fetch);
   assign opcdrive = srcopc & (state_alu | state_write);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
