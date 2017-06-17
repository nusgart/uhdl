// MF
//
// TK		CADR	DRIVE MF ONTO M

module MF(mfenb, mfdrive, srcm, spcenb, pdlenb, state_alu, state_write, state_mmu, state_fetch);

   input pdlenb;
   input spcenb;
   input srcm;
   input state_alu;
   input state_fetch;
   input state_mmu;
   input state_write;
   output mfdrive;
   output mfenb;

   ////////////////////////////////////////////////////////////////////////////////

   assign mfenb = ~srcm & !(spcenb | pdlenb);
   assign mfdrive = mfenb &
		    (state_alu || state_write || state_mmu || state_fetch);

endmodule
