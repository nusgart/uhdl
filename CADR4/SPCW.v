// SPCW --- SPC WRITE DATA SEL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-01-23 12:29:26 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module SPCW(/*AUTOARG*/
   // Outputs
   spcw,
   // Inputs
   ipc, wpc, l, destspc, n
   );

   input [13:0] ipc;
   input [13:0] wpc;
   input [31:0] l;
   input destspc;
   input n;
   output [18:0] spcw;

   ////////////////////////////////////////////////////////////////////////////////

   wire [13:0] reta;

   ////////////////////////////////////////////////////////////////////////////////

   assign spcw = destspc ? l[18:0] : {5'b0, reta};
   assign reta = n ? wpc : ipc;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
