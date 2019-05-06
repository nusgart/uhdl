// MSKG4 --- MASK GENERATION
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1980-02-06 08:46:58 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module MSKG4(/*AUTOARG*/
   // Outputs
   msk,
   // Inputs
   clk, mskl, mskr
   );

   input clk;

   input [4:0] mskl;
   input [4:0] mskr;
   output [31:0] msk;

   ////////////////////////////////////////////////////////////////////////////////

   wire nclk = ~clk;

   wire [31:0] msk_left;
   wire [31:0] msk_right;

   rom #(.ADDRESS_WIDTH(5), .DATA_WIDTH(32), .MEM_DEPTH(32),
	 .MEM_FILE("mskl.bin"), .MEM_FILE_FORMAT("binary")) MSKL
     (.clk_i(nclk), .addr_i(mskl), .q_o(msk_left));
   rom #(.ADDRESS_WIDTH(5), .DATA_WIDTH(32), .MEM_DEPTH(32),
	 .MEM_FILE("mskr.bin"), .MEM_FILE_FORMAT("binary")) MSKR
     (.clk_i(nclk), .addr_i(mskr), .q_o(msk_right));

   assign msk = msk_right & msk_left;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
