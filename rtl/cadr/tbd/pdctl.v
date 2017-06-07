module PDCTL();

   /* m-src = pdl buffer, or index based write */
   assign pdlp = (state_read & ir[30]) | (~state_read & ~pwidx);

   assign pdla = pdlp ? pdlptr : pdlidx;

   assign pdlwrite = destpdltop | destpdl_x | destpdl_p;

   always @(posedge clk)
     if (reset)
       begin
	  pwidx <= 0;
       end
     else
       if (state_alu | state_write)
	 begin
	    pwidx <= destpdl_x;
	 end

   assign pwp = pdlwrite & state_write;
   assign prp = pdlenb && state_read;

   assign pdlenb = srcpdlpop | srcpdltop;

   assign pdldrive = pdlenb &
		     (state_alu || state_write || state_mmu || state_fetch);

   assign pdlcnt = (~nop & srcpdlpop) | destpdl_p;

endmodule
