// TK		CADR	LOCATION COUNTER

module LC(clk, reset, destlc, lcry3, lca, lcinc, lc_byte_mode, lc, srclc, state_alu, state_write, state_mmu, state_fetch, ob,lcdrive);

   input clk;
   input reset;

   input [31:0] ob;
   input	destlc;
   input	lc_byte_mode;
   input	lcinc;
   input	srclc;
   input	state_alu;
   input	state_fetch;
   input	state_mmu;
   input	state_write;
   output [25:0] lc;
   output [3:0]  lca;
   output	 lcry3;
   output lcdrive;

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

endmodule
