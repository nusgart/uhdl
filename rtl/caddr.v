/*
 * caddr - synchronous cadr
 *
 * made rams dual port
 * added mmu cycle
 * cycle by cycle cosim with usim
 * 6/2011 brad parker brad@heeltoe.com
 *
 * lots of debugging on fpga
 * revamped bus interface
 * 10/2010 brad parker brad@heeltoe.com
 *
 * major cleanup:
 * 11/2009 brad parker brad@heeltoe.com
 *
 * sync version:
 * 4/2008 brad parker brad@heeltoe.com
 *
 * original version:
 * 10/2005 brad parker brad@heeltoe.com
 */

/*
 * The original set of clocks:
 *
 *   +++++++++++++++++++++++++++                    +--------
 *   |                         |                    |
 *   |                         |                    |  tpclk
 * --+                         +--------------------+
 *
 *                                    ++++++++
 *                                    |      |
 *                                    |      |         tpwp
 * -----------------------------------+      +---------------
 *
 *   ^                         ^
 *   |                         |
 *   |                      latch A&M memory output
 *  latch IR
 *
 * ===============================================================
 *
 * New states & clock:
 *
 *  ++++  ++++  ++++  ++++  ++++  ++++  ++++  ++++  ++++  ++++
 *  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
 * -+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--
 *
 *  +++++++
 *  |     |
 * -+     +---------------
 *   decode
 *        +++++++
 *        |     |
 * -------+     +---------------
 *         read
 *              +++++++
 *              |     |
 * -------------+     +---------------
 *               alu
 *                    +++++++
 *                    |     |
 * -------------------+     +---------------
 *                     write
 *                          +++++++
 *                          |     |
 * -------------------------+     +---------------
 *                           mmu (optional)
 *                                +++++++
 *                                |     |
 * -------------------------------+     +---------------
 *                                 fetch
 * boot
 * reset
 *
 * ===================================
 *
 * decode
 *      start a&m read
 *	wadr <- ir[]
 *	aadr = ir[41:32]
 *      madr = ir[30:26]
 *      early vmem0 read
 *
 * read
 *      amem & mmem valid by end of cycle
 *	74181 propagation
 *      pdl read (optional)
 *      early vmem1 read
 *
 * alu
 *	74181 propagation
 *
 * write
 *      a&m write
 *	normal vmem0 read
 *      spc read
 *      spc write (optional)
 *      pdl write (optional)
 *      dispatch write (optional)
 *
 * mmu
 *	normal vmem1 read (optional)
 *
 * fetch
 *	update pc
 *	ir <- i (or i|iob)
 *      update spcptr
 *      update pdlptr
 */

module caddr ( clk, ext_int, ext_reset, ext_boot, ext_halt,

	       spy_in, spy_out,
	       dbread, dbwrite, eadr,

	       pc_out, state_out, machrun_out,
	       prefetch_out, fetch_out,

	       mcr_addr, mcr_data_out, mcr_data_in,
	       mcr_ready, mcr_write, mcr_done,

	       set_promdisable,

	       bd_state_in,
	       disk_state_in,
	       pma, vma, md,
	       busint_bus,

	       memrq,
	       memack,
	       wrcyc,
	       loadmd,
	       bus_int
	       );

   input clk;
   input ext_int;
   input ext_reset;
   input ext_boot;
   input ext_halt;

   input [15:0] spy_in;
   output [15:0] spy_out;
   input	dbread;
   input	dbwrite;
   input [4:0]	eadr;

   output [13:0] pc_out;
   output [5:0]  state_out;
   output	 machrun_out;
   output	 prefetch_out;
   output	 fetch_out;

   output [13:0] mcr_addr;
   output [48:0] mcr_data_out;
   input [48:0]  mcr_data_in;
   input	 mcr_ready;
   output	 mcr_write;
   input	 mcr_done;

   input [11:0]  bd_state_in;
   input [4:0]	 disk_state_in;

   // ------------------------------------------------------------

   wire [13:0]	npc;
   wire [13:0]	dpc;
   wire [13:0]	ipc;
   wire [18:0]	spc;

   wire [48:0]	ir;

   wire [31:0]	a;
   wire [9:0]	aadr;
   wire		awp;
   wire		arp;

   wire [9:0]	wadr;

   wire [7:0]	aeqm_bits;
   wire		aeqm;
