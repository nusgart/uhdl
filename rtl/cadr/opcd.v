// OPCD --- OPC, DC, ZERO DRIVE

module OPCD(dcdrive, opcdrive, srcdc, srcopc, state_alu, state_write, state_mmu, state_fetch);

   input state_alu;
   input state_fetch;
   input state_mmu;
   input state_write;

   input srcdc;
   input srcopc;
   output dcdrive;
   output opcdrive;

   ////////////////////////////////////////////////////////////////////////////////

   assign dcdrive = srcdc & (state_alu || state_write || state_mmu || state_fetch);
   assign opcdrive = srcopc & (state_alu | state_write);

endmodule
