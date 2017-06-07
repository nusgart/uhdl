module DSPCTL();

   assign dmapbenb  = ir[8] | ir[9];

   assign dispwr = irdisp & funct[2];

   always @(posedge clk)
     if (reset)
       dc <= 0;
     else
       if (state_fetch && irdisp)
	 dc <= ir[41:32];

   wire   nc_dmask;

   part_32x8prom i_DMASK(
			 .clk(~clk),
			 .addr( {1'b0, 1'b0, ir[7], ir[6], ir[5]} ),
			 .q( {nc_dmask, dmask[6:0]} )
			 );

endmodule