//   reg	aeqm;
   wire [32:0]	alu;

   wire		divposlasttime, divsubcond, divaddcond;
   wire		aluadd, alusub, mulnop;
   wire		mul, div, specalu;

   wire [1:0]	osel;

   wire [3:0]	aluf;
   wire		alumode;
   wire		cin0;

   wire [31:0]	amem;

   wire		dfall, dispenb, ignpopj, jfalse, jcalf, jretf, jret, iwrite;
   wire		ipopj, popj, srcspcpopreal;
   wire		spop, spush;

   wire		swp, srp, spcenb, spcdrive, spcnt;

   wire		inop, iwrited;
   wire		n, pcs1, pcs0;

   wire		nopa, nop;

   // page DRAM0-2
   wire [10:0]	dadr;
   wire		dr, dp, dn;
   wire		daddr0;
   wire [6:0]	dmask;
   wire		dwe;

   // page DSPCTL
   wire		dmapbenb, dispwr;
   wire [9:0]	dc;
   wire [11:0]	prompc;
   wire [8:0]	promaddr;

   // page FLAG
   wire		statbit, ilong, aluneg;
   wire		pgf_or_int, pgf_or_int_or_sb, sint;

   wire [2:0]	conds;
   wire		jcond;
   wire		lc_byte_mode, prog_unibus_reset, int_enable, sequence_break;

   // page IOR
   wire [47:0]	iob;
   wire [31:0]	ob;

   // page IPAR

   // page LC
   wire [25:0]	lc;
   wire [3:0]	lca;
   wire		lcry3;

   wire		lcdrive;
   wire		sh4, sh3;

   wire [31:0]	mf;

   wire		lc0b, next_instr, newlc_in;
   wire		have_wrong_word, last_byte_in_word;
   wire		needfetch, ifetch, spcmung, spc1a;
   wire		lcinc;

   wire		newlc, sintr, next_instrd;

   wire		lc_modifies_mrot;
   wire		inst_in_left_half;
   wire		inst_in_2nd_or_4th_quarter;

   wire [13:0]	wpc;

   // page MCTL
   wire		mpassm;
   wire		srcm;
   wire		mwp;
   wire		mrp;
   wire [4:0]	madr;

   // page MD
   output [31:0] md;
   wire [31:0]	md;
   wire		mddrive;	/* drive md on to mf bus */
   wire		mdclk;		/* enable - clock md in? */
   input		loadmd;		/* data available from busint */

   wire		mdhaspar, mdpar;
   wire		mdgetspar;

   wire		ignpar;

   // page MDS
   wire [31:0]	mds;
   wire [31:0]	mem;
   input [31:0]	busint_bus;
   input		bus_int;


   // page MF
   wire		mfenb;
   wire		mfdrive;

   // page MLATCH
   wire [31:0]	m;

   // page MMEM
   wire [31:0]	mmem;

   wire [31:0]	mo;

   wire [31:0]	msk_right_out, msk_left_out, msk;

   wire		dcdrive, opcdrive;

   // page PDL01
   wire [31:0]	pdl;

   // page PDLCTL
   wire [9:0]	pdla;
   wire		pdlp, pdlwrite;
   wire		pwp, prp, pdlenb, pdldrive, pdlcnt;
   wire		pwidx;

   // page PDLPTR
   wire		pidrive, ppdrive;
   wire [9:0]	pdlidx;

   // page Q
   wire [31:0]	q;
   wire		qs1, qs0, qdrive;

   // page SHIFT0-1
   wire [31:0]	sa;
   wire [31:0]	r;

   // page SMCTL
   wire		mr, sr;
   wire [4:0]	mskr;
   wire [4:0]	mskl;

   wire		s4, s3, s2, s1, s0;

   // page SOURCE
   wire		irbyte, irdisp, irjump, iralu;

   wire [3:0]	funct;

   wire		srcdc;		/* ir<30-26> m src = dispatch constant */
   wire		srcspc;		/* ir<30-26> m src = spc ptr */
   wire		srcpdlptr;	/* ir<30-26> m src = pdl ptr */
   wire		srcpdlidx;	/* ir<30-26> m src = pdl index */

   wire		srcopc;
   wire		srcq;
   wire		srcvma;		/* ir<30-26> m src = vma */
   wire		srcmap;		/* ir<30-26> m src = vm map[md] */
   wire		srcmd;		/* ir<30-26> m src = md */
   wire		srclc;		/* ir<30-26> m src = lc */

   wire		srcspcpop;	/* ir<30-26> m src = SPC , pop*/

   wire		srcpdlpop;	/* ir<30-26> m src = PDL buffer, ptr, pop */
   wire		srcpdltop;	/* ir<30-26> m src = PDL buffer, ptr */


   wire		imod;

   wire		dest;
   wire		destm;		/* fuctional destination */

   wire		destmem;	/* ir<25-14> dest VMA or MD */

   wire		destvma;	/* ir<25-14> dest VMA register */
   wire		destmdr;	/* ir<25-14> dest MD register */

   wire		destintctl;	/* ir<25-14> dest interrupt control */
   wire		destlc;		/* ir<25-14> dest lc */
   wire		destimod1;	/* ir<25-14> dest oa register <47-26> */
   wire		destimod0;	/* ir<25-14> dest oa register <25-0> */
   wire		destspc;	/* ir<25-14> dest spc data, push*/
   wire		destpdlp;	/* ir<25-14> dest pdl ptr */
   wire		destpdlx;	/* ir<25-14> dest pdl index */
   wire		destpdl_x;	/* ir<25-14> dest pdl (addressed by index)  */
   wire		destpdl_p;	/* ir<25-14> dest pdl (addressed by ptr), push*/
   wire		destpdltop;	/* ir<25-14> dest pdl (addressed by ptr) */


   // page SPC

   wire [4:0]	spcptr;

   wire [18:0]	spcw;
   wire [18:0]	spco;

   // page SPCPAR

   wire		trap;
   wire		boot_trap;


   // page _VCTL1

   wire		memop;
   wire		memprepare;
   wire		memstart;
   wire		memcheck;

   wire		rdcyc;
   wire		mbusy;

   output		memrq;
   wire		wrcyc;
   output wrcyc;

   wire		pfw;			/* vma permissions */
   wire		pfr;
   wire		vmaok;		/* vma access ok */

   wire		mfinish;

   input		memack;

   wire		waiting;

   // page VCTL2

   wire		mapwr0, mapwr1, vm0wp, vm1wp;
   wire		vm0rp, vm1rp;
   wire [10:0]	vmem0_adr;

   wire		vmaenb, vmasel;
   wire		memdrive, mdsel, use_md;
   wire		wmap, memwr, memrd;

   wire		lm_drive_enb;

   // page VMA

   output [31:0] vma;
   wire [31:0]	vma;
   wire		vmadrive;

   // page VMAS

   wire [31:0]	vmas;

   //       22221111111111
   // mapi  32109876543210
   //       1
   // vmem0 09876543210
   //
   wire [23:8]	mapi;

   wire [4:0]	vmap;

   // page VMEM0 - virtual memory map stage 0

   wire		use_map;

   wire [23:0]	vmo;

   wire		mapdrive;

   wire [48:0]	i;
   wire [48:0]	iprom;
   wire [48:0]	iram;
   wire [47:0]	spy_ir;

   wire		ramdisable;

   wire		opcinh, opcclk, lpc_hold;

   wire		ldstat, idebug, nop11, step;

   wire		run;

   wire		machrun, stat_ovf, stathalt;

   wire		prog_reset, reset;
   wire		err, errhalt;
   wire		bus_reset;
   wire		prog_boot, boot;

   wire		prog_bus_reset;

   wire		opcclka;

   // page VMEM1&2

   wire [9:0]	vmem1_adr;

   // page PCTL
   wire		promenable, promce, bottom_1k;

   // page OLORD1
   wire		promdisable;
   wire		trapenb;
   wire		stathenb;
   wire		errstop;

   wire		srun, sstep, ssdone, promdisabled;

   // page OLORD2

   wire		higherr;
   wire		statstop;
   wire		halted;

   // page L
   wire [31:0]	l;

   // page NPC
   wire [13:0]	pc;

   // page OPCS
   wire [13:0]	opc;

   // page PDLPTR
   wire [9:0]	pdlptr;

   // page SPCW
