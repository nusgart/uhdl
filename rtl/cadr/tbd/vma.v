module VMA();

   always @(posedge clk)
     if (reset)
       vma <= 0;
     else
       if (state_alu && vmaenb)
	 vma <= vmas;
       else
	 if (ldvmah)
	   vma[31:16] <= spy_in;
	 else
	   if (ldvmal)
	     vma[15:0] <= spy_in;

   assign vmadrive = srcvma &
		     (state_alu || state_write || state_fetch);

endmodule
