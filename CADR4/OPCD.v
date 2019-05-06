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

module OPCD(/*AUTOARG*/
   // Outputs
   dcdrive, opcdrive,
   // Inputs
   state_alu, state_fetch, state_mmu, state_write, srcdc, srcopc
   );

   input state_alu;
   input state_fetch;
   input state_mmu;
   input state_write;

   input srcdc;
   input srcopc;
   output dcdrive;
   output opcdrive;

   ////////////////////////////////////////////////////////////////////////////////

   assign dcdrive = srcdc & (state_alu || state_write || state_mmu || state_fetch);
   assign opcdrive = srcopc & (state_alu | state_write);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
