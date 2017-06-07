module OPCD (dcdrive, opcdrive, srcdc, srcopc, state_alu, state_write, state_mmu, state_fetch);

   input srcdc, srcopc, state_alu, state_write, state_mmu, state_fetch;
   output dcdrive, opcdrive;

   assign dcdrive = srcdc &	/* dispatch constant */
		    (state_alu || state_write || state_mmu || state_fetch);

   assign opcdrive = srcopc &
		     (state_alu | state_write);

endmodule
