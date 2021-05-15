// MF --- DRIVE MF ONTO M
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-03 02:28:35 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module MF
  (input wire  state_alu,
   input wire  state_fetch,
   input wire  state_mmu,
   input wire  state_write,

   input wire  pdlenb,
   input wire  spcenb,
   input wire  srcm,
   output wire mfdrive,

   input wire  clk,
   input wire  reset);

   wire        mfenb;

   ////////////////////////////////////////////////////////////////////////////////

   assign mfenb = ~srcm & !(spcenb | pdlenb);
   assign mfdrive = mfenb & (state_alu || state_write || state_mmu || state_fetch);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