//   wire [13:0]		reta;
   wire [13:0]	reta;

   // page IWR
   wire [48:0]	iwr;

   wire [13:0]	lpc;

   wire		lvmo_23;
   wire		lvmo_22;
   output [21:8]	pma;


   // SPY 0

   wire   spy_obh, spy_obl, spy_pc, spy_opc,
	  spy_scratch, spy_irh, spy_irm, spy_irl;

   wire   spy_sth, spy_stl, spy_ah, spy_al,
	  spy_mh, spy_ml, spy_flag2, spy_flag1;

   wire   spy_mdh, spy_mdl, spy_vmah, spy_vmal, spy_obh_, spy_obl_;
   wire   spy_disk, spy_bd;

   wire   ldmode, ldopc, ldclk, lddbirh, lddbirm, lddbirl, ldscratch1, ldscratch2;
   wire   ldmdh, ldmdl, ldvmah, ldvmal;
   input   set_promdisable;

   wire [15:0] scratch;

`ifdef debug
   integer	  debug;
`endif

   // *******************************************************************

   // main cpu state machine

   parameter STATE_RESET    = 6'b000000,
	       STATE_DECODE = 6'b000001,
	       STATE_READ   = 6'b000010,
	       STATE_ALU    = 6'b000100,
	       STATE_WRITE  = 6'b001000,
	       STATE_MMU    = 6'b010000,
	       STATE_FETCH  = 6'b100000;

   reg [5:0] state;
   wire [5:0] next_state;
   wire       state_decode, state_read, state_alu, state_write, state_fetch;
   wire       state_mmu, state_prefetch;

   always @(posedge clk)
     if (reset)
       state <= STATE_RESET;
     else
       state <= next_state;

   wire       need_mmu_state;
   assign     need_mmu_state = memprepare | wmap | srcmap;

   wire       mcr_hold;
