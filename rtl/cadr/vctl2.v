// TK	CADR	VMA/MD CONTROL

module VCTL2(loadmd, nopa, ir, wrcyc, destmdr, srcmd, destmem, srcmap, irdisp, memprepare, memstart, destvma, ifetch, state_decode, state_write, state_read, state_mmu, vm0wp, vm1wp, wmap, memwr, memrd, vma, dmapbenb, dispwr, vm0rp, vm1rp, vmaenb, vmasel, memdrive, mdsel);

   input state_decode;
   input state_mmu;
   input state_read;
   input state_write;

   input [31:0] vma;
   input [48:0] ir;
   input	destmdr;
   input	destmem;
   input	destvma;
   input	dispwr;
   input	dmapbenb;
   input	ifetch;
   input	irdisp;
   input	loadmd;
   input	memprepare;
   input	memstart;
   input	nopa;
   input	srcmap;
   input	srcmd;
   input	wrcyc;
   output	mdsel;
   output	memdrive;
   output	memrd;
   output	memwr;
   output	vm0rp;
   output	vm0wp;
   output	vm1rp;
   output	vm1wp;
   output	vmaenb;
   output	vmasel;
   output	wmap;

   ////////////////////////////////////////////////////////////////////////////////

   wire		early_vm0_rd;
   wire		early_vm1_rd;
   wire		normal_vm0_rd;
   wire		normal_vm1_rd;
   wire		use_md;

   /*
    * for memory cycle, we run mmu state and map vma during state_write & state_mmu
    * for dispatch,     we don't run mmy state and map md early
    *                   so dispatch ram has a chance to read and register during write state
    *
    * dispatch ram output has to be valid during fetch cycle to get npc correct
    */

   assign mapwr0 = wmap & vma[26];
   assign mapwr1 = wmap & vma[25];

   // for dispatch, no alu needed, so read early and skip mmu state
   // for byte,     no alu needed, so read early
   // for alu,      no alu needed, so read early
   assign early_vm0_rd  = (irdisp && dmapbenb) | srcmap;
   assign early_vm1_rd  = (irdisp && dmapbenb) | srcmap;

   assign normal_vm0_rd = wmap;
   assign normal_vm1_rd = 1'b0;

   assign vm0rp = (state_decode && early_vm0_rd) |
		  (state_write  && normal_vm0_rd) |
		  (state_write  && memprepare);

   assign vm1rp = (state_read && early_vm1_rd) |
		  (state_mmu  && normal_vm1_rd) |
		  (state_mmu  && memstart);

   assign vm0wp = mapwr0 & state_write;
   assign vm1wp = mapwr1 & state_mmu;

   assign vmaenb = destvma | ifetch;
   assign vmasel = ~ifetch;

   // external?
   assign lm_drive_enb = 0;

   assign memdrive = wrcyc & lm_drive_enb;

   assign mdsel = destmdr & ~loadmd/*& ~state_write*/;

   assign use_md  = srcmd & ~nopa;

   assign {wmap,memwr,memrd} =
			      ~destmem ? 3'b000 :
			      (ir[20:19] == 2'b01) ? 3'b001 :
			      (ir[20:19] == 2'b10) ? 3'b010 :
			      (ir[20:19] == 2'b11) ? 3'b100 :
			      3'b000 ;

endmodule
