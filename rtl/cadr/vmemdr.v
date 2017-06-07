module VMEMDR(vmo, srcmap, state_alu, state_write, state_mmu, state_fetch, lvmo_23, lvmo_22, mapdrive, pma);

   input [23:0] vmo;
   input 	 srcmap;
   input 	 state_alu, state_write, state_mmu, state_fetch;
   output 	lvmo_23, lvmo_22, mapdrive;
   output [21:8] pma;
   
   // output of vmem1 is registered
   assign lvmo_23 = vmo[23];
   assign lvmo_22 = vmo[22];
   assign pma = vmo[13:0];

   assign mapdrive = srcmap &
		     (state_alu || state_write || state_mmu || state_fetch);

endmodule