`define use_ucode_ram
`ifdef use_ucode_ram
   assign     mcr_hold = 0;
`else
   assign     mcr_hold = promdisabled && ~mcr_ready;
`endif

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

   ACTL(.clk, .reset, .state_decode, .state_write, .wadr, .destm, .awp, .arp, .aadr, .ir, .dest);

   ALATCH(.a, .amem);

   wire[2:0] nc_alu;
   wire      cin32_n, cin28_n, cin24_n, cin20_n;
   wire      cin16_n, cin12_n, cin8_n, cin4_n;

   wire      xx0, xx1;
   wire      yy0, yy1;

   wire      xout3, xout7, xout11, xout15, xout19, xout23, xout27, xout31;
   wire      yout3, yout7, yout11, yout15, yout19, yout23, yout27, yout31;

   ALU01(.a, .m, .aluf, .alumode, .aeqm, .alu, .cin12_n, .cin16_n, .cin20_n, .cin24_n, .cin28_n, .cin32_n, .cin4_n, .cin8_n, .cin0, .xout11, .xout15, .xout19, .xout23, .xout27, .xout3, .xout31, .xout7, .yout11, .yout15, .yout19, .yout23, .yout27, .yout3, .yout31, .yout7);

   ALUC4(.yout15, .yout11, .yout7, .yout3, .xout15, .xout11, .xout7, .xout3, .yout31, .yout27, .yout23, .yout19, .xout31, .xout27, .xout23, .xout19, .a, .ir, .iralu, .irjump, .mul, .div, .q, .osel, .aluf, .alumode, .cin12_n, .cin8_n, .cin4_n, .cin0, .cin28_n, .cin24_n, .cin20_n, .cin16_n, .cin32_n);

   AMEM01(.amem, .clk, .reset, .aadr, .awp, .arp, .l);

   CONTRL(.clk, .reset, .iwrited, .nopa, .pcs0, .pcs1, .spcdrive, .spcenb, .spcnt, .spop, .spush, .srcspcpopreal, .srp, .swp, .dr, .dp, .irdisp, .funct, .irjump, .ir, .srcspcpop, .jcond, .destspc, .state_write, .srcspc, .state_alu, .state_fetch, .trap, .dn, .nop11, .n, .nop);

   DRAM02(.clk, .reset, .a, .ir, .vmo, .dmask, .r, .dr, .dp, .dn, .dpc, .dispwr, .state_write, .state_prefetch);

   DSPCTL(.clk, .reset, .state_fetch, .irdisp, .funct, .ir, .dmask, .dmapbenb, .dispwr, .dc);

   FLAG(.clk, .reset, .ir, .nopa, .aeqm, .sintr, .int_enable, .vmaok, .sequence_break, .alu, .conds, .pgf_or_int, .pgf_or_int_or_sb, .sint, .lc_byte_mode, .prog_unibus_reset, .ob, .r, .state_fetch, .destintctl, .statbit, .ilong, .jcond);

   IOR(.iob, .i, .ob);

   IREG(.clk, .reset, .i, .iob, .ir, .state_fetch, .destimod1, .destimod0);

   IWR(.clk, .reset, .state_fetch, .iwr, .a, .m);

   L(.clk, .reset, .vmaenb, .state_write, .state_alu, .ob, .l);

   LC(.clk, .reset, .destlc, .lcry3, .lca, .lcinc, .lc_byte_mode, .lc, .srclc, .state_alu, .state_write, .state_mmu, .state_fetch, .ob, .lcdrive, .opcdrive, .opc, .dcdrive, .dc, .pdlptr, .pidrive, .pdlidx, .qdrive, .q, .mddrive, .md, .vmadrive, .vma, .mapdrive, .pfw, .needfetch, .int_enable, .prog_unibus_reset, .sequence_break, .lc0b, .ppdrive, .vmap, .pfr, .vmo, .mf);

   LCC(.clk, .reset, .state_fetch, .lc0b, .next_instr, .newlc_in, .have_wrong_word, .last_byte_in_word, .needfetch, .ifetch, .spcmung, .spc1a, .lc_modifies_mrot, .inst_in_left_half, .inst_in_2nd_or_4th_quarter, .sh4, .sh3, .newlc, .sintr, .next_instrd, .lc, .lc_byte_mode, .spop, .srcspcpopreal, .spc, .lcinc, .destlc, .irdisp, .ir, .ext_int, .bus_int);

   LPC(.clk, .reset, .lpc_hold, .pc, .wpc, .irdisp, .ir, .state_fetch);

   MCTL(.mpassm, .srcm, .mrp, .mwp, .madr, .ir, .destm, .wadr, .state_decode, .state_write);

   MD(.clk, .reset, .md, .mddrive, .spy_in, .loadmd, .memrq, .destmdr, .mds, .srcmd, .state_alu, .state_write, .state_mmu, .state_fetch, .ldmdh, .ldmdl);

   MDS(.mds, .mdsel, .ob, .memdrive, .loadmd, .busint_bus, .md);

   MF(.mfdrive, .srcm, .spcenb, .pdlenb, .state_alu, .state_write, .state_mmu, .state_fetch);

   MLATCH(.pdldrive, .spcdrive, .mfdrive, .mmem, .pdl, .spcptr, .spco, .mf, .m, .mpassm);

   MMEM(.clk, .reset, .mrp, .mwp, .madr, .l, .mmem);

   MO01(.msk, .r, .a, .alu, .q, .osel, .ob);

   MSKG4(.clk, .mskl, .mskr, .msk);

   NPC(.clk, .reset, .state_fetch, .ipc, .trap, .pcs1, .pcs0, .ir, .spc, .spc1a, .dpc, .pc);

   OPCD(.dcdrive, .opcdrive, .srcdc, .srcopc, .state_alu, .state_write, .state_mmu, .state_fetch);

   PDL01(.clk, .reset, .prp, .pdla, .l, .pwp, .pdl);

   PDLCTL(.clk, .reset, .pdlidx, .pdla, .pdlwrite, .state_alu, .state_write, .state_read, .ir, .pwp, .prp, .pdlenb, .pdldrive, .pdlcnt, .pdlptr, .destpdltop, .destpdl_x, .destpdl_p, .srcpdlpop, .state_mmu, .nop, .srcpdltop, .state_fetch);

   PDLPTR(.clk, .reset, .pidrive, .ppdrive, .pdlidx, .pdlptr, .state_alu, .state_write, .state_fetch, .state_read, .destpdlx, .srcpdlidx, .srcpdlptr, .ob, .destpdlp, .pdlcnt, .srcpdlpop);

   Q(.clk, .reset, .state_alu, .state_write, .state_mmu, .state_fetch, .alu, .srcq, .qdrive, .q, .ir, .iralu);

   SHIFT01(.r, .s0, .s1, .s2, .s3, .s4, .m);

   SMCTL(.mskr, .s0, .s1, .s2, .s3, .s4, .sh3, .sh4, .mskl, .irbyte, .ir);

   SOURCE(.ir, .iralu, .irbyte, .destimod0, .destimod1, .iwrited, .idebug, .nop, .irdisp, .irjump, .funct, .div, .mul, .srcq, .srcopc, .srcpdltop, .srcpdlpop, .srcpdlidx, .srcpdlptr, .srcspc, .srcdc, .srcspcpop, .srclc, .srcmd, .srcmap, .srcvma, .imod, .destmem, .destvma, .destmdr, .dest, .destm, .destintctl, .destlc, .destspc, .destpdlp, .destpdlx, .destpdl_x, .destpdl_p, .destpdltop);

   SPC(.clk, .reset, .spcnt, .state_fetch, .spush, .spcptr, .spco, .spcw, .srp, .swp);

   SPCLCH(.spc, .spco);

   SPCW(.destspc, .l, .spcw, .n, .wpc, .ipc);

   SPY124(.clk, .reset, .spy_out, .ir, .spy_mdh, .spy_mdl, .state_write, .spy_vmah, .spy_vmal, .spy_obh_, .spy_obl_, .md, .vma, .ob, .opc, .waiting, .boot, .promdisable, .stathalt, .dbread, .nop, .spy_obh, .spy_obl, .spy_pc, .spy_opc, .spy_scratch, .spy_irh, .spy_irm, .spy_irl, .spy_disk, .spy_bd, .pc, .err, .scratch, .spy_sth, .spy_stl, .spy_ah, .spy_al, .spy_mh, .spy_ml, .spy_flag2, .spy_flag1, .m, .a, .bd_state_in, .wmap, .ssdone, .vmaok, .destspc, .jcond, .srun, .pcs1, .pcs0, .iwrited, .imod, .pdlwrite, .spush, .disk_state_in);

   TRAP(.trap, .boot_trap);

   VCTL1(.clk, .reset, .lcinc, .memrq, .ifetch, .lvmo_22, .lvmo_23, .memack, .memprepare, .memrd, .memstart, .memwr, .needfetch, .pfr, .pfw, .state_alu, .state_fetch, .state_prefetch, .state_write, .vmaok, .wrcyc, .waiting);

   VCTL2(.loadmd, .nopa, .ir, .wrcyc, .destmdr, .srcmd, .destmem, .srcmap, .irdisp, .memprepare, .memstart, .destvma, .ifetch, .state_decode, .state_write, .state_read, .state_mmu, .mapwr0, .mapwr1, .vm0wp, .vm1wp, .wmap, .memwr, .memrd, .vma, .dmapbenb, .dispwr, .vm0rp, .vm1rp, .vmaenb, .vmasel, .memdrive, .mdsel, .use_md);

   VMA(.clk, .reset, .state_alu, .state_write, .state_fetch, .vmaenb, .vmas, .spy_in, .srcvma, .ldvmal, .ldvmah, .vma, .vmadrive);

   VMAS(.vmas, .mapi, .vmasel, .ob, .memprepare, .md, .vma, .lc);

   VMEM0(.clk, .reset, .mapi, .vmap, .vm0rp, .vma, .srcmap, .memstart, .vm0wp);

   VMEM12(.clk, .reset, .vmap, .mapi, .vm1rp, .vma, .vmo, .vm1wp);

   VMEMDR(.vmo, .srcmap, .state_alu, .state_write, .state_mmu, .state_fetch, .lvmo_23, .lvmo_22, .mapdrive, .pma);

   DEBUG(.clk, .reset, .spy_in, .i, .idebug, .promenable, .iprom, .iram, .lddbirh, .lddbirm, .lddbirl);

   wire   iwe;
   ICTL(.idebug, .promdisabled, .iwrited, .state_write, .iwe);

   OLORD1(.clk, .reset, .ldmode, .ldscratch1, .ldscratch2, .ldclk, .boot, .run, .step, .promdisable, .trapenb, .stathenb, .errstop, .scratch, .opcinh, .opcclk, .lpc_hold, .ldstat, .idebug, .nop11, .srun, .sstep, .ssdone, .promdisabled, .machrun, .stat_ovf, .stathalt, .errhalt, .state_fetch, .statstop, .spy_in, .ldopc, .set_promdisable, .waiting);

   OLORD2(.clk, .reset, .statstop, .halted, .prog_reset, .err, .errhalt, .prog_bus_reset, .bus_reset, .prog_boot, .boot, .boot_trap, .ldmode, .spy_in, .errstop, .ext_reset, .ext_boot, .srun, .ext_halt, .stat_ovf);

   OPCS(.clk, .reset, .opcclk, .opcinh, .pc, .opc, .state_fetch);

   PCTL(.pc, .idebug, .promdisabled, .iwrited, .promenable, .promaddr);

   PROM01(.clk, .promaddr, .iprom);

   IRAM(.clk, .reset, .pc, .pc_out, .state_out, .iwr, .iwe, .iram, .fetch_out, .prefetch_out, .machrun_out, .mcr_data_in, .state_fetch, .machrun, .state, .need_mmu_state, .state_mmu, .state_write, .state_prefetch, .promdisabled);

   SPY0(.spy_obh, .spy_obl, .spy_pc, .spy_opc, .spy_scratch, .spy_irh, .spy_irm, .spy_irl, .spy_stl, .spy_ah, .spy_al, .spy_mh, .spy_ml, .spy_flag2, .spy_flag1, .ldscratch2, .ldscratch1, .ldmode, .ldopc, .ldclk, .lddbirh, .lddbirm, .lddbirl, .eadr, .dbread, .dbwrite, .spy_mdl, .spy_vmal, .spy_vmah, .spy_sth, .spy_mdh, .spy_disk, .spy_bd, .ldmdh, .ldmdl, .ldvmah, .ldvmal, .spy_obl_, .spy_obh_);

