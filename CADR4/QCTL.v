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

module QCTL
  (input wire	     state_alu,
   input wire	     state_write,
   input wire	     state_mmu,
   input wire	     state_fetch,

   input wire [48:0] ir,
   input wire	     iralu,
   input wire	     srcq,

   output wire	     qs0,
   output wire	     qs1,
   output wire	     qdrive,

   input wire	     clk,
   input wire	     reset);

   ////////////////////////////////////////////////////////////////////////////////

   assign qs1 = ir[1] & iralu;
   assign qs0 = ir[0] & iralu;

   assign qdrive = srcq & (state_alu || state_write || state_mmu || state_fetch);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
