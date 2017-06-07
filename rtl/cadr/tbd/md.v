module MD();

   always @(posedge clk)
     if (reset)
       begin
	  md <= 32'b0;
	  mdhaspar <= 1'b0;
	  mdpar <= 1'b0;
       end
     else
       if ((loadmd && memrq) || (state_alu && destmdr))
	 begin
	    md <= mds;
	    mdhaspar <= mdgetspar;
	 end
       else
	 if (ldmdh)
	   md[31:16] <= spy_in;
	 else
	   if (ldmdl)
	     md[15:0] <= spy_in;

   assign mddrive = srcmd &
		    (state_alu || state_write || state_mmu || state_fetch);

   assign mdgetspar = ~destmdr & ~ignpar;
   assign ignpar = 1'b0;

   assign mdclk = loadmd | destmdr;

endmodule
