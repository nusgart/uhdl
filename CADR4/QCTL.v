// QCTL --- Q REGISTER CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-16 05:40:45 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module QCTL(/*AUTOARG*/
   // Outputs
   qs0, qs1, qdrive,
   // Inputs
   state_alu, state_write, state_mmu, state_fetch, ir, iralu, srcq
   );

   input state_alu;
   input state_write;
   input state_mmu;
   input state_fetch;

   input [48:0] ir;
   input iralu;
   input srcq;

   output qs0;
   output qs1;
   output qdrive;

   ////////////////////////////////////////////////////////////////////////////////

   assign qs1 = ir[1] & iralu;
   assign qs0 = ir[0] & iralu;

   assign qdrive = srcq & (state_alu || state_write || state_mmu || state_fetch);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
