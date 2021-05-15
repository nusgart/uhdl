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

module MLATCH
  (input wire [18:0]  spco,
   input wire [31:0]  mf,
   input wire [31:0]  mmem,
   input wire [31:0]  pdlo,
   input wire [4:0]   spcptr,
   input wire	      mfdrive,
   input wire	      mpassm,
   input wire	      pdldrive,
   input wire	      spcdrive,
   output wire [31:0] m,

   input wire	      clk,
   input wire	      reset);

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
