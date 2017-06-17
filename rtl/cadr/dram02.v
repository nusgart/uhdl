// DRAM0, DRAM1, DRAM2
//
// TK		CADR	DISPATCH RAM

module DRAM02(clk, reset, daddr0, dadr, dwe, a, ir, vmo, dmask, r, dr, dp, dn, dpc, dispwr, state_write, state_prefetch);

   input clk;
   input reset;

   input	state_prefetch;
   input	state_write;

   input [23:0] vmo;
   input [31:0] a;;
   input [31:0] r;
   input [48:0] ir;
   input [6:0]	dmask;
   input	dispwr;
   output [10:0] dadr;
   output [13:0] dpc;
   output	 daddr0;
   output	 dp;
   output	 dn;
   output	 dr;
   output	 dwe;

   ////////////////////////////////////////////////////////////////////////////////

   // dadr  10 9  8  7  6  5  4  3  2  1  0
   // -------------------------------------
   // ir    22 21 20 19 18 17 16 15 14 13 d
   // dmask x  x  x  x  6  5  4  3  2  1  x
   // r     x  x  x  x  6  5  4  3  2  1  x

   assign daddr0 =
		   (ir[8] & vmo[18]) |
		   (ir[9] & vmo[19]) |
		   //note: the hardware shows bit 0 replaced,
		   //	but usim or's it instead.
		   (/*~dmapbenb &*/ dmask[0] & r[0]) |
		   (ir[12]);

   assign dadr =
		{ ir[22:13], daddr0 } |
		({ 4'b0000, dmask[6:1], 1'b0 } &
		 { 4'b0000, r[6:1],     1'b0 });

   assign dwe = dispwr & state_write;

   // dispatch ram
   part_2kx17dpram i_DRAM(
			  .reset(reset),

			  .clk_a(clk),
			  .address_a(dadr),
			  .q_a({dr,dp,dn,dpc}),
			  .data_a(17'b0),
			  .wren_a(1'b0),
			  .rden_a(~state_prefetch && ~dwe),

			  .clk_b(clk),
			  .address_b(dadr),
			  .q_b(),
			  .data_b(a[16:0]),
			  .wren_b(dwe),
			  .rden_b(1'b0)
			  );

endmodule
