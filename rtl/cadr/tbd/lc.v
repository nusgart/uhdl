module LC();

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
