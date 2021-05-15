// MCTL --- M CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1979-03-31 04:48:31 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module MCTL
  (input wire	     state_decode,
   input wire	     state_write,

   input wire [48:0] ir,
   input wire [9:0]  wadr,
   input wire	     destm,
   output wire [4:0] madr,
   output wire	     mpassm,
   output wire	     mrp,
   output wire	     mwp,
   output wire	     srcm,

   input wire	     clk,
   input wire	     reset);

   ////////////////////////////////////////////////////////////////////////////////

   assign mpassm = ~ir[31];
   assign srcm = ~ir[31];
   assign mrp = state_decode;
   assign mwp = destm & state_write;

   // Use WADR during STATE_WRITE.
   ///---!!! why use WADR during STATE_WRITE?
   assign madr = ~state_write ? ir[30:26] : wadr[4:0];

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
