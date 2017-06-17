// VMEMDR
//
// TK	CADR	MAP OUTPUT DRIVE

module VMEMDR(vmo, srcmap, state_alu, state_write, state_mmu, state_fetch, lvmo_23, lvmo_22, mapdrive, pma);

   input	state_alu;
   input	state_fetch;
   input	state_mmu;
   input	state_write;

   input [23:0] vmo;
   input	srcmap;
   output [21:8] pma;
   output	 lvmo_22;
   output	 lvmo_23;
   output	 mapdrive;

   ////////////////////////////////////////////////////////////////////////////////

   // output of vmem1 is registered
   assign lvmo_23 = vmo[23];
   assign lvmo_22 = vmo[22];
   assign pma = vmo[13:0];

   assign mapdrive = srcmap &
		     (state_alu || state_write || state_mmu || state_fetch);

endmodule
