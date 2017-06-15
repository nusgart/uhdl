// MF
//
// TK		CADR	DRIVE MF ONTO M

module MF(mfdrive, srcm, spcenb, pdlenb, state_alu, state_write, state_mmu, state_fetch);

   input state_alu;
   input state_fetch;
   input state_mmu;
   input state_write;

   input pdlenb;
   input spcenb;
   input srcm;
   output mfdrive;

   ////////////////////////////////////////////////////////////////////////////////

   wire   mfenb;

   assign mfenb = ~srcm & !(spcenb | pdlenb);
   assign mfdrive = mfenb &
		    (state_alu || state_write || state_mmu || state_fetch);

endmodule
