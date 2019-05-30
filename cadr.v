// cadr.v --- MIT CADR processor

`timescale 1ns/1ps
`default_nettype none

module cadr(/*AUTOARG*/
   // Outputs
   spy_out, mcr_addr, mcr_data_out, mcr_write, md, memrq, wrcyc, vma,
   pma,
   // Inputs
   clk, ext_int, ext_reset, ext_boot, ext_halt, spy_in, dbread,
   dbwrite, eadr, mcr_data_in, mcr_ready, mcr_done, bd_state,
   disk_state_in, loadmd, busint_bus, bus_int, memack,
   set_promdisable
   );

   input wire clk;
   input wire ext_int;
   input wire ext_reset;
   input wire ext_boot;
   input wire ext_halt;
   input [15:0] spy_in;
   output [15:0] spy_out;
   input wire dbread;
   input wire dbwrite;
   input [4:0] eadr;
   output [13:0] mcr_addr;
   output [48:0] mcr_data_out;
   input [48:0] mcr_data_in;
   input wire mcr_ready;
   output mcr_write;
   input wire mcr_done;
   output [31:0] md;
   output wire memrq;
   output wire wrcyc;
   output [31:0] vma;
   output [21:8] pma;
   input [11:0] bd_state;
   input [4:0] disk_state_in;
   input wire loadmd;
   input [31:0] busint_bus;
   input wire bus_int;
   input wire memack;
   input wire set_promdisable;
	///
	wire [11:0] bd_state_in;

   ////////////////////////////////////////////////////////////////////////////////

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		a;			// From cadr_alatch of ALATCH.v
   wire [9:0]		aadr;			// From cadr_actl of ACTL.v
   wire			aeqm;			// From cadr_alu of ALU.v
   wire [32:0]		alu;			// From cadr_alu of ALU.v
   wire [3:0]		aluf;			// From cadr_aluc4 of ALUC4.v
   wire			alumode;		// From cadr_aluc4 of ALUC4.v
   wire [31:0]		amem;			// From cadr_amem of AMEM.v
   wire			arp;			// From cadr_actl of ACTL.v
   wire			awp;			// From cadr_actl of ACTL.v
   wire			boot;			// From cadr_olord2 of OLORD2.v
   wire			boot_trap;		// From cadr_olord2 of OLORD2.v
   wire			cin0;			// From cadr_aluc4 of ALUC4.v
   wire			cin12_n;		// From cadr_aluc4 of ALUC4.v
   wire			cin16_n;		// From cadr_aluc4 of ALUC4.v
   wire			cin20_n;		// From cadr_aluc4 of ALUC4.v
   wire			cin24_n;		// From cadr_aluc4 of ALUC4.v
   wire			cin28_n;		// From cadr_aluc4 of ALUC4.v
   wire			cin32_n;		// From cadr_aluc4 of ALUC4.v
   wire			cin4_n;			// From cadr_aluc4 of ALUC4.v
   wire			cin8_n;			// From cadr_aluc4 of ALUC4.v
   wire [9:0]		dc;			// From cadr_dspctl of DSPCTL.v
   wire			dcdrive;		// From cadr_opcd of OPCD.v
   wire			dest;			// From cadr_source of SOURCE.v
   wire			destimod0;		// From cadr_source of SOURCE.v
   wire			destimod1;		// From cadr_source of SOURCE.v
   wire			destintctl;		// From cadr_source of SOURCE.v
   wire			destlc;			// From cadr_source of SOURCE.v
   wire			destm;			// From cadr_source of SOURCE.v
   wire			destmdr;		// From cadr_source of SOURCE.v
   wire			destmem;		// From cadr_source of SOURCE.v
   wire			destpdl_p;		// From cadr_source of SOURCE.v
   wire			destpdl_x;		// From cadr_source of SOURCE.v
   wire			destpdlp;		// From cadr_source of SOURCE.v
   wire			destpdltop;		// From cadr_source of SOURCE.v
   wire			destpdlx;		// From cadr_source of SOURCE.v
   wire			destspc;		// From cadr_source of SOURCE.v
   wire			destvma;		// From cadr_source of SOURCE.v
   wire			dispwr;			// From cadr_dspctl of DSPCTL.v
   wire			div;			// From cadr_source of SOURCE.v
   wire			dmapbenb;		// From cadr_dspctl of DSPCTL.v
   wire [6:0]		dmask;			// From cadr_dspctl of DSPCTL.v
   wire			dn;			// From cadr_dram of DRAM.v
   wire			dp;			// From cadr_dram of DRAM.v
   wire [13:0]		dpc;			// From cadr_dram of DRAM.v
   wire			dr;			// From cadr_dram of DRAM.v
   wire			err;			// From cadr_olord2 of OLORD2.v
   wire			errhalt;		// From cadr_olord2 of OLORD2.v
   wire			errstop;		// From cadr_olord1 of OLORD1.v
   wire [3:0]		funct;			// From cadr_source of SOURCE.v
   wire [48:0]		i;			// From cadr_debug of DEBUG.v
   wire			idebug;			// From cadr_olord1 of OLORD1.v
   wire			ifetch;			// From cadr_lcc of LCC.v
   wire			imod;			// From cadr_source of SOURCE.v
   wire			int_enable;		// From cadr_flag of FLAG.v
   wire [47:0]		iob;			// From cadr_ior of IOR.v
   wire [13:0]		ipc;			// From cadr_npc of NPC.v
   wire [48:0]		iprom;			// From cadr_prom of PROM.v
   wire [48:0]		ir;			// From cadr_ireg of IREG.v
   wire			iralu;			// From cadr_source of SOURCE.v
   wire [48:0]		iram;			// From cadr_iram of IRAM.v
   wire			irbyte;			// From cadr_source of SOURCE.v
   wire			irdisp;			// From cadr_source of SOURCE.v
   wire			irjump;			// From cadr_source of SOURCE.v
   wire			iwe;			// From cadr_ictl of ICTL.v
   wire [48:0]		iwr;			// From cadr_iwr of IWR.v
   wire			iwrited;		// From cadr_contrl of CONTRL.v
   wire			jcond;			// From cadr_flag of FLAG.v
   wire [31:0]		l;			// From cadr_l of L.v
   wire [25:0]		lc;			// From cadr_lc of LC.v
   wire			lc0b;			// From cadr_lcc of LCC.v
   wire			lc_byte_mode;		// From cadr_flag of FLAG.v
   wire [3:0]		lca;			// From cadr_lc of LC.v
   wire			lcinc;			// From cadr_lcc of LCC.v
   wire			ldclk;			// From cadr_spy0 of SPY0.v
   wire			lddbirh;		// From cadr_spy0 of SPY0.v
   wire			lddbirl;		// From cadr_spy0 of SPY0.v
   wire			lddbirm;		// From cadr_spy0 of SPY0.v
   wire			ldmdh;			// From cadr_spy0 of SPY0.v
   wire			ldmdl;			// From cadr_spy0 of SPY0.v
   wire			ldmode;			// From cadr_spy0 of SPY0.v
   wire			ldopc;			// From cadr_spy0 of SPY0.v
   wire			ldscratch1;		// From cadr_spy0 of SPY0.v
   wire			ldscratch2;		// From cadr_spy0 of SPY0.v
   wire			ldvmah;			// From cadr_spy0 of SPY0.v
   wire			ldvmal;			// From cadr_spy0 of SPY0.v
   wire			lpc_hold;		// From cadr_olord1 of OLORD1.v
   wire			lvmo_22;		// From cadr_vmemdr of VMEMDR.v
   wire			lvmo_23;		// From cadr_vmemdr of VMEMDR.v
   wire [31:0]		m;			// From cadr_mlatch of MLATCH.v
   wire			machrun;		// From cadr_olord1 of OLORD1.v
   wire [4:0]		madr;			// From cadr_mctl of MCTL.v
   wire			mapdrive;		// From cadr_vmemdr of VMEMDR.v
   wire [23:8]		mapi;			// From cadr_vmas of VMAS.v
   wire			mddrive;		// From cadr_md of MD.v
   wire			mdgetspar;		// From cadr_md of MD.v
   wire [31:0]		mds;			// From cadr_mds of MDS.v
   wire			mdsel;			// From cadr_vctl2 of VCTL2.v
   wire			memdrive;		// From cadr_vctl2 of VCTL2.v
   wire			memprepare;		// From cadr_vctl1 of VCTL1.v
   wire			memrd;			// From cadr_vctl2 of VCTL2.v
   wire			memstart;		// From cadr_vctl1 of VCTL1.v
   wire			memwr;			// From cadr_vctl2 of VCTL2.v
   wire [31:0]		mf;			// From cadr_lc of LC.v
   wire			mfdrive;		// From cadr_mf of MF.v
   wire [31:0]		mmem;			// From cadr_mmem of MMEM.v
   wire			mpassm;			// From cadr_mctl of MCTL.v
   wire			mrp;			// From cadr_mctl of MCTL.v
   wire [31:0]		msk;			// From cadr_mskg4 of MSKG4.v
   wire [4:0]		mskl;			// From cadr_smctl of SMCTL.v
   wire [4:0]		mskr;			// From cadr_smctl of SMCTL.v
   wire			mul;			// From cadr_source of SOURCE.v
   wire			mwp;			// From cadr_mctl of MCTL.v
   wire			n;			// From cadr_contrl of CONTRL.v
   wire			needfetch;		// From cadr_lcc of LCC.v
   wire			nop;			// From cadr_contrl of CONTRL.v
   wire			nop11;			// From cadr_olord1 of OLORD1.v
   wire			nopa;			// From cadr_contrl of CONTRL.v
   wire [31:0]		ob;			// From cadr_mo of MO.v
   wire [13:0]		opc;			// From cadr_opcs of OPCS.v
   wire			opcclk;			// From cadr_olord1 of OLORD1.v
   wire			opcdrive;		// From cadr_opcd of OPCD.v
   wire			opcinh;			// From cadr_olord1 of OLORD1.v
   wire [1:0]		osel;			// From cadr_aluc4 of ALUC4.v
   wire [13:0]		pc;			// From cadr_npc of NPC.v
   wire			pcs0;			// From cadr_contrl of CONTRL.v
   wire			pcs1;			// From cadr_contrl of CONTRL.v
   wire [31:0]		pdl;			// From cadr_platch of PLATCH.v
   wire [9:0]		pdla;			// From cadr_pdlctl of PDLCTL.v
   wire			pdlcnt;			// From cadr_pdlctl of PDLCTL.v
   wire			pdldrive;		// From cadr_pdlctl of PDLCTL.v
   wire			pdlenb;			// From cadr_pdlctl of PDLCTL.v
   wire [9:0]		pdlidx;			// From cadr_pdlptr of PDLPTR.v
   wire [31:0]		pdlo;			// From cadr_pdl of PDL.v
   wire [9:0]		pdlptr;			// From cadr_pdlptr of PDLPTR.v
   wire			pdlwrite;		// From cadr_pdlctl of PDLCTL.v
   wire			pfr;			// From cadr_vctl1 of VCTL1.v
   wire			pfw;			// From cadr_vctl1 of VCTL1.v
   wire			pidrive;		// From cadr_pdlptr of PDLPTR.v
   wire			ppdrive;		// From cadr_pdlptr of PDLPTR.v
   wire			prog_unibus_reset;	// From cadr_flag of FLAG.v
   wire [8:0]		promaddr;		// From cadr_pctl of PCTL.v
   wire			promdisable;		// From cadr_olord1 of OLORD1.v
   wire			promdisabled;		// From cadr_olord1 of OLORD1.v
   wire			promenable;		// From cadr_pctl of PCTL.v
   wire			prp;			// From cadr_pdlctl of PDLCTL.v
   wire			pwp;			// From cadr_pdlctl of PDLCTL.v
   wire [31:0]		q;			// From cadr_q of Q.v
   wire			qdrive;			// From cadr_qctl of QCTL.v
   wire			qs0;			// From cadr_qctl of QCTL.v
   wire			qs1;			// From cadr_qctl of QCTL.v
   wire [31:0]		r;			// From cadr_shift of SHIFT.v
   wire			reset;			// From cadr_olord2 of OLORD2.v
   wire			s0;			// From cadr_smctl of SMCTL.v
   wire			s1;			// From cadr_smctl of SMCTL.v
   wire			s2;			// From cadr_smctl of SMCTL.v
   wire			s3;			// From cadr_smctl of SMCTL.v
   wire			s4;			// From cadr_smctl of SMCTL.v
   wire [15:0]		scratch;		// From cadr_olord1 of OLORD1.v
   wire			sequence_break;		// From cadr_flag of FLAG.v
   wire			sh3;			// From cadr_lcc of LCC.v
   wire			sh4;			// From cadr_lcc of LCC.v
   wire			sintr;			// From cadr_lcc of LCC.v
   wire [18:0]		spc;			// From cadr_spclch of SPCLCH.v
   wire			spc1a;			// From cadr_lcc of LCC.v
   wire			spcdrive;		// From cadr_contrl of CONTRL.v
   wire			spcenb;			// From cadr_contrl of CONTRL.v
   wire			spcnt;			// From cadr_contrl of CONTRL.v
   wire [18:0]		spco;			// From cadr_spc of SPC.v
   wire [4:0]		spcptr;			// From cadr_spc of SPC.v
   wire [18:0]		spcw;			// From cadr_spcw of SPCW.v
   wire			spop;			// From cadr_contrl of CONTRL.v
   wire			spush;			// From cadr_contrl of CONTRL.v
   wire			spy_ah;			// From cadr_spy0 of SPY0.v
   wire			spy_al;			// From cadr_spy0 of SPY0.v
   wire			spy_bd;			// From cadr_spy0 of SPY0.v
   wire			spy_disk;		// From cadr_spy0 of SPY0.v
   wire			spy_flag1;		// From cadr_spy0 of SPY0.v
   wire			spy_flag2;		// From cadr_spy0 of SPY0.v
   wire			spy_irh;		// From cadr_spy0 of SPY0.v
   wire			spy_irl;		// From cadr_spy0 of SPY0.v
   wire			spy_irm;		// From cadr_spy0 of SPY0.v
   wire			spy_mdh;		// From cadr_spy0 of SPY0.v
   wire			spy_mdl;		// From cadr_spy0 of SPY0.v
   wire			spy_mh;			// From cadr_spy0 of SPY0.v
   wire			spy_ml;			// From cadr_spy0 of SPY0.v
   wire			spy_obh;		// From cadr_spy0 of SPY0.v
   wire			spy_obh_;		// From cadr_spy0 of SPY0.v
   wire			spy_obl;		// From cadr_spy0 of SPY0.v
   wire			spy_obl_;		// From cadr_spy0 of SPY0.v
   wire			spy_opc;		// From cadr_spy0 of SPY0.v
   wire			spy_pc;			// From cadr_spy0 of SPY0.v
   wire			spy_scratch;		// From cadr_spy0 of SPY0.v
   wire			spy_sth;		// From cadr_spy0 of SPY0.v
   wire			spy_stl;		// From cadr_spy0 of SPY0.v
   wire			spy_vmah;		// From cadr_spy0 of SPY0.v
   wire			spy_vmal;		// From cadr_spy0 of SPY0.v
   wire			srcdc;			// From cadr_source of SOURCE.v
   wire			srclc;			// From cadr_source of SOURCE.v
   wire			srcm;			// From cadr_mctl of MCTL.v
   wire			srcmap;			// From cadr_source of SOURCE.v
   wire			srcmd;			// From cadr_source of SOURCE.v
   wire			srcopc;			// From cadr_source of SOURCE.v
   wire			srcpdlidx;		// From cadr_source of SOURCE.v
   wire			srcpdlpop;		// From cadr_source of SOURCE.v
   wire			srcpdlptr;		// From cadr_source of SOURCE.v
   wire			srcpdltop;		// From cadr_source of SOURCE.v
   wire			srcq;			// From cadr_source of SOURCE.v
   wire			srcspc;			// From cadr_source of SOURCE.v
   wire			srcspcpop;		// From cadr_source of SOURCE.v
   wire			srcspcpopreal;		// From cadr_contrl of CONTRL.v
   wire			srcvma;			// From cadr_source of SOURCE.v
   wire			srp;			// From cadr_contrl of CONTRL.v
   wire			srun;			// From cadr_olord1 of OLORD1.v
   wire			ssdone;			// From cadr_olord1 of OLORD1.v
   wire			stat_ovf;		// From cadr_olord1 of OLORD1.v
   wire			stathalt;		// From cadr_olord1 of OLORD1.v
   wire			statstop;		// From cadr_olord2 of OLORD2.v
   wire			swp;			// From cadr_contrl of CONTRL.v
   wire			trap;			// From cadr_trap of TRAP.v
   wire			vm0rp;			// From cadr_vctl2 of VCTL2.v
   wire			vm0wp;			// From cadr_vctl2 of VCTL2.v
   wire			vm1rp;			// From cadr_vctl2 of VCTL2.v
   wire			vm1wp;			// From cadr_vctl2 of VCTL2.v
   wire			vmadrive;		// From cadr_vma of VMA.v
   wire			vmaenb;			// From cadr_vctl2 of VCTL2.v
   wire			vmaok;			// From cadr_vctl1 of VCTL1.v
   wire [4:0]		vmap;			// From cadr_vmem0 of VMEM0.v
   wire [31:0]		vmas;			// From cadr_vmas of VMAS.v
   wire			vmasel;			// From cadr_vctl2 of VCTL2.v
   wire [23:0]		vmo;			// From cadr_vmem1 of VMEM1.v
   wire [9:0]		wadr;			// From cadr_actl of ACTL.v
   wire			waiting;		// From cadr_vctl1 of VCTL1.v
   wire			wmap;			// From cadr_vctl2 of VCTL2.v
   wire [13:0]		wpc;			// From cadr_lpc of LPC.v
   wire			xout11;			// From cadr_alu of ALU.v
   wire			xout15;			// From cadr_alu of ALU.v
   wire			xout19;			// From cadr_alu of ALU.v
   wire			xout23;			// From cadr_alu of ALU.v
   wire			xout27;			// From cadr_alu of ALU.v
   wire			xout3;			// From cadr_alu of ALU.v
   wire			xout31;			// From cadr_alu of ALU.v
   wire			xout7;			// From cadr_alu of ALU.v
   wire			yout11;			// From cadr_alu of ALU.v
   wire			yout15;			// From cadr_alu of ALU.v
   wire			yout19;			// From cadr_alu of ALU.v
   wire			yout23;			// From cadr_alu of ALU.v
   wire			yout27;			// From cadr_alu of ALU.v
   wire			yout3;			// From cadr_alu of ALU.v
   wire			yout31;			// From cadr_alu of ALU.v
   wire			yout7;			// From cadr_alu of ALU.v
   // End of automatics
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [13:0]		mcr_addr;
   reg [48:0]		mcr_data_out;
   reg			mcr_write;
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   parameter [5:0]
     STATE_RESET = 6'b000000,
     STATE_DECODE = 6'b000001,
     STATE_READ = 6'b000010,
     STATE_ALU = 6'b000100,
     STATE_WRITE = 6'b001000,
     STATE_MMU = 6'b010000,
     STATE_FETCH = 6'b100000;

   reg [5:0] state;

   wire [5:0] next_state;
   wire state_decode;
   wire state_read;
   wire state_alu;
   wire state_write;
   wire state_fetch;
   wire state_mmu;
   wire state_prefetch;
   wire need_mmu_state;
   wire mcr_hold;

   always @(posedge clk)
     if (reset)
       state <= STATE_RESET;
     else
       state <= next_state;

   assign need_mmu_state = memprepare | wmap | srcmap;
   assign mcr_hold = 0;
   assign next_state =
		      state == STATE_RESET ? STATE_DECODE :
		      (state == STATE_DECODE && machrun) ? STATE_READ :
		      (state == STATE_DECODE && ~machrun) ? STATE_DECODE :
		      state == STATE_READ ? STATE_ALU :
		      state == STATE_ALU ? STATE_WRITE :
		      (state == STATE_WRITE && need_mmu_state) ? STATE_MMU :
		      (state == STATE_WRITE && ~need_mmu_state) ? STATE_FETCH :
		      state == STATE_MMU ? STATE_FETCH :
		      (state == STATE_FETCH && mcr_hold) ? STATE_FETCH :
		      STATE_DECODE;
   assign state_decode = state[0];
   assign state_read = state[1];
   assign state_alu = state[2];
   assign state_write = state[3];
   assign state_mmu = state[4];
   assign state_prefetch = state[5] & mcr_hold;
   assign state_fetch = state[5] & ~mcr_hold;

   ////////////////////////////////////////////////////////////////////////////////
   // CADR4

   ACTL cadr_actl(/*AUTOINST*/
		  // Outputs
		  .aadr			(aadr[9:0]),
		  .wadr			(wadr[9:0]),
		  .arp			(arp),
		  .awp			(awp),
		  // Inputs
		  .clk			(clk),
		  .reset		(reset),
		  .state_decode		(state_decode),
		  .state_write		(state_write),
		  .ir			(ir[48:0]),
		  .dest			(dest),
		  .destm		(destm));
   ALATCH cadr_alatch(/*AUTOINST*/
		      // Outputs
		      .a		(a[31:0]),
		      // Inputs
		      .amem		(amem[31:0]));
   ALU cadr_alu(/*AUTOINST*/
		// Outputs
		.alu			(alu[32:0]),
		.aeqm			(aeqm),
		.xout3			(xout3),
		.xout7			(xout7),
		.xout11			(xout11),
		.xout15			(xout15),
		.xout19			(xout19),
		.xout23			(xout23),
		.xout27			(xout27),
		.xout31			(xout31),
		.yout3			(yout3),
		.yout7			(yout7),
		.yout11			(yout11),
		.yout15			(yout15),
		.yout19			(yout19),
		.yout23			(yout23),
		.yout27			(yout27),
		.yout31			(yout31),
		// Inputs
		.aluf			(aluf[3:0]),
		.alumode		(alumode),
		.a			(a[31:0]),
		.m			(m[31:0]),
		.cin0			(cin0),
		.cin4_n			(cin4_n),
		.cin8_n			(cin8_n),
		.cin12_n		(cin12_n),
		.cin16_n		(cin16_n),
		.cin20_n		(cin20_n),
		.cin24_n		(cin24_n),
		.cin28_n		(cin28_n),
		.cin32_n		(cin32_n));
   ALUC4 cadr_aluc4(/*AUTOINST*/
		    // Outputs
		    .osel		(osel[1:0]),
		    .aluf		(aluf[3:0]),
		    .alumode		(alumode),
		    .cin0		(cin0),
		    .cin4_n		(cin4_n),
		    .cin8_n		(cin8_n),
		    .cin12_n		(cin12_n),
		    .cin16_n		(cin16_n),
		    .cin20_n		(cin20_n),
		    .cin24_n		(cin24_n),
		    .cin28_n		(cin28_n),
		    .cin32_n		(cin32_n),
		    // Inputs
		    .a			(a[31:0]),
		    .q			(q[31:0]),
		    .ir			(ir[48:0]),
		    .iralu		(iralu),
		    .irjump		(irjump),
		    .div		(div),
		    .mul		(mul),
		    .xout3		(xout3),
		    .xout7		(xout7),
		    .xout11		(xout11),
		    .xout15		(xout15),
		    .xout19		(xout19),
		    .xout23		(xout23),
		    .xout27		(xout27),
		    .xout31		(xout31),
		    .yout3		(yout3),
		    .yout7		(yout7),
		    .yout11		(yout11),
		    .yout15		(yout15),
		    .yout19		(yout19),
		    .yout23		(yout23),
		    .yout27		(yout27),
		    .yout31		(yout31));
   AMEM cadr_amem(/*AUTOINST*/
		  // Outputs
		  .amem			(amem[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset		(reset),
		  .l			(l[31:0]),
		  .aadr			(aadr[9:0]),
		  .arp			(arp),
		  .awp			(awp));
   CONTRL cadr_contrl(/*AUTOINST*/
		      // Outputs
		      .iwrited		(iwrited),
		      .n		(n),
		      .nop		(nop),
		      .nopa		(nopa),
		      .pcs0		(pcs0),
		      .pcs1		(pcs1),
		      .spcdrive		(spcdrive),
		      .spcenb		(spcenb),
		      .spcnt		(spcnt),
		      .spop		(spop),
		      .spush		(spush),
		      .srcspcpopreal	(srcspcpopreal),
		      .srp		(srp),
		      .swp		(swp),
		      // Inputs
		      .clk		(clk),
		      .reset		(reset),
		      .state_alu	(state_alu),
		      .state_fetch	(state_fetch),
		      .state_write	(state_write),
		      .funct		(funct[3:0]),
		      .ir		(ir[48:0]),
		      .destspc		(destspc),
		      .dn		(dn),
		      .dp		(dp),
		      .dr		(dr),
		      .irdisp		(irdisp),
		      .irjump		(irjump),
		      .jcond		(jcond),
		      .nop11		(nop11),
		      .srcspc		(srcspc),
		      .srcspcpop	(srcspcpop),
		      .trap		(trap));
   DRAM cadr_dram(/*AUTOINST*/
		  // Outputs
		  .dpc			(dpc[13:0]),
		  .dn			(dn),
		  .dp			(dp),
		  .dr			(dr),
		  // Inputs
		  .clk			(clk),
		  .reset		(reset),
		  .state_prefetch	(state_prefetch),
		  .state_write		(state_write),
		  .vmo			(vmo[23:0]),
		  .a			(a[31:0]),
		  .r			(r[31:0]),
		  .ir			(ir[48:0]),
		  .dmask		(dmask[6:0]),
		  .dispwr		(dispwr));
   DSPCTL cadr_dspctl(/*AUTOINST*/
		      // Outputs
		      .dmask		(dmask[6:0]),
		      .dc		(dc[9:0]),
		      .dispwr		(dispwr),
		      .dmapbenb		(dmapbenb),
		      // Inputs
		      .clk		(clk),
		      .reset		(reset),
		      .state_fetch	(state_fetch),
		      .funct		(funct[3:0]),
		      .ir		(ir[48:0]),
		      .irdisp		(irdisp));
   FLAG cadr_flag(/*AUTOINST*/
		  // Outputs
		  .int_enable		(int_enable),
		  .jcond		(jcond),
		  .lc_byte_mode		(lc_byte_mode),
		  .prog_unibus_reset	(prog_unibus_reset),
		  .sequence_break	(sequence_break),
		  // Inputs
		  .clk			(clk),
		  .reset		(reset),
		  .state_fetch		(state_fetch),
		  .ob			(ob[31:0]),
		  .r			(r[31:0]),
		  .alu			(alu[32:0]),
		  .ir			(ir[48:0]),
		  .aeqm			(aeqm),
		  .destintctl		(destintctl),
		  .nopa			(nopa),
		  .sintr		(sintr),
		  .vmaok		(vmaok));
   IOR cadr_ior(/*AUTOINST*/
		// Outputs
		.iob			(iob[47:0]),
		// Inputs
		.ob			(ob[31:0]),
		.i			(i[48:0]));
   IREG cadr_ireg(/*AUTOINST*/
		  // Outputs
		  .ir			(ir[48:0]),
		  // Inputs
		  .clk			(clk),
		  .reset		(reset),
		  .state_fetch		(state_fetch),
		  .iob			(iob[47:0]),
		  .i			(i[48:0]),
		  .destimod0		(destimod0),
		  .destimod1		(destimod1));
   IWR cadr_iwr(/*AUTOINST*/
		// Outputs
		.iwr			(iwr[48:0]),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.state_fetch		(state_fetch),
		.a			(a[31:0]),
		.m			(m[31:0]));
   L cadr_l(/*AUTOINST*/
	    // Outputs
	    .l				(l[31:0]),
	    // Inputs
	    .clk			(clk),
	    .reset			(reset),
	    .state_alu			(state_alu),
	    .state_write		(state_write),
	    .ob				(ob[31:0]),
	    .vmaenb			(vmaenb));
   LC cadr_lc(/*AUTOINST*/
	      // Outputs
	      .lc			(lc[25:0]),
	      .mf			(mf[31:0]),
	      .lca			(lca[3:0]),
	      // Inputs
	      .clk			(clk),
	      .reset			(reset),
	      .state_alu		(state_alu),
	      .state_fetch		(state_fetch),
	      .state_mmu		(state_mmu),
	      .state_write		(state_write),
	      .opc			(opc[13:0]),
	      .vmo			(vmo[23:0]),
	      .md			(md[31:0]),
	      .ob			(ob[31:0]),
	      .q			(q[31:0]),
	      .vma			(vma[31:0]),
	      .vmap			(vmap[4:0]),
	      .dc			(dc[9:0]),
	      .pdlidx			(pdlidx[9:0]),
	      .pdlptr			(pdlptr[9:0]),
	      .dcdrive			(dcdrive),
	      .destlc			(destlc),
	      .int_enable		(int_enable),
	      .lc0b			(lc0b),
	      .lc_byte_mode		(lc_byte_mode),
	      .lcinc			(lcinc),
	      .mapdrive			(mapdrive),
	      .mddrive			(mddrive),
	      .needfetch		(needfetch),
	      .opcdrive			(opcdrive),
	      .pfr			(pfr),
	      .pfw			(pfw),
	      .pidrive			(pidrive),
	      .ppdrive			(ppdrive),
	      .prog_unibus_reset	(prog_unibus_reset),
	      .qdrive			(qdrive),
	      .sequence_break		(sequence_break),
	      .srclc			(srclc),
	      .vmadrive			(vmadrive));
   LCC cadr_lcc(/*AUTOINST*/
		// Outputs
		.ifetch			(ifetch),
		.lc0b			(lc0b),
		.lcinc			(lcinc),
		.needfetch		(needfetch),
		.sh3			(sh3),
		.sh4			(sh4),
		.sintr			(sintr),
		.spc1a			(spc1a),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.state_fetch		(state_fetch),
		.spc			(spc[18:0]),
		.lc			(lc[25:0]),
		.ir			(ir[48:0]),
		.bus_int		(bus_int),
		.destlc			(destlc),
		.ext_int		(ext_int),
		.irdisp			(irdisp),
		.lc_byte_mode		(lc_byte_mode),
		.spop			(spop),
		.srcspcpopreal		(srcspcpopreal));
   LPC cadr_lpc(/*AUTOINST*/
		// Outputs
		.wpc			(wpc[13:0]),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.state_fetch		(state_fetch),
		.lpc_hold		(lpc_hold),
		.pc			(pc[13:0]),
		.ir			(ir[48:0]),
		.irdisp			(irdisp));
   MCTL cadr_mctl(/*AUTOINST*/
		  // Outputs
		  .madr			(madr[4:0]),
		  .mpassm		(mpassm),
		  .mrp			(mrp),
		  .mwp			(mwp),
		  .srcm			(srcm),
		  // Inputs
		  .state_decode		(state_decode),
		  .state_write		(state_write),
		  .ir			(ir[48:0]),
		  .wadr			(wadr[9:0]),
		  .destm		(destm));
   MD cadr_md(/*AUTOINST*/
	      // Outputs
	      .md			(md[31:0]),
	      .mddrive			(mddrive),
	      .mdgetspar		(mdgetspar),
	      // Inputs
	      .clk			(clk),
	      .reset			(reset),
	      .state_alu		(state_alu),
	      .state_fetch		(state_fetch),
	      .state_mmu		(state_mmu),
	      .state_write		(state_write),
	      .spy_in			(spy_in[15:0]),
	      .mds			(mds[31:0]),
	      .destmdr			(destmdr),
	      .ldmdh			(ldmdh),
	      .ldmdl			(ldmdl),
	      .loadmd			(loadmd),
	      .memrq			(memrq),
	      .srcmd			(srcmd));
   MDS cadr_mds(/*AUTOINST*/
		// Outputs
		.mds			(mds[31:0]),
		// Inputs
		.busint_bus		(busint_bus[31:0]),
		.md			(md[31:0]),
		.ob			(ob[31:0]),
		.loadmd			(loadmd),
		.mdsel			(mdsel),
		.memdrive		(memdrive));
   MF cadr_mf(/*AUTOINST*/
	      // Outputs
	      .mfdrive			(mfdrive),
	      // Inputs
	      .state_alu		(state_alu),
	      .state_fetch		(state_fetch),
	      .state_mmu		(state_mmu),
	      .state_write		(state_write),
	      .pdlenb			(pdlenb),
	      .spcenb			(spcenb),
	      .srcm			(srcm));
   MLATCH cadr_mlatch(/*AUTOINST*/
		      // Outputs
		      .m		(m[31:0]),
		      // Inputs
		      .spco		(spco[18:0]),
		      .mf		(mf[31:0]),
		      .mmem		(mmem[31:0]),
		      .pdlo		(pdlo[31:0]),
		      .spcptr		(spcptr[4:0]),
		      .mfdrive		(mfdrive),
		      .mpassm		(mpassm),
		      .pdldrive		(pdldrive),
		      .spcdrive		(spcdrive));
   MMEM cadr_mmem(/*AUTOINST*/
		  // Outputs
		  .mmem			(mmem[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset		(reset),
		  .l			(l[31:0]),
		  .madr			(madr[4:0]),
		  .mrp			(mrp),
		  .mwp			(mwp));
   MO cadr_mo(/*AUTOINST*/
	      // Outputs
	      .ob			(ob[31:0]),
	      // Inputs
	      .osel			(osel[1:0]),
	      .a			(a[31:0]),
	      .msk			(msk[31:0]),
	      .q			(q[31:0]),
	      .r			(r[31:0]),
	      .alu			(alu[32:0]));
   MSKG4 cadr_mskg4(/*AUTOINST*/
		    // Outputs
		    .msk		(msk[31:0]),
		    // Inputs
		    .clk		(clk),
		    .mskl		(mskl[4:0]),
		    .mskr		(mskr[4:0]));
   NPC cadr_npc(/*AUTOINST*/
		// Outputs
		.ipc			(ipc[13:0]),
		.pc			(pc[13:0]),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.state_fetch		(state_fetch),
		.dpc			(dpc[13:0]),
		.spc			(spc[18:0]),
		.ir			(ir[48:0]),
		.pcs0			(pcs0),
		.pcs1			(pcs1),
		.spc1a			(spc1a),
		.trap			(trap));
   OPCD cadr_opcd(/*AUTOINST*/
		  // Outputs
		  .dcdrive		(dcdrive),
		  .opcdrive		(opcdrive),
		  // Inputs
		  .state_alu		(state_alu),
		  .state_fetch		(state_fetch),
		  .state_mmu		(state_mmu),
		  .state_write		(state_write),
		  .srcdc		(srcdc),
		  .srcopc		(srcopc));
   PDL cadr_pdl(/*AUTOINST*/
		// Outputs
		.pdlo			(pdlo[31:0]),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.l			(l[31:0]),
		.pdla			(pdla[9:0]),
		.prp			(prp),
		.pwp			(pwp));
   PLATCH cadr_platch(/*AUTOINST*/
		      // Outputs
		      .pdl		(pdl[31:0]),
		      // Inputs
		      .pdlo		(pdlo[31:0]));
   PDLCTL cadr_pdlctl(/*AUTOINST*/
		      // Outputs
		      .pdla		(pdla[9:0]),
		      .pdlcnt		(pdlcnt),
		      .pdldrive		(pdldrive),
		      .pdlenb		(pdlenb),
		      .pdlwrite		(pdlwrite),
		      .prp		(prp),
		      .pwp		(pwp),
		      // Inputs
		      .clk		(clk),
		      .reset		(reset),
		      .state_alu	(state_alu),
		      .state_fetch	(state_fetch),
		      .state_mmu	(state_mmu),
		      .state_read	(state_read),
		      .state_write	(state_write),
		      .ir		(ir[48:0]),
		      .pdlidx		(pdlidx[9:0]),
		      .pdlptr		(pdlptr[9:0]),
		      .destpdl_p	(destpdl_p),
		      .destpdl_x	(destpdl_x),
		      .destpdltop	(destpdltop),
		      .nop		(nop),
		      .srcpdlpop	(srcpdlpop),
		      .srcpdltop	(srcpdltop));
   PDLPTR cadr_pdlptr(/*AUTOINST*/
		      // Outputs
		      .pdlidx		(pdlidx[9:0]),
		      .pdlptr		(pdlptr[9:0]),
		      .pidrive		(pidrive),
		      .ppdrive		(ppdrive),
		      // Inputs
		      .clk		(clk),
		      .reset		(reset),
		      .state_alu	(state_alu),
		      .state_fetch	(state_fetch),
		      .state_read	(state_read),
		      .state_write	(state_write),
		      .ob		(ob[31:0]),
		      .destpdlp		(destpdlp),
		      .destpdlx		(destpdlx),
		      .pdlcnt		(pdlcnt),
		      .srcpdlidx	(srcpdlidx),
		      .srcpdlpop	(srcpdlpop),
		      .srcpdlptr	(srcpdlptr));
   QCTL cadr_qctl(/*AUTOINST*/
		  // Outputs
		  .qs0			(qs0),
		  .qs1			(qs1),
		  .qdrive		(qdrive),
		  // Inputs
		  .state_alu		(state_alu),
		  .state_write		(state_write),
		  .state_mmu		(state_mmu),
		  .state_fetch		(state_fetch),
		  .ir			(ir[48:0]),
		  .iralu		(iralu),
		  .srcq			(srcq));
   Q cadr_q(/*AUTOINST*/
	    // Outputs
	    .q				(q[31:0]),
	    // Inputs
	    .clk			(clk),
	    .reset			(reset),
	    .state_fetch		(state_fetch),
	    .qs0			(qs0),
	    .qs1			(qs1),
	    .alu			(alu[32:0]));
   SHIFT cadr_shift(/*AUTOINST*/
		    // Outputs
		    .r			(r[31:0]),
		    // Inputs
		    .m			(m[31:0]),
		    .s0			(s0),
		    .s1			(s1),
		    .s2			(s2),
		    .s3			(s3),
		    .s4			(s4));
   SMCTL cadr_smctl(/*AUTOINST*/
		    // Outputs
		    .mskl		(mskl[4:0]),
		    .mskr		(mskr[4:0]),
		    .s0			(s0),
		    .s1			(s1),
		    .s2			(s2),
		    .s3			(s3),
		    .s4			(s4),
		    // Inputs
		    .ir			(ir[48:0]),
		    .irbyte		(irbyte),
		    .sh3		(sh3),
		    .sh4		(sh4));
   SOURCE cadr_source(/*AUTOINST*/
		      // Outputs
		      .funct		(funct[3:0]),
		      .dest		(dest),
		      .div		(div),
		      .imod		(imod),
		      .iralu		(iralu),
		      .irbyte		(irbyte),
		      .irdisp		(irdisp),
		      .irjump		(irjump),
		      .mul		(mul),
		      .destlc		(destlc),
		      .destintctl	(destintctl),
		      .destpdltop	(destpdltop),
		      .destpdl_p	(destpdl_p),
		      .destpdl_x	(destpdl_x),
		      .destpdlx		(destpdlx),
		      .destpdlp		(destpdlp),
		      .destspc		(destspc),
		      .destimod0	(destimod0),
		      .destimod1	(destimod1),
		      .destvma		(destvma),
		      .destmdr		(destmdr),
		      .destmem		(destmem),
		      .destm		(destm),
		      .srcdc		(srcdc),
		      .srcspc		(srcspc),
		      .srcpdlptr	(srcpdlptr),
		      .srcpdlidx	(srcpdlidx),
		      .srcpdltop	(srcpdltop),
		      .srcopc		(srcopc),
		      .srcq		(srcq),
		      .srcvma		(srcvma),
		      .srcmap		(srcmap),
		      .srcmd		(srcmd),
		      .srclc		(srclc),
		      .srcspcpop	(srcspcpop),
		      .srcpdlpop	(srcpdlpop),
		      // Inputs
		      .ir		(ir[48:0]),
		      .idebug		(idebug),
		      .iwrited		(iwrited),
		      .nop		(nop));
   SPC cadr_spc(/*AUTOINST*/
		// Outputs
		.spco			(spco[18:0]),
		.spcptr			(spcptr[4:0]),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.state_fetch		(state_fetch),
		.spcw			(spcw[18:0]),
		.spcnt			(spcnt),
		.spush			(spush),
		.srp			(srp),
		.swp			(swp));
   SPCLCH cadr_spclch(/*AUTOINST*/
		      // Outputs
		      .spc		(spc[18:0]),
		      // Inputs
		      .spco		(spco[18:0]));
   SPCW cadr_spcw(/*AUTOINST*/
		  // Outputs
		  .spcw			(spcw[18:0]),
		  // Inputs
		  .ipc			(ipc[13:0]),
		  .wpc			(wpc[13:0]),
		  .l			(l[31:0]),
		  .destspc		(destspc),
		  .n			(n));
   SPY124 cadr_spy124(/*AUTOINST*/
		      // Outputs
		      .spy_out		(spy_out[15:0]),
		      // Inputs
		      .clk		(clk),
		      .reset		(reset),
		      .state_write	(state_write),
		      .bd_state_in	(bd_state_in[11:0]),
		      .opc		(opc[13:0]),
		      .pc		(pc[13:0]),
		      .scratch		(scratch[15:0]),
		      .a		(a[31:0]),
		      .m		(m[31:0]),
		      .md		(md[31:0]),
		      .ob		(ob[31:0]),
		      .vma		(vma[31:0]),
		      .ir		(ir[48:0]),
		      .disk_state_in	(disk_state_in[4:0]),
		      .boot		(boot),
		      .dbread		(dbread),
		      .destspc		(destspc),
		      .err		(err),
		      .imod		(imod),
		      .iwrited		(iwrited),
		      .jcond		(jcond),
		      .nop		(nop),
		      .pcs0		(pcs0),
		      .pcs1		(pcs1),
		      .pdlwrite		(pdlwrite),
		      .promdisable	(promdisable),
		      .spush		(spush),
		      .spy_ah		(spy_ah),
		      .spy_al		(spy_al),
		      .spy_bd		(spy_bd),
		      .spy_disk		(spy_disk),
		      .spy_flag1	(spy_flag1),
		      .spy_flag2	(spy_flag2),
		      .spy_irh		(spy_irh),
		      .spy_irl		(spy_irl),
		      .spy_irm		(spy_irm),
		      .spy_mdh		(spy_mdh),
		      .spy_mdl		(spy_mdl),
		      .spy_mh		(spy_mh),
		      .spy_ml		(spy_ml),
		      .spy_obh		(spy_obh),
		      .spy_obh_		(spy_obh_),
		      .spy_obl		(spy_obl),
		      .spy_obl_		(spy_obl_),
		      .spy_opc		(spy_opc),
		      .spy_pc		(spy_pc),
		      .spy_scratch	(spy_scratch),
		      .spy_sth		(spy_sth),
		      .spy_stl		(spy_stl),
		      .spy_vmah		(spy_vmah),
		      .spy_vmal		(spy_vmal),
		      .srun		(srun),
		      .ssdone		(ssdone),
		      .stathalt		(stathalt),
		      .vmaok		(vmaok),
		      .waiting		(waiting),
		      .wmap		(wmap));
   TRAP cadr_trap(/*AUTOINST*/
		  // Outputs
		  .trap			(trap),
		  // Inputs
		  .boot_trap		(boot_trap));
   VCTL1 cadr_vctl1(/*AUTOINST*/
		    // Outputs
		    .memprepare		(memprepare),
		    .memrq		(memrq),
		    .memstart		(memstart),
		    .pfr		(pfr),
		    .pfw		(pfw),
		    .vmaok		(vmaok),
		    .waiting		(waiting),
		    .wrcyc		(wrcyc),
		    // Inputs
		    .clk		(clk),
		    .reset		(reset),
		    .state_alu		(state_alu),
		    .state_fetch	(state_fetch),
		    .state_prefetch	(state_prefetch),
		    .state_write	(state_write),
		    .ifetch		(ifetch),
		    .lcinc		(lcinc),
		    .lvmo_22		(lvmo_22),
		    .lvmo_23		(lvmo_23),
		    .memack		(memack),
		    .memrd		(memrd),
		    .memwr		(memwr),
		    .needfetch		(needfetch));
   VCTL2 cadr_vctl2(/*AUTOINST*/
		    // Outputs
		    .mdsel		(mdsel),
		    .memdrive		(memdrive),
		    .memrd		(memrd),
		    .memwr		(memwr),
		    .vm0rp		(vm0rp),
		    .vm0wp		(vm0wp),
		    .vm1rp		(vm1rp),
		    .vm1wp		(vm1wp),
		    .vmaenb		(vmaenb),
		    .vmasel		(vmasel),
		    .wmap		(wmap),
		    // Inputs
		    .state_decode	(state_decode),
		    .state_mmu		(state_mmu),
		    .state_read		(state_read),
		    .state_write	(state_write),
		    .vma		(vma[31:0]),
		    .ir			(ir[48:0]),
		    .destmdr		(destmdr),
		    .destmem		(destmem),
		    .destvma		(destvma),
		    .dispwr		(dispwr),
		    .dmapbenb		(dmapbenb),
		    .ifetch		(ifetch),
		    .irdisp		(irdisp),
		    .loadmd		(loadmd),
		    .memprepare		(memprepare),
		    .memstart		(memstart),
		    .nopa		(nopa),
		    .srcmap		(srcmap),
		    .srcmd		(srcmd),
		    .wrcyc		(wrcyc));
   VMA cadr_vma(/*AUTOINST*/
		// Outputs
		.vma			(vma[31:0]),
		.vmadrive		(vmadrive),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.state_alu		(state_alu),
		.state_fetch		(state_fetch),
		.state_write		(state_write),
		.spy_in			(spy_in[15:0]),
		.vmas			(vmas[31:0]),
		.ldvmah			(ldvmah),
		.ldvmal			(ldvmal),
		.srcvma			(srcvma),
		.vmaenb			(vmaenb));
   VMAS cadr_vmas(/*AUTOINST*/
		  // Outputs
		  .mapi			(mapi[23:8]),
		  .vmas			(vmas[31:0]),
		  // Inputs
		  .lc			(lc[25:0]),
		  .md			(md[31:0]),
		  .ob			(ob[31:0]),
		  .vma			(vma[31:0]),
		  .memprepare		(memprepare),
		  .vmasel		(vmasel));
   VMEM0 cadr_vmem0(/*AUTOINST*/
		    // Outputs
		    .vmap		(vmap[4:0]),
		    // Inputs
		    .clk		(clk),
		    .reset		(reset),
		    .mapi		(mapi[23:8]),
		    .vma		(vma[31:0]),
		    .memstart		(memstart),
		    .srcmap		(srcmap),
		    .vm0rp		(vm0rp),
		    .vm0wp		(vm0wp));
   VMEM1 cadr_vmem1(/*AUTOINST*/
		    // Outputs
		    .vmo		(vmo[23:0]),
		    // Inputs
		    .clk		(clk),
		    .reset		(reset),
		    .mapi		(mapi[23:8]),
		    .vma		(vma[31:0]),
		    .vmap		(vmap[4:0]),
		    .vm1rp		(vm1rp),
		    .vm1wp		(vm1wp));
   VMEMDR cadr_vmemdr(/*AUTOINST*/
		      // Outputs
		      .pma		(pma[21:8]),
		      .lvmo_22		(lvmo_22),
		      .lvmo_23		(lvmo_23),
		      .mapdrive		(mapdrive),
		      // Inputs
		      .state_alu	(state_alu),
		      .state_fetch	(state_fetch),
		      .state_mmu	(state_mmu),
		      .state_write	(state_write),
		      .vmo		(vmo[23:0]),
		      .srcmap		(srcmap));

   ////////////////////////////////////////////////////////////////////////////////
     // IRAML

   DEBUG cadr_debug(/*AUTOINST*/
		    // Outputs
		    .i			(i[48:0]),
		    // Inputs
		    .clk		(clk),
		    .reset		(reset),
		    .spy_in		(spy_in[15:0]),
		    .iprom		(iprom[48:0]),
		    .iram		(iram[48:0]),
		    .idebug		(idebug),
		    .lddbirh		(lddbirh),
		    .lddbirl		(lddbirl),
		    .lddbirm		(lddbirm),
		    .promenable		(promenable));
   ICTL cadr_ictl(/*AUTOINST*/
		  // Outputs
		  .iwe			(iwe),
		  // Inputs
		  .state_write		(state_write),
		  .idebug		(idebug),
		  .iwrited		(iwrited),
		  .promdisabled		(promdisabled));
   OLORD1 cadr_olord1(/*AUTOINST*/
		      // Outputs
		      .scratch		(scratch[15:0]),
		      .errstop		(errstop),
		      .idebug		(idebug),
		      .lpc_hold		(lpc_hold),
		      .machrun		(machrun),
		      .nop11		(nop11),
		      .opcclk		(opcclk),
		      .opcinh		(opcinh),
		      .promdisable	(promdisable),
		      .promdisabled	(promdisabled),
		      .srun		(srun),
		      .ssdone		(ssdone),
		      .stat_ovf		(stat_ovf),
		      .stathalt		(stathalt),
		      // Inputs
		      .clk		(clk),
		      .reset		(reset),
		      .state_fetch	(state_fetch),
		      .spy_in		(spy_in[15:0]),
		      .boot		(boot),
		      .errhalt		(errhalt),
		      .ldclk		(ldclk),
		      .ldmode		(ldmode),
		      .ldopc		(ldopc),
		      .ldscratch1	(ldscratch1),
		      .ldscratch2	(ldscratch2),
		      .set_promdisable	(set_promdisable),
		      .statstop		(statstop),
		      .waiting		(waiting));
   OLORD2 cadr_olord2(/*AUTOINST*/
		      // Outputs
		      .boot		(boot),
		      .boot_trap	(boot_trap),
		      .err		(err),
		      .errhalt		(errhalt),
		      .reset		(reset),
		      .statstop		(statstop),
		      // Inputs
		      .clk		(clk),
		      .ext_reset	(ext_reset),
		      .spy_in		(spy_in[15:0]),
		      .errstop		(errstop),
		      .ext_boot		(ext_boot),
		      .ext_halt		(ext_halt),
		      .ldmode		(ldmode),
		      .srun		(srun),
		      .stat_ovf		(stat_ovf));
   OPCS cadr_opcs(/*AUTOINST*/
		  // Outputs
		  .opc			(opc[13:0]),
		  // Inputs
		  .clk			(clk),
		  .reset		(reset),
		  .state_fetch		(state_fetch),
		  .pc			(pc[13:0]),
		  .opcclk		(opcclk),
		  .opcinh		(opcinh));
   PCTL cadr_pctl(/*AUTOINST*/
		  // Outputs
		  .promaddr		(promaddr[8:0]),
		  .promenable		(promenable),
		  // Inputs
		  .pc			(pc[13:0]),
		  .idebug		(idebug),
		  .iwrited		(iwrited),
		  .promdisabled		(promdisabled));
   PROM cadr_prom(/*AUTOINST*/
		  // Outputs
		  .iprom		(iprom[48:0]),
		  // Inputs
		  .clk			(clk),
		  .promaddr		(promaddr[8:0]));
   IRAM cadr_iram(/*AUTOINST*/
		  // Outputs
		  .iram			(iram[48:0]),
		  // Inputs
		  .clk			(clk),
		  .reset		(reset),
		  .pc			(pc[13:0]),
		  .iwr			(iwr[48:0]),
		  .iwe			(iwe));
   SPY0 cadr_spy0(/*AUTOINST*/
		  // Outputs
		  .ldclk		(ldclk),
		  .lddbirh		(lddbirh),
		  .lddbirl		(lddbirl),
		  .lddbirm		(lddbirm),
		  .ldmdh		(ldmdh),
		  .ldmdl		(ldmdl),
		  .ldmode		(ldmode),
		  .ldopc		(ldopc),
		  .ldscratch1		(ldscratch1),
		  .ldscratch2		(ldscratch2),
		  .ldvmah		(ldvmah),
		  .ldvmal		(ldvmal),
		  .spy_ah		(spy_ah),
		  .spy_al		(spy_al),
		  .spy_bd		(spy_bd),
		  .spy_disk		(spy_disk),
		  .spy_flag1		(spy_flag1),
		  .spy_flag2		(spy_flag2),
		  .spy_irh		(spy_irh),
		  .spy_irl		(spy_irl),
		  .spy_irm		(spy_irm),
		  .spy_mdh		(spy_mdh),
		  .spy_mdl		(spy_mdl),
		  .spy_mh		(spy_mh),
		  .spy_ml		(spy_ml),
		  .spy_obh		(spy_obh),
		  .spy_obh_		(spy_obh_),
		  .spy_obl		(spy_obl),
		  .spy_obl_		(spy_obl_),
		  .spy_opc		(spy_opc),
		  .spy_pc		(spy_pc),
		  .spy_scratch		(spy_scratch),
		  .spy_sth		(spy_sth),
		  .spy_stl		(spy_stl),
		  .spy_vmah		(spy_vmah),
		  .spy_vmal		(spy_vmal),
		  // Inputs
		  .eadr			(eadr[4:0]),
		  .dbread		(dbread),
		  .dbwrite		(dbwrite));

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("." "CADR4" "CADR4/IRAML")
// End:
