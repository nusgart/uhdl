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

module MF(/*AUTOARG*/
   // Outputs
   mfdrive,
   // Inputs
   state_alu, state_fetch, state_mmu, state_write, pdlenb, spcenb,
   srcm
   );

   input state_alu;
   input state_fetch;
   input state_mmu;
   input state_write;

   input pdlenb;
   input spcenb;
   input srcm;
   output mfdrive;

   ////////////////////////////////////////////////////////////////////////////////

   wire mfenb;

   ////////////////////////////////////////////////////////////////////////////////

   assign mfenb = ~srcm & !(spcenb | pdlenb);
   assign mfdrive = mfenb & (state_alu || state_write || state_mmu || state_fetch);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
