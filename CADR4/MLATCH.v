// MLATCH --- M MEMORY LATCH
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog; merge of PLATCH,
//   SPCLCH.
//	???: Nets added.
//	???: Nets removed.
//   (1978-01-23 12:33:10 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module MLATCH(/*AUTOARG*/
   // Outputs
   m,
   // Inputs
   spco, mf, mmem, pdlo, spcptr, mfdrive, mpassm, pdldrive, spcdrive
   );

   input [18:0] spco;
   input [31:0] mf;
   input [31:0] mmem;
   input [31:0] pdlo;
   input [4:0] spcptr;
   input mfdrive;
   input mpassm;
   input pdldrive;
   input spcdrive;
   output [31:0] m;

   ////////////////////////////////////////////////////////////////////////////////

   assign m = mpassm ? mmem :
	      pdldrive ? pdlo :
	      spcdrive ? {3'b0, spcptr, 5'b0, spco} :
	      mfdrive ? mf :
	      32'b0;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