`ifdef debug
   // ======================================================================================
   // monitors

   always @(posedge clk)
     begin
       if ((loadmd && memrq) || (state_alu && destmdr))
	 $display("md: load <- %o", mds);
       else
	 if (ldmdh)
	   $display("spy: load md[31:16] <= %o", spy_in);
	 else
	   if (ldmdl)
	     $display("spy: load md[15:0] <= %o", spy_in);

       if (state_alu && vmaenb)
	 $display("vma: load <- %o", vmas);
       else
	 if (ldvmah)
	   $display("vma: load vma[31:16] <- %o", spy_in);
	 else
	   if (ldvmal)
	     $display("vma: load vma[15:0] <- %o", spy_in);

       if (state_fetch && destintctl)
	 if (debug > 0)
	   $display("destintctl: ob %o (%b %b %b %b)", ob, ob[29], ob[28], ob[27], ob[26]);

       if (state_fetch)
	 begin
`ifdef debug_iram
	    if (~destimod0 && ~destimod0 && ~promenable)
	      $display("iram: [%o] -> %o; %t", pc, iram, $time);
`endif
`ifdef debug_detail
	    if (destimod1)
	      $display("destimod1: lpc %o ob %o ir %o",
		       lpc, ob[21:0], { iob[47:26], i[25:0] });
