// LC
//
// TK		CADR	LOCATION COUNTER

module LC(clk, reset, destlc, lcry3, lca, lcinc, lc_byte_mode, lc, srclc, state_alu, state_write, state_mmu, state_fetch, ob, lcdrive, opcdrive, opc, dcdrive, dc, pdlptr, pidrive, pdlidx, qdrive, q, mddrive, md, vmadrive, vma, mapdrive, pfw, needfetch, int_enable, prog_unibus_reset, sequence_break, lc0b, ppdrive, vmap, pfr, vmo, mf);

   input clk;
   input reset;

   input	state_alu;
   input	state_fetch;
   input	state_mmu;
   input	state_write;

   input [13:0] opc;
   input [23:0] vmo;
   input [31:0] md;
   input [31:0] ob;
   input [31:0] q;
   input [31:0] vma;
   input [4:0]	vmap;
   input [9:0]	dc;
   input [9:0]	pdlidx;
   input [9:0]	pdlptr;
   input	dcdrive;
   input	destlc;
   input	int_enable;
   input	lc0b;
   input	lc_byte_mode;
   input	lcinc;
   input	mapdrive;
   input	mddrive;
   input	needfetch;
   input	opcdrive;
   input	pfr;
   input	pfw;
   input	pidrive;
   input	ppdrive;
   input	prog_unibus_reset;
   input	qdrive;
   input	sequence_break;
   input	srclc;
   input	vmadrive;
   output [25:0] lc;
   output [31:0] mf;
   output [3:0]  lca;
   output	 lcdrive;
   output	 lcry3;

   ////////////////////////////////////////////////////////////////////////////////

   reg [25:0]	 lc;

   always @(posedge clk)
     if (reset)
       lc <= 0;
     else
       if (state_fetch)
	 begin
	    if (destlc)
	      lc <= { ob[25:4], ob[3:0] };
	    else
	      lc <= { lc[25:4] + { 21'b0, lcry3 }, lca[3:0] };
	 end

   assign {lcry3, lca[3:0]} =
			     lc[3:0] +
			     { 3'b0, lcinc & ~lc_byte_mode } +
			     { 3'b0, lcinc };

   assign lcdrive  = srclc &&
		     (state_alu || state_write || state_mmu || state_fetch);

   // xxx
   // I think the above is really
   //
   // always @(posedge clk)
   //   begin
   //     if (destlc_n == 0)
   //       lc <= ob;
   //     else
   //       lc <= lc +
   //             !(lcinc_n | lc_byte_mode) ? 1 : 0 +
   //             lcinc ? 1 : 0;
   //   end
   //

   // mux MF
   assign mf =
	lcdrive ?
	      { needfetch, 1'b0, lc_byte_mode, prog_unibus_reset,
		int_enable, sequence_break, lc[25:1], lc0b } :
	opcdrive ?
	      { 16'b0, 2'b0, opc[13:0] } :
	dcdrive ?
	      { 16'b0, 4'b0, 2'b0, dc[9:0] } :
	ppdrive ?
	      { 16'b0, 4'b0, 2'b0, pdlptr[9:0] } :
	pidrive ?
	      { 16'b0, 4'b0, 2'b0, pdlidx[9:0] } :
	qdrive ?
	      q :
	mddrive ?
	      md :
//	mpassl ?
//	      l :
	vmadrive ?
	      vma :
	mapdrive ?
	      { ~pfw, ~pfr, 1'b1, vmap[4:0], vmo[23:0] } :
	      32'b0;

endmodule
