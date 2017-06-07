module NPC();

   assign npc =
		trap ? 14'b0 :
		{pcs1,pcs0} == 2'b00 ? { spc[13:2], spc1a, spc[0] } :
		{pcs1,pcs0} == 2'b01 ? { ir[25:12] } :
		{pcs1,pcs0} == 2'b10 ? dpc :
		/*2'b11*/ ipc;

   always @(posedge clk)
     if (reset)
       pc <= 0;
     else
       if (state_fetch)
	 pc <= npc;

   assign ipc = pc + 14'd1;

endmodule