`endif
	 end

`ifdef use_iologger
	if (state_fetch && ~sintr && bus_int)
	  test.iologger(32'd3, 0, 1);
	if (state_fetch && sintr && ~bus_int)
	  test.iologger(32'd3, 0, 0);
`endif

`ifdef debug_ifetch
	if (ifetch && state_fetch)
	  $display("(lba) ifetch! lpc %o, lc %o; %t", lpc, lc, $time);
`endif

`ifdef debug_md
       if ((loadmd && memrq) || (state_alu && destmdr))
	 begin
	    if (debug != 0)
	    if (state_fetch && destmdr)
	      $display("load md <- %o; D mdsel%b osel %b alu %o mo %o; lpc %o",
		       mds, mdsel, osel, alu, mo, lpc);
	    else
	      $display("load md <- %o; L lpc %o; %t", mds, lpc, $time);
	    $display("load md <- %o; %t", mds, $time);
	 end
`endif


`ifdef debug
	if (loadmd && (state_fetch && destmdr))
	  begin
	     $display("XXXX loadmd and destmdr conflict, lpc %o; %t", lpc, $time);
	     $finish;
	  end
`endif

`ifdef debug_mmem
	if (mwp && madr != 0)
	  $display("mmem: %o <- %o; %t", madr, l, $time);
`endif

`ifdef debug_dispatch
	if (state_fetch && irdisp/*({pcs1,pcs0} == 2'b10)*/)
	  begin
	     $display("dispatch: dadr=%o %b%b%b %o; dmask %o r %o ir %b vmo %b md %o",
		      dadr, dr, dp, dn, dpc, dmask, r[11:0],
		      {ir[8], ir[9]}, {vmo[19],vmo[18]}, md);
	     $display("dispatch: mapi %o vmap %o vmem1_adr %o vmo %o",
		      mapi[23:13], vmap, vmem1_adr, vmo);
	     $display("dispatch: pcs %b, dispenb %b dfall %b; vmo[19:18] %o, npc %o",
		      {pcs1,pcs0}, dispenb, dfall, vmo[19:18], npc);
	  end
`endif

`ifdef debug_detail
	if (~reset)
	  begin
	     $display("; npc %o ipc %o, spc %o, pc %o pcs %b%b state %b",
		      npc, ipc, spc, pc, pcs1, pcs0, state);
	     $display("; spco %o, spcw %o",
		      spco, spcw);
	     $display("; %b %b %b %b (%b %b)",
		      (popj & ~ignpopj),
		      (jfalse & ~jcond),
		      (irjump & ~ir[6] & jcond),
		      (dispenb & dr & ~dp),
		      popj, ignpopj);
	     $display("; conds=%b,  aeqm=%b, aeqm_bits=%b",
		      conds, aeqm, aeqm_bits);
	     $display("; trap=%b,  trapenb=%b boot_trap=%b",
		      trap, trapenb, boot_trap);
	     $display("; nopa %b, inop %b, nop11 %b",
		      nopa, inop, nop11);
	  end
`endif
`ifdef debug
	if (state_write && destpdlx && pdlidx != ob[9:0] && debug > 0)
	  $display("pdlidx <- %o", ob[9:0]);
`endif

`ifdef debug_amem
	if (awp && aadr != 0)
	  $display("amem: W %o <- %o", aadr, l);
`endif

`ifdef debug_xbus
	if (memstart & ~vmaok)
	  $display("xbus: access fault, l1[%o]=%o, l2[%o]= %b%b %o; %t",
		   mapi[23:13], vmap,
		   vmem1_adr, vmo[23], vmo[22], vmo[21:0],
		   $time);
	if (memstart & vmaok)
	  $display("xbus: start l1[%o]=%o, l2[%o]= %b%b %o",
		   mapi[23:13], vmap,
		   vmem1_adr, vmo[23], vmo[22], vmo[21:0]);
`endif

`ifdef debug_vma
	if (state_alu && vmaenb)
	  if (vma != vmas)
	    $display("vma <- %o", vmas);
`endif

	if (promdisable == 1 && promdisabled == 0)
	  $display("prom: disabled");
	if (promdisable == 0 && promdisabled == 1)
	  $display("prom: enabled");

     end

`ifdef debug
   always @(vm0wp or mapwr0 or state_write)
     if (debug != 0)
     if (vm0wp)
       $display("vm0wp %b, a=%o, di=%o; %t",
		vm0wp, mapi[23:13], vma[31:27], $time);

   always @(vm1wp or mapwr1 or state_write)
     if (debug != 0)
     if (vm1wp)
       $display("vm1wp %b, a=%o, di=%o; %t",
		vm1wp, vmem1_adr, vma[23:0], $time);
`endif

`ifdef debug_vmem
   always @(memprepare or memstart or mapi or vmo or vmap or clk)
     if (memprepare && memstart)
       begin
	  $display("%t prep vmem0_adr %o, vmap=%o",
		   $time, mapi[23:13], vmap);
	  $display("%t prep vmem1_adr %o, vma=%o, vmo[23:22]=%b%b, vmo=%o",
		   $time, vmem1_adr, vma, vmo[23], vmo[22], vmo[21:0]);
       end

   always @(memrq)
     if (memrq)
       begin
	  $display("%t req vmem0_adr %o, vmap=%o",
		   $time, mapi[23:13], vmap);
	  $display("%t req vmem1_adr %o, vma=%o, vmo[23:22]=%b, vmo[21:0]=%o",
		   $time, vmem1_adr, vma, {vmo[23], vmo[22]}, vmo[21:0]);
	  $display("%t req lvmo_23,22 %b%b, pma=%o",
		   $time, lvmo_23, lvmo_22, pma);
       end
`endif

`endif

//`define CHIPSCOPE_CADDR

`ifdef __CVER__
 `ifdef CHIPSCOPE_CADDR
  `undef CHIPSCOPE_CADDR
 `endif
`endif

`ifdef CHIPSCOPE_CADDR
   // chipscope
   wire [35:0] control0;
   wire [127:0] trig0;
   wire        mclk_en;
   wire        mclk;

   assign trig0 = {
		   busint.disk.state, //5
		   bd_state_in,       //12
		   state_decode,      //1
		   lpc,		      //14
		   a,		      //32
		   m,		      //32
		   md		      //32
		   };

   chipscope_icon_caddr icon1 (.CONTROL0(control0));
   chipscope_ila_caddr ila1 (.CONTROL(control0), .CLK(clk), .TRIG0(trig0));
`endif

endmodule
