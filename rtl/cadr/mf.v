module MF (mfenb, mfdrive, srcm, spcenb, pdlenb, state_alu, state_write, state_mmu, state_fetch);

   input srcm, spcenb, pdlenb, state_alu, state_write, state_mmu, state_fetch;
   output mfenb, mfdrive;

   assign mfenb = ~srcm & !(spcenb | pdlenb);
   assign mfdrive = mfenb &
		    (state_alu || state_write || state_mmu || state_fetch);

endmodule
