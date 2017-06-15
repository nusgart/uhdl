// MSKG4
//
// TK		CADR	MASK GENERATION

module MSKG4(clk, mskl, mskr, msk);

   input clk;

   input [4:0] mskl;
   input [4:0] mskr;
   output [31:0] msk;

   ////////////////////////////////////////////////////////////////////////////////

   wire [31:0]	 msk_left_out;
   wire [31:0]	 msk_right_out;

   part_32x32prom_maskleft i_MSKR(
				  .clk(~clk),
				  .q(msk_left_out),
				  .addr(mskl)
				  );

   part_32x32prom_maskright i_MSKL(
				   .clk(~clk),
				   .q(msk_right_out),
				   .addr(mskr)
				   );

   assign msk = msk_right_out & msk_left_out;

endmodule
