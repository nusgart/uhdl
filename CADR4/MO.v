// MO --- MASKER/OUTPUT SELECT
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog; merge of MO0, and MO1.
//	???: Nets added.
//	???: Nets removed.
//   (1980-02-06 12:38:16 TK) MO1: Initial.
//   (1980-02-06 10:24:26 TK) MO0: Initial.

`timescale 1ns/1ps
`default_nettype none

module MO(/*AUTOARG*/
   // Outputs
   ob,
   // Inputs
   osel, a, msk, q, r, alu
   );

   input [1:0] osel;
   input [31:0] a;
   input [31:0] msk;
   input [31:0] q;
   input [31:0] r;
   input [32:0] alu;
   output [31:0] ob;

   ////////////////////////////////////////////////////////////////////////////////

   wire [31:0] mo;              // Masker output.

   ////////////////////////////////////////////////////////////////////////////////

   assign mo = (msk & r) | (~msk & a);
   assign ob = osel == 2'b00 ? mo :
	       osel == 2'b01 ? alu[31:0] :
	       osel == 2'b10 ? alu[32:1] :
	       {alu[30:0], q[31]};

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
