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

module MSKG4
  (input wire [4:0]   mskl,
   input wire [4:0]   mskr,
   output wire [31:0] msk,

   input wire	      clk,
   input wire	      reset);

   wire		      nclk = ~clk;

   wire [31:0]	      msk_left;
   wire [31:0]	      msk_right;

   localparam	      ADDR_WIDTH = 5;
   localparam	      DATA_WIDTH = 32;
   localparam	      MEM_DEPTH = 32;

   ////////////////////////////////////////////////////////////////////////////////

   rom #(.ADDRESS_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_DEPTH(MEM_DEPTH),
	 .MEM_FILE("CADR4/mskl.bin"), .MEM_FILE_FORMAT("binary")) MSKL
     (.clk_i(nclk), .addr_i(mskl), .q_o(msk_left));
   rom #(.ADDRESS_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_DEPTH(MEM_DEPTH),
	 .MEM_FILE("CADR4/mskr.bin"), .MEM_FILE_FORMAT("binary")) MSKR
     (.clk_i(nclk), .addr_i(mskr), .q_o(msk_right));

   assign msk = msk_right & msk_left;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
