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
 * 	normal vmem0 read
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
	       dbread, dbwrite, eadr, spy_reg, spy_rd, spy_wr,

	       pc_out, state_out, machrun_out,
	       prefetch_out, fetch_out,
	       disk_state_out, bus_state_out,
	       
	       mcr_addr, mcr_data_out, mcr_data_in,
	       mcr_ready, mcr_write, mcr_done,

	       sdram_addr, sdram_data_in, sdram_data_out,
	       sdram_req, sdram_ready, sdram_write, sdram_done,

	       vram_addr, vram_data_in, vram_data_out,
	       vram_req, vram_ready, vram_write, vram_done,

	       bd_cmd, bd_start, bd_bsy, bd_rdy, bd_err, bd_addr,
	       bd_data_in, bd_data_out, bd_rd, bd_wr, bd_iordy, bd_state_in,

	       kb_data, kb_ready,
	       ms_x, ms_y, ms_button, ms_ready );

   input clk;
   input ext_int;
   input ext_reset;
   input ext_boot;
   input ext_halt;

   input [15:0] spy_in;
   output [15:0] spy_out;
   input 	dbread;
   input 	dbwrite;
   input [4:0] 	eadr;
   output [3:0]	spy_reg;
   output 	spy_rd;
   output 	spy_wr;
   
   output [13:0] pc_out;
   output [5:0]  state_out;
   output [4:0]  disk_state_out;
   output [3:0]  bus_state_out;
   output 	 machrun_out;
   output 	 prefetch_out;
   output 	 fetch_out;

   output [13:0] mcr_addr;
   output [48:0] mcr_data_out;
   input [48:0]  mcr_data_in;
   input 	 mcr_ready;
   output 	 mcr_write;
   input 	 mcr_done;

   output [21:0]  sdram_addr;
   output [31:0] sdram_data_out;
   input [31:0]  sdram_data_in;
   output 	 sdram_req;
   input 	 sdram_ready;
   output 	 sdram_write;
   input 	 sdram_done;

   output [14:0] vram_addr;
   output [31:0] vram_data_out;
   input [31:0]  vram_data_in;
   output 	 vram_req;
   input 	 vram_ready;
   output 	 vram_write;
   input 	 vram_done;
   
   output [1:0]  bd_cmd;	/* generic block device interface */
   output 	 bd_start;
   input 	 bd_bsy;
   input 	 bd_rdy;
   input 	 bd_err;
   output [23:0] bd_addr;
   input [15:0]  bd_data_in;
   output [15:0] bd_data_out;
   output 	 bd_rd;
   output 	 bd_wr;
   input 	 bd_iordy;
   input [11:0]  bd_state_in;

   input [15:0]  kb_data;
   input 	 kb_ready;
   
   input [11:0]  ms_x, ms_y;
   input [2:0] 	 ms_button;
   input 	 ms_ready;

   // ------------------------------------------------------------
   
   wire [13:0] 	npc;
   wire [13:0] 	dpc;
   wire [13:0] 	ipc;
   wire [18:0] 	spc;

   wire [48:0] 	ir;

   wire [31:0] 	a;
   wire [9:0] 	aadr;
   wire 	awp;
   wire 	arp;
   
   wire [9:0] 	wadr;

   wire [7:0] 	aeqm_bits;
   wire 	aeqm;
//   reg 	aeqm;
   wire [32:0] 	alu;

   wire 	divposlasttime, divsubcond, divaddcond;
   wire 	aluadd, alusub, mulnop;
   wire 	mul, div, specalu;

   wire [1:0] 	osel;

   wire [3:0] 	aluf;
   wire 	alumode;
   wire 	cin0;

   wire [31:0] 	amem;

   wire 	dfall, dispenb, ignpopj, jfalse, jcalf, jretf, jret, iwrite;
   wire 	ipopj, popj, srcspcpopreal;
   wire 	spop, spush;

   wire 	swp, srp, spcenb, spcdrive, spcnt;

   wire 		inop, iwrited; 
   wire 	n, pcs1, pcs0;

   wire 	nopa, nop;

   // page DRAM0-2
   wire [10:0] 	dadr;
   wire 	dr, dp, dn;
   wire 	daddr0;
   wire [6:0] 	dmask;
   wire 	dwe;

   // page DSPCTL
   wire 	dmapbenb, dispwr;
   wire [9:0] 	dc;
   wire [11:0] 	prompc;
   wire [8:0] 	promaddr;

   // page FLAG
   wire 	statbit, ilong, aluneg;
   wire 	pgf_or_int, pgf_or_int_or_sb, sint;

   wire [2:0] 	conds;
   wire 	jcond;
   wire 		lc_byte_mode, prog_unibus_reset, int_enable, sequence_break;

   // page IOR
   wire [47:0] 	iob;
   wire [31:0] 	ob;

   // page IPAR

   // page LC
   wire [25:0] 	lc;
   wire [3:0] 	lca;
   wire 	lcry3;

   wire 	lcdrive;
   wire 	sh4, sh3;

   wire [31:0] 	mf;

   wire 	lc0b, next_instr, newlc_in;
   wire 	have_wrong_word, last_byte_in_word;
   wire 	needfetch, ifetch, spcmung, spc1a;
   wire 	lcinc;

   wire 		newlc, sintr, next_instrd;

   wire 	lc_modifies_mrot;
   wire 	inst_in_left_half;
   wire 	inst_in_2nd_or_4th_quarter;

   wire [13:0] 	wpc;

   // page MCTL
   wire 	mpassm;
   wire 	srcm;
   wire 	mwp;
   wire 	mrp;
   wire [4:0] 	madr;

   // page MD
   wire [31:0] 	md;
   wire 	mddrive;	/* drive md on to mf bus */
   wire 	mdclk;		/* enable - clock md in? */
   wire 	loadmd;		/* data available from busint */

   wire 		mdhaspar, mdpar;
   wire 	mdgetspar;

   wire 	ignpar;

   // page MDS
   wire [31:0] 	mds;
   wire [31:0] 	mem;
   wire [31:0] 	busint_bus;
   wire [15:0] 	busint_spyout;

   wire 	bus_int;
   

   // page MF
   wire 	mfenb;
   wire 	mfdrive;

   // page MLATCH
   wire [31:0] 	m;

   // page MMEM
   wire [31:0] 	mmem;

   wire [31:0] 	mo;

   wire [31:0] 	msk_right_out, msk_left_out, msk;

   wire 	dcdrive, opcdrive;

   // page PDL
   wire [31:0] 	pdl;

   // page PDLCTL
   wire [9:0] 	pdla;
   wire 	pdlp, pdlwrite;
   wire 	pwp, prp, pdlenb, pdldrive, pdlcnt;
   wire 		pwidx;

   // page PDLPTR
   wire 	pidrive, ppdrive;
   wire [9:0] 	pdlidx;

   // page Q
   wire [31:0] 	q;
   wire 	qs1, qs0, qdrive;

   // page SHIFT0-1
   wire [31:0] 	sa;
   wire [31:0] 	r;

   // page SMCTL
   wire 	mr, sr;
   wire [4:0] 	mskr;
   wire [4:0] 	mskl;

   wire 	s4, s3, s2, s1, s0;

   // page SOURCE
   wire 	irbyte, irdisp, irjump, iralu;

   wire [3:0] 	funct;

   wire 	srcdc;		/* ir<30-26> m src = dispatch constant */
   wire 	srcspc;		/* ir<30-26> m src = spc ptr */
   wire 	srcpdlptr;	/* ir<30-26> m src = pdl ptr */
   wire 	srcpdlidx;	/* ir<30-26> m src = pdl index */
   
   wire 	srcopc;
   wire 	srcq;
   wire 	srcvma;		/* ir<30-26> m src = vma */
   wire 	srcmap;		/* ir<30-26> m src = vm map[md] */
   wire 	srcmd;		/* ir<30-26> m src = md */
   wire 	srclc;		/* ir<30-26> m src = lc */
   
   wire 	srcspcpop;	/* ir<30-26> m src = SPC , pop*/

   wire 	srcpdlpop;	/* ir<30-26> m src = PDL buffer, ptr, pop */
   wire 	srcpdltop;	/* ir<30-26> m src = PDL buffer, ptr */


   wire 	imod;

   wire 	dest;
   wire 	destm;		/* fuctional destination */

   wire 	destmem;	/* ir<25-14> dest VMA or MD */

   wire 	destvma;	/* ir<25-14> dest VMA register */
   wire 	destmdr;	/* ir<25-14> dest MD register */

   wire 	destintctl;	/* ir<25-14> dest interrupt control */
   wire 	destlc;		/* ir<25-14> dest lc */
   wire 	destimod1;	/* ir<25-14> dest oa register <47-26> */
   wire 	destimod0;	/* ir<25-14> dest oa register <25-0> */
   wire 	destspc;	/* ir<25-14> dest spc data, push*/
   wire 	destpdlp;	/* ir<25-14> dest pdl ptr */
   wire		destpdlx;	/* ir<25-14> dest pdl index */
   wire 	destpdl_x;	/* ir<25-14> dest pdl (addressed by index)  */
   wire 	destpdl_p;	/* ir<25-14> dest pdl (addressed by ptr), push*/
   wire 	destpdltop;	/* ir<25-14> dest pdl (addressed by ptr) */


   // page SPC

   wire [4:0] 	spcptr;

   wire [18:0] 	spcw;
   wire [18:0] 	spco;

   // page SPCPAR

   wire 	trap;
   wire 		boot_trap;


   // page VCTRL1

   wire 	memop;
   wire 		memprepare;
   wire 		memstart;
   wire 		memcheck;
   
   wire 		rdcyc;
   wire 		mbusy;

   wire 	memrq;
   wire 		wrcyc;

   wire 	pfw;			/* vma permissions */
   wire 	pfr;
   wire 		vmaok;			/* vma access ok */

   wire 	mfinish;

   wire 	memack;

   wire 	waiting;
   
   // page VCTRL2

   wire 	mapwr0, mapwr1, vm0wp, vm1wp;
   wire 	vm0rp, vm1rp;
   wire [10:0] 	vmem0_adr;
 	
   wire 	vmaenb, vmasel;
   wire 	memdrive, mdsel, use_md;
   wire 	wmap, memwr, memrd;

   wire 	lm_drive_enb;

   // page VMA

   wire [31:0] 	vma;
   wire 	vmadrive;

   // page VMAS

   wire [31:0] 	vmas;

   //       22221111111111
   // mapi  32109876543210
   //       1
   // vmem0 09876543210
   //
   wire [23:8] 	mapi;

   wire [4:0] 	vmap;

   // page VMEM0 - virtual memory map stage 0

   wire 	use_map;

   wire [23:0] 	vmo;

   wire 	mapdrive;

   wire [48:0] 	i;
   wire [48:0] 	iprom;
   wire [48:0] 	iram;
   wire [47:0] 	spy_ir;

   wire 	ramdisable;

   wire 		opcinh, opcclk, lpc_hold;

   wire 		ldstat, idebug, nop11, step;

   wire 		run;

   wire 	machrun, stat_ovf, stathalt;

   wire 	prog_reset, reset;
   wire 	err, errhalt;
   wire 	bus_reset;
   wire 	prog_boot, boot;

   wire 	prog_bus_reset;

   wire 	opcclka;

   // page VMEM1&2

   wire [9:0] 	vmem1_adr;

   // page PCTL
   wire 	promenable, promce, bottom_1k;

   // page OLORD1 
   wire 		promdisable;
   wire 		trapenb;
   wire 		stathenb;
   wire 		errstop;

   wire 		srun, sstep, ssdone, promdisabled;

   // page OLORD2

   wire 		higherr;
   wire 		statstop;
   wire 		halted;

   // page L
   wire [31:0] 	l;

   // page NPC
   wire [13:0] 	pc;

   // page OPCS
   wire [13:0] 	opc;

   // page PDLPTR
   wire [9:0] 	pdlptr;

   // page SPCW
//   reg [13:0] 	reta;
   wire [13:0] 	reta;

   // page IWR
   wire [48:0] 	iwr;

   wire [13:0] 	lpc;

   wire 	lvmo_23;
   wire 	lvmo_22;
   wire [21:8] 	pma;


   // SPY 0

   wire   spy_obh, spy_obl, spy_pc, spy_opc,
	  spy_scratch, spy_irh, spy_irm, spy_irl;

   wire   spy_sth, spy_stl, spy_ah, spy_al,
	  spy_mh, spy_ml, spy_flag2, spy_flag1;

   wire   spy_mdh, spy_mdl, spy_vmah, spy_vmal, spy_obh_, spy_obl_;
   wire   spy_disk, spy_bd;
   
   wire   ldmode, ldopc, ldclk, lddbirh, lddbirm, lddbirl, ldscratch1, ldscratch2;
   wire   ldmdh, ldmdl, ldvmah, ldvmal;
   wire   set_promdisable;

   wire [15:0] scratch;
   
`ifdef debug
   integer 	  debug;
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

   ACTL cadr_actl(.clk(clk), .reset(reset), .state_decode(state_decode), .state_write(state_write), .wadr(wadr), .destm(destm), .awp(awp), .arp(arp), .aadr(aadr), .ir(ir), .dest(dest));

   ALATCH cadr_alatch(.amem(amem), .a(a));

   // page ALU0-1

   wire[2:0] nc_alu;
   wire      cin32_n, cin28_n, cin24_n, cin20_n;
   wire      cin16_n, cin12_n, cin8_n, cin4_n;

   wire      xx0, xx1;
   wire      yy0, yy1;

   wire      xout3, xout7, xout11, xout15, xout19, xout23, xout27, xout31;
   wire      yout3, yout7, yout11, yout15, yout19, yout23, yout27, yout31;

//`define _alu01
`ifdef _alu01
   ALU01 cadr_alu01(.aeqm_bits(aeqm_bits), .a(a), .m(m), .aluf(aluf), .alumode(alumode), .aeqm(aeqm), .alu(alu), .cin12_n(cin12_n), .cin16_n(cin16_n), .cin20_n(cin20_n), .cin24_n(cin24_n), .cin28_n(cin28_n), .cin32_n(cin32_n), .cin4_n(cin4_n), .cin8_n(cin8_n), .cin0(cin0), .xout11(xout11), .xout15(xout15), .xout19(xout19), .xout23(xout23), .xout27(xout27), .xout3(xout3), .xout31(xout31), .xout7(xout7), .yout11(yout11), .yout15(yout15), .yout19(yout19), .yout23(yout23), .yout27(yout27), .yout3(yout3), .yout31(yout31), .yout7(yout7));
`else

   // 74181 pulls down AEB if not equal
   // aeqm is the simulated open collector
   assign aeqm = aeqm_bits == { 8'b11111111 } ? 1'b1 : 1'b0;
//  always @(posedge clk)
//     if (reset)
//       aeqm <= 0;
//     else
//       aeqm <= aeqm_bits == { 8'b11111111 } ? 1'b1 : 1'b0;

   ic_74S181  i_ALU1_2A03 (
			   .B({3'b0,a[31]}),
			   .A({3'b0,m[31]}),
			   .S(aluf[3:0]),
			   .CIN_N(cin32_n),
			   .M(alumode),
			   .F({nc_alu,alu[32]}),
			   .X(),
			   .Y(),
			   .COUT_N(),
			   .AEB()
			   );

   ic_74S181  i_ALU1_2A08 (
			   .B(a[31:28]),
			   .A(m[31:28]),
			   .S(aluf[3:0]),
			   .CIN_N(cin28_n),
			   .M(alumode),
			   .F(alu[31:28]),
			   .AEB(aeqm_bits[7]),
			   .X(xout31),
			   .Y(yout31),
			   .COUT_N()
			   );

   ic_74S181  i_ALU1_2B08 (
			   .B(a[27:24]),
			   .A(m[27:24]),
			   .S(aluf[3:0]),
			   .CIN_N(cin24_n),
			   .M(alumode),
			   .F(alu[27:24]),
			   .AEB(aeqm_bits[6]),
			   .X(xout27),
			   .Y(yout27),
			   .COUT_N()
			   );

   ic_74S181  i_ALU1_2A13 (
			   .B(a[23:20]),
			   .A(m[23:20]),
			   .S(aluf[3:0]),
			   .CIN_N(cin20_n),
			   .M(alumode),
			   .F(alu[23:20]),
			   .AEB(aeqm_bits[5]),
			   .X(xout23),
			   .Y(yout23),
			   .COUT_N()
			   );

   ic_74S181  i_ALU1_2B13 (
			   .B(a[19:16]),
			   .A(m[19:16]),
			   .S(aluf[3:0]),
			   .CIN_N(cin16_n),
			   .M(alumode),
			   .F(alu[19:16]),
			   .AEB(aeqm_bits[4]),
			   .X(xout19),
			   .Y(yout19),
			   .COUT_N()
			   );

   ic_74S181  i_ALU0_2A23 (
			   .A(m[15:12]),
			   .B(a[15:12]),
			   .S(aluf[3:0]),
			   .CIN_N(cin12_n),
			   .M(alumode),
			   .F({alu[15:12]}),
			   .AEB(aeqm_bits[3]),
			   .X(xout15),
			   .Y(yout15),
			   .COUT_N()
			   );

   ic_74S181  i_ALU0_2B23 (
			   .A(m[11:8]),
			   .B(a[11:8]),
			   .S(aluf[3:0]),
			   .CIN_N(cin8_n),
			   .M(alumode),
			   .F(alu[11:8]),
			   .AEB(aeqm_bits[2]),
			   .X(xout11),
			   .Y(yout11),
			   .COUT_N()
			   );

   ic_74S181  i_ALU0_2A28 (
			   .A(m[7:4]),
			   .B(a[7:4]),
			   .S(aluf[3:0]),
			   .CIN_N(cin4_n),
			   .M(alumode),
			   .F(alu[7:4]),
			   .AEB(aeqm_bits[1]),
			   .X(xout7),
			   .Y(yout7),
			   .COUT_N()
			   );

   ic_74S181  i_ALU0_2B28 (
			   .A(m[3:0]),
			   .B(a[3:0]),
			   .S(aluf[3:0]),
			   .CIN_N(~cin0),
			   .M(alumode),
			   .F(alu[3:0]),
			   .AEB(aeqm_bits[0]),
			   .X(xout3),
			   .Y(yout3),
			   .COUT_N()
			   );
`endif

`define _aluc4
`ifdef _aluc4
   ALUC4 cadr_aluc4(.yout15(yout15), .yout11(yout11), .yout7(yout7), .yout3(yout3), .xout15(xout15), .xout11(xout11), .xout7(xout7), .xout3(xout3), .yout31(yout31), .yout27(yout27), .yout23(yout23), .yout19(yout19), .xout31(xout31), .xout27(xout27), .xout23(xout23), .xout19(xout19), .a(a), .ir(ir), .iralu(iralu), .irjump(irjump), .mul(mul), .div(div), .q(q), .osel(osel), .divposlasttime(divposlasttime), .divsubcond(divsubcond), .divaddcond(divaddcond), .mulnop(mulnop ), .aluadd(aluadd ), .alusub(alusub ), .aluf(aluf ), .alumode(alumode ), .cin12_n(cin12_n), .cin8_n(cin8_n), .cin4_n(cin4_n), .cin0(cin0), .xx0(xx0), .yy0(yy0), .cin28_n(cin28_n), .cin24_n(cin24_n), .cin20_n(cin20_n), .cin16_n(cin16_n), .xx1(xx1), .yy1(yy1), .cin32_n(cin32_n));
`else
   // page ALUC4

   ic_74S182  i_ALUC4_2A20 (
			    .Y( { yout15,yout11,yout7,yout3 } ),
			    .X( { xout15,xout11,xout7,xout3 } ),
			    .COUT2_N(cin12_n),
			    .COUT1_N(cin8_n),
			    .COUT0_N(cin4_n),
			    .CIN_N(~cin0),
			    .XOUT(xx0),
			    .YOUT(yy0)
			    );

   ic_74S182  i_ALUC4_2A19 (
			    .Y( { yout31,yout27,yout23,yout19 } ),
			    .X( { xout31,xout27,xout23,xout19 } ),
			    .COUT2_N(cin28_n),
			    .COUT1_N(cin24_n),
			    .COUT0_N(cin20_n),
			    .CIN_N(cin16_n),
			    .XOUT(xx1),
			    .YOUT(yy1)
			    );

   ic_74S182  i_ALUC4_2A18 (
			    .Y( { 2'b00, yy1,yy0 } ),
			    .X( { 2'b00, xx1,xx0 } ),
			    .COUT1_N(cin32_n),
			    .COUT0_N(cin16_n),
			    .CIN_N(~cin0),
			    .COUT2_N(),
			    .XOUT(),
			    .YOUT()
			    );


   assign    divposlasttime  = q[0] | ir[6];

   assign    divsubcond = div & divposlasttime;

   assign    divaddcond = div & (ir[5] | ~divposlasttime);

   assign    mulnop = mul & ~q[0];

   assign    aluadd = (divaddcond & ~a[31]) |
		      (divsubcond & a[31]) |
		      mul;

   assign    alusub = mulnop |
		      (divsubcond & ~a[31]) |
	              (divaddcond & a[31]) |
		      irjump;

   assign osel[1] = ir[13] & iralu;
   assign osel[0] = ir[12] & iralu;

   assign aluf =
		  {alusub,aluadd} == 2'b00 ? { ir[3], ir[4], ~ir[6], ~ir[5] } :
		  {alusub,aluadd} == 2'b01 ? { 1'b1,   1'b0,   1'b0,  1'b1 } :
		  {alusub,aluadd} == 2'b10 ? { 1'b0,   1'b1,   1'b1,  1'b0 } :
	          { 1'b1,   1'b1,   1'b1,  1'b1 };

   assign alumode =
		     {alusub,aluadd} == 2'b00 ? ~ir[7] :
		     {alusub,aluadd} == 2'b01 ? 1'b0 :
		     {alusub,aluadd} == 2'b10 ? 1'b0 :
	             1'b1;

   assign cin0 =
		  {alusub,aluadd} == 2'b00 ? ir[2] :
		  {alusub,aluadd} == 2'b01 ? 1'b0 :
		  {alusub,aluadd} == 2'b10 ? ~irjump :
                  1'b1;
`endif

   AMEM01 cadr_amem01(.clk(clk), .reset(reset), .aadr(aadr), .amem(amem), .awp(awp), .arp(arp), .l(l));

`define _contrl
`ifdef _contrl
   CONTRL cadr_contrl(.clk(clk), .reset(reset), .destspc(destspc), .dfall(dfall), .dispenb(dispenb), .dn(dn), .dp(dp), .dr(dr), .funct(funct), .ignpopj(ignpopj), .inop(inop), .ipopj(ipopj), .ir(ir), .irdisp(irdisp), .irjump(irjump), .iwrite(iwrite), .iwrited(iwrited), .jcalf(jcalf), .jcond(jcond), .jfalse(jfalse), .jret(jret), .jretf(jretf), .n(n), .nop(nop), .nop11(nop11), .nopa(nopa), .pcs0(pcs0), .pcs1(pcs1), .popj(popj), .spcdrive(spcdrive), .spcenb(spcenb), .spcnt(spcnt), .spop(spop), .spush(spush), .srcspc(srcspc), .srcspcpop(srcspcpop), .srcspcpopreal(srcspcpopreal), .srp(srp), .state_alu(state_alu), .state_fetch(state_fetch), .state_write(state_write), .swp(swp), .trap(trap));
`else
   // page CONTRL

   assign dfall  = dr & dp;			/* push-pop fall through */

   assign dispenb = irdisp & ~funct[2];

   assign ignpopj  = irdisp & ~dr;

   assign jfalse = irjump & ir[6];		/* jump and inverted-sense */

   assign jcalf = jfalse & ir[8];		/* call and inverted-sense */

   assign jret = irjump & ~ir[8] & ir[9];	/* return */

   assign jretf = jret & ir[6];			/* return and inverted-sense */

   assign iwrite = irjump & ir[8] & ir[9];	/* microcode write */

   assign ipopj = ir[42] & ~nop;

   assign popj = ipopj | iwrited;

   assign srcspcpopreal  = srcspcpop & ~nop;

   assign spop =
		((srcspcpopreal | popj) & ~ignpopj) |
		(dispenb & dr & ~dp) |
		(jret & ~ir[6] & jcond) |
		(jretf & ~jcond);

   assign spush = 
		  destspc |
		  (jcalf & ~jcond) |
		  (dispenb & dp & ~dr) |
		  (irjump & ~ir[6] & ir[8] & jcond);
   
   assign srp = state_write;
   assign swp = spush & state_write;
   assign spcenb = srcspc | srcspcpop;
   assign spcdrive = spcenb &
		     (state_alu || state_write || state_fetch);
   assign spcnt = spush | spop;

   always @(posedge clk)
     if (reset)
       begin
	  iwrited <= 0;
       end
     else
       if (state_fetch)
	 begin
	    iwrited <= iwrite;
	 end

   /*
    * select new pc
    * {pcs1,pcs0}
    * 00 0 spc
    * 01 1 ir
    * 10 2 dpc
    * 11 3 ipc
    */

   assign pcs1 =
	!(
	  (popj & ~ignpopj) |		/* popj & !ignore */
	  (jfalse & ~jcond) |		/* jump & invert & cond-not-satisfied */
	  (irjump & ~ir[6] & jcond) |	/* jump & !invert & cond-satisfied */
	  (dispenb & dr & ~dp)		/* dispatch + return & !push */
	  );

   assign pcs0 =
	!(
	  (popj) |
	  (dispenb & ~dfall) |
	  (jretf & ~jcond) |
	  (jret & ~ir[6] & jcond)
	  );

   /*
    * N set if:
    *  trap 						or
    *  iwrite (microcode write) 			or
    *  dispatch & disp-N 				or
    *  jump & invert-jump-selse & cond-false & !next	or
    *  jump & !invert-jump-sense & cond-true & !next
    */
   assign n =
	     trap |
	     iwrited |
	     (dispenb & dn) |
	     (jfalse & ~jcond & ir[7]) |
	     (irjump & ~ir[6] & jcond & ir[7]);

   assign nopa = inop | nop11;

   assign nop = trap | nopa;

   always @(posedge clk)
     if (reset)
       inop <= 0;
     else
       if (state_fetch)
	 inop <= n;
`endif
   
`define _dram02
`ifdef _dram02
   DRAM02 cadr_dram02(.clk(clk), .reset(reset), .daddr0(daddr0), .dadr(dadr), .dwe(dwe), .a(a), .ir(ir), .vmo(vmo), .dmask(dmask), .r(r), .dr(dr), .dp(dp), .dn(dn), .dpc(dpc), .dispwr(dispwr), .state_write(state_write), .state_prefetch(state_prefetch));
`else
   // page DRAM0-2

   // dadr  10 9  8  7  6  5  4  3  2  1  0
   // -------------------------------------
   // ir    22 21 20 19 18 17 16 15 14 13 d
   // dmask x  x  x  x  6  5  4  3  2  1  x
   // r     x  x  x  x  6  5  4  3  2  1  x

   assign daddr0 = 
		   (ir[8] & vmo[18]) |
		   (ir[9] & vmo[19]) |
//note: the hardware shows bit 0 replaced, 
// 	but usim or's it instead.
		   (/*~dmapbenb &*/ dmask[0] & r[0]) |
		   (ir[12]);

   assign dadr =
		{ ir[22:13], daddr0 } |
		({ 4'b0000, dmask[6:1], 1'b0 } &
		 { 4'b0000, r[6:1],     1'b0 });
   
   assign dwe = dispwr & state_write;

   // dispatch ram
   part_2kx17dpram i_DRAM(
			  .reset(reset),
			  
			  .clk_a(clk),
			  .address_a(dadr),
			  .q_a({dr,dp,dn,dpc}),
			  .data_a(17'b0),
			  .wren_a(1'b0),
			  .rden_a(~state_prefetch && ~dwe),

			  .clk_b(clk),
			  .address_b(dadr),
			  .q_b(),
			  .data_b(a[16:0]),
			  .wren_b(dwe),
			  .rden_b(1'b0)
			  );
`endif

   DSPCTL cadr_dspctl(.clk(clk), .reset(reset), .state_fetch(state_fetch), .irdisp(irdisp), .funct(funct), .ir(ir), .dmask(dmask), .dmapbenb(dmapbenb), .dispwr(dispwr), .dc(dc));


`define _flag
`ifdef _flag
   FLAG cadr_flag(.clk(clk), .reset(reset), .ir(ir), .nopa(nopa), .aeqm(aeqm), .sintr(sintr), .int_enable(int_enable), .vmaok(vmaok), .sequence_break(sequence_break), .alu(alu), .conds(conds), .pgf_or_int(pgf_or_int), .pgf_or_int_or_sb(pgf_or_int_or_sb), .sint(sint), .lc_byte_mode(lc_byte_mode), .prog_unibus_reset(prog_unibus_reset), .ob(ob), .r(r), .state_fetch(state_fetch), .destintctl(destintctl));
`else     
   // page FLAG

   assign statbit = ~nopa & ir[46];
   assign ilong  = ~nopa & ir[45];
   
   assign aluneg = ~aeqm & alu[32];

   assign sint = sintr & int_enable;
   
   assign pgf_or_int = ~vmaok | sint;
   assign pgf_or_int_or_sb = ~vmaok | sint | sequence_break;

   assign conds = ir[2:0] & {ir[5],ir[5],ir[5]};

   assign jcond = 
		  conds == 3'b000 ? r[0] :
		  conds == 3'b001 ? aluneg :
		  conds == 3'b010 ? alu[32] :
		  conds == 3'b011 ? aeqm :
		  conds == 3'b100 ? ~vmaok :
		  conds == 3'b101 ? pgf_or_int :
		  conds == 3'b110 ? pgf_or_int_or_sb :
	          1'b1;

   always @(posedge clk)
     if (reset)
       begin
	  lc_byte_mode <= 0;
	  prog_unibus_reset <= 0;
	  int_enable <= 0;
	  sequence_break <= 0;
       end
     else
       if (state_fetch && destintctl)
	 begin
            lc_byte_mode <= ob[29];
            prog_unibus_reset <= ob[28];
            int_enable <= ob[27];
            sequence_break <= ob[26];
	 end
`endif

   IOR cadr_ior(.iob(iob), .i(i), .ob(ob));

   // page IPAR -- empty

   IREG cadr_ireg(.clk(clk), .reset(reset), .i(i), .iob(iob), .ir(ir), .state_fetch(state_fetch), .destimod1(destimod1), .destimod0(destimod0));

   IWR cadr_iwr(.clk(clk), .reset(reset), .state_fetch(state_fetch), .iwr(iwr), .a(a), .m(m));

   L cadr_l(.clk(clk), .reset(reset), .vmaenb(vmaenb), .state_write(state_write), .state_alu(state_alu), .ob(ob), .l(l));

`define _lc
`ifdef _lc
   LC cadr_lc(.clk(clk), .reset(reset), .destlc(destlc), .lcry3(lcry3), .lca(lca), .lcinc(lcinc), .lc_byte_mode(lc_byte_mode), .lc(lc), .srclc(srclc), .state_alu(state_alu), .state_write(state_write), .state_mmu(state_mmu), .state_fetch(state_fetch), .ob(ob));   

   // mux MF -- move to mf.v
   assign mf =
	      lcdrive ?
	      { needfetch, 1'b0, lc_byte_mode, prog_unibus_reset,
		int_enable, sequence_break, lc[25:1], lc0b } :
	      opcdrive ?
	      { 16'b0, 2'b0, opc[13:0] } :
	      dcdrive ?
	      { 16'b0, 4'b0, 2'b0, dc[9:0] } :
	      ppdrive ?
	      { 16'b0, 4'b0, 2'b0, pdlptr[9:0] } :
	      pidrive ?
	      { 16'b0, 4'b0, 2'b0, pdlidx[9:0] } :
	      qdrive ?
	      q :
	      mddrive ?
	      md :
	      //	mpassl ?
	      //	      l :
	      vmadrive ?
	      vma :
	      mapdrive ?
	      { ~pfw, ~pfr, 1'b1, vmap[4:0], vmo[23:0] } :
	      32'b0;
`else
   // page LC

   always @(posedge clk)
     if (reset)
       lc <= 0;
     else
       if (state_fetch)
	 begin
	    if (destlc)
              lc <= { ob[25:4], ob[3:0] };
	    else
              lc <= { lc[25:4] + { 21'b0, lcry3 }, lca[3:0] };
	 end

   assign {lcry3, lca[3:0]} =
			     lc[3:0] +
			     { 3'b0, lcinc & ~lc_byte_mode } +
			     { 3'b0, lcinc };

   assign lcdrive  = srclc &&
		     (state_alu || state_write || state_mmu || state_fetch);

   // xxx
   // I think the above is really
   // 
   // always @(posedge clk)
   //   begin
   //     if (destlc_n == 0)
   //       lc <= ob;
   //     else
   //       lc <= lc + 
   //             !(lcinc_n | lc_byte_mode) ? 1 : 0 +
   //             lcinc ? 1 : 0;
   //   end
   //

   // mux MF
   assign mf =
        lcdrive ?
	      { needfetch, 1'b0, lc_byte_mode, prog_unibus_reset,
		int_enable, sequence_break, lc[25:1], lc0b } :
        opcdrive ?
	      { 16'b0, 2'b0, opc[13:0] } :
        dcdrive ?
	      { 16'b0, 4'b0, 2'b0, dc[9:0] } :
	ppdrive ?
	      { 16'b0, 4'b0, 2'b0, pdlptr[9:0] } :
	pidrive ?
	      { 16'b0, 4'b0, 2'b0, pdlidx[9:0] } :
	qdrive ?
	      q :
	mddrive ?
	      md :
//	mpassl ?
//	      l :
	vmadrive ?
	      vma :
	mapdrive ?
	      { ~pfw, ~pfr, 1'b1, vmap[4:0], vmo[23:0] } :
	      32'b0;
`endif


`define _lcc
`ifdef _lcc
   LCC cadr_lcc(.clk(clk), .reset(reset), .state_fetch(state_fetch), .lc0b(lc0b), .next_instr(next_instr), .newlc_in(newlc_in), .have_wrong_word(have_wrong_word), .last_byte_in_word(last_byte_in_word), .needfetch(needfetch), .ifetch(ifetch), .spcmung(spcmung), .spc1a(spc1a), .lc_modifies_mrot(lc_modifies_mrot), .inst_in_left_half(inst_in_left_half), .inst_in_2nd_or_4th_quarter(inst_in_2nd_or_4th_quarter), .sh4(sh4), .sh3(sh3), .newlc(newlc), .sintr(sintr), .next_instrd(next_instrd), .lc(lc), .lc_byte_mode(lc_byte_mode), .spop(spop), .srcspcpopreal(srcspcpopreal), .spc(spc), .lcinc(lcinc), .destlc(destlc));
`else
   // page LCC

   assign lc0b = lc[0] & lc_byte_mode;
   assign next_instr  = spop & (~srcspcpopreal & spc[14]);
  
   assign newlc_in  = have_wrong_word & ~lcinc;
   assign have_wrong_word = newlc | destlc;
   assign last_byte_in_word  = ~lc[1] & ~lc0b;
   assign needfetch = have_wrong_word | last_byte_in_word;

   assign ifetch  = needfetch & lcinc;
   assign spcmung = spc[14] & ~needfetch;
   assign spc1a = spcmung | spc[1];

   assign lcinc = next_instrd | (irdisp & ir[24]);

   always @(posedge clk)
     if (reset)
       begin
	  newlc <= 0;
	  sintr <= 0;
	  next_instrd <= 0;
       end
     else
       if (state_fetch)
	 begin
	    newlc <= newlc_in;
	    sintr <= (ext_int | bus_int);
	    next_instrd <= next_instr;
	 end

   // mustn't depend on nop

   assign lc_modifies_mrot  = ir[10] & ir[11];
   
   assign inst_in_left_half = !((lc[1] ^ lc0b) | ~lc_modifies_mrot);

   assign sh4  = ~(inst_in_left_half ^ ~ir[4]);

   // LC<1:0>
   // +---------------+
   // | 0 | 3 | 2 | 1 |
   // +---------------+
   // |   0   |   2   |
   // +---------------+

   assign inst_in_2nd_or_4th_quarter =
	      !(lc[0] | ~lc_modifies_mrot) & lc_byte_mode;

   assign sh3  = ~(~ir[3] ^ inst_in_2nd_or_4th_quarter);
`endif

   LPC cadr_lpc(.clk(clk), .reset(reset), .lpc(lpc), .lpc_hold(lpc_hold), .pc(pc), .wpc(wpc), .irdisp(irdisp), .ir(ir), .state_fetch(state_fetch));

   MCTL cadr_mctl(.mpassm(mpassm), .srcm(srcm), .mrp(mrp), .mwp(mwp), .madr(madr), .ir(ir), .destm(destm), .wadr(wadr), .state_decode(state_decode), .state_write(state_write));

`define _md
`ifdef _md
   MD cadr_md(.clk(clk), .reset(reset), .md(md), .mdhaspar(mdhaspar), .mdpar(mdpar), .mddrive(mddrive), .ignpar(ignpar), .mdclk(mdclk), .spy_in(spy_in), .loadmd(loadmd), .memrq(memrq), .destmdr(destmdr), .mds(mds), .mdgetspar(mdgetspar), .srcmd(srcmd), .state_alu(state_alu), .state_write(state_write), .state_mmu(state_mmu), .state_fetch(state_fetch), .ldmdh(ldmdh), .ldmdl(ldmdl));
`else
   // page MD

   always @(posedge clk) 
     if (reset)
       begin
	  md <= 32'b0;
	  mdhaspar <= 1'b0;
	  mdpar <= 1'b0;
       end
     else
       if ((loadmd && memrq) || (state_alu && destmdr))
	 begin
	    md <= mds;
	    mdhaspar <= mdgetspar;
	 end
       else
	 if (ldmdh)
	   md[31:16] <= spy_in;
	 else
	   if (ldmdl)
	     md[15:0] <= spy_in;
   
   assign mddrive = srcmd &
		    (state_alu || state_write || state_mmu || state_fetch);

   assign mdgetspar = ~destmdr & ~ignpar;
   assign ignpar = 1'b0;

   assign mdclk = loadmd | destmdr;
`endif

   MDS cadr_mds(.mds(mds), .mdsel(mdsel), .ob(ob), .memdrive(memdrive), .loadmd(loadmd), .busint_bus(busint_bus), .md(md));

   MF cadr_mf(.mfenb(mfenb), .mfdrive(mfdrive), .srcm(srcm), .spcenb(spcenb), .pdlenb(pdlenb), .state_alu(state_alu), .state_write(state_write), .state_mmu(state_mmu), .state_fetch(state_fetch));

   MLATCH cadr_mlatch(.pdldrive(pdldrive), .mpassm(mpassm), .spcdrive(spcdrive), .mfdrive(mfdrive), .mmem(mmem), .pdl(pdl), .spcptr(spcptr), .spco(spco), .mf(mf), .m(m));

   MMEM cadr_mmem(.clk(clk), .reset(reset), .mwp(mwp), .mrp(mrp), .madr(madr), .l(l), .b(b), .mmem(mmem));

   MO cadr_mo(.msk(msk), .r(r), .a(a), .mo(mo), .alu(alu), .q(q), .osel(osel), .ob(ob));

   MSKG4 cadr_mskg4(.clk(clk), .msk(msk), .mskl(mskl), .mskr(mskr));

   NPC cadr_npc(.clk(clk), .reset(reset), .state_fetch(state_fetch), .ipc(ipc), .npc(npc), .trap(trap), .pcs1(pcs1), .pcs0(pcs0), .ir(ir), .spc(spc), .spc1a(spc1a), .dpc(dpc), .pc(pc));
	
   OPCD cadr_opcd(.dcdrive(dcdrive), .opcdrive(opcdrive), .srcdc(srcdc), .srcopc(srcopc), .state_alu(state_alu), .state_write(state_write), .state_mmu(state_mmu), .state_fetch(state_fetch));

   PDL cadr_pdl(.clk(clk), .reset(reset), .prp(prp), .pdla(pdla), .l(l), .pwp(pwp), .pdl(pdl));

`define _pdlctl
`ifdef _pdlctl
   PDCTL cadr_pdctl( .clk(clk), .reset(reset), .pdlidx(pdlidx), .pdla(pdla), .pdlp(pdlp), .pdlwrite(pdlwrite), .state_alu(state_alu), .state_write(state_write), .state_read(state_read), .ir(ir), .pwidx(pwidx), .pwp(pwp), .prp(prp), .pdlenb(pdlenb), .pdldrive(pdldrive), .pdlcnt(pdlcnt), .pdlptr(pdlptr), .destpdltop(destpdltop), .destpdl_x(destpdl_x), .destpdl_p(destpdl_p), .srcpdlpop(srcpdlpop), .state_mmu(state_mmu), .nop(nop), .srcpdltop(srcpdltop), .state_fetch(state_fetch));
`else
   // page PDLCTL

   /* m-src = pdl buffer, or index based write */
   assign pdlp = (state_read & ir[30]) | (~state_read & ~pwidx);

   assign pdla = pdlp ? pdlptr : pdlidx;

   assign pdlwrite = destpdltop | destpdl_x | destpdl_p;

   always @(posedge clk)
     if (reset)
       begin
	  pwidx <= 0;
       end
     else
       if (state_alu | state_write)
	 begin
	    pwidx <= destpdl_x;
	 end

   assign pwp = pdlwrite & state_write;
   assign prp = pdlenb && state_read;

   assign pdlenb = srcpdlpop | srcpdltop;

   assign pdldrive = pdlenb &
		     (state_alu || state_write || state_mmu || state_fetch);
   
   assign pdlcnt = (~nop & srcpdlpop) | destpdl_p;
`endif

   
`define _pdlptr
`ifdef _pdlptr
   PDLPTR cadr_pdlptr( .clk(clk), .reset(reset), .pidrive(pidrive), .ppdrive(ppdrive), .pdlidx(pdlidx), .pdlptr(pdlptr), .state_alu(state_alu), .state_write(state_write), .state_fetch(state_fetch), .state_read(state_read), .destpdlx(destpdlx), .srcpdlidx(srcpdlidx), .srcpdlptr(srcpdlptr), .ob(ob), .destpdlp(destpdlp), .pdlcnt(pdlcnt), .srcpdlpop(srcpdlpop));
`else
   // page PDLPTR

   assign pidrive = srcpdlidx & (state_alu || state_write || state_fetch);

   assign ppdrive  = srcpdlptr & (state_alu || state_write || state_fetch);

   always @(posedge clk)
     if (reset)
       pdlidx <= 0;
     else
       if (state_write && destpdlx)
	 pdlidx <= ob[9:0];

   // pdlpop = read[pdlptr] (state_read), pdlptr-- (state_fetch)
   // pdlpush = pdlptr++ (state_read), write[pdlptr] (state_write)
   
   always @(posedge clk)
     if (reset)
       pdlptr <= 0;
     else
       if (state_read)
	 begin
	    if (~destpdlp && pdlcnt && ~srcpdlpop)
	      pdlptr <= pdlptr + 10'd1;
	 end
       else
	 if (state_fetch)
	   begin
	      if (destpdlp)
		pdlptr <= ob[9:0];
	      else
		if (pdlcnt && srcpdlpop)
		  pdlptr <= pdlptr - 10'd1;
	   end
	 
//       if (state_fetch)
//	 begin
//	    if (destpdlp)
//	      pdlptr <= ob[9:0];
//	    else
//	      if (pdlcnt)
//		begin
//		   if (srcpdlpop)
//		     pdlptr <= pdlptr - 10'd1;
//		   else
//		     pdlptr <= pdlptr + 10'd1;
//		end
//	 end
`endif

   // page PLATCH -- empty

   Q cadr_q(.clk(clk), .reset(reset), .state_alu(state_alu), .state_write(state_write), .state_mmu(state_mmu), .state_fetch(state_fetch), .alu(alu), .srcq(srcq), .qs1(qs1), .qs0(qs0), .qdrive(qdrive), .q(q), .ir(ir), .iralu(iralu));

   SHIFT01 cadr_shift01(.sa(sa), .r(r), .s0(s0), .s1(s1), .s2(s2), .s3(s3), .s4(s4), .m(m));

   SMCTL cadr_smctl(.mr(mr), .sr(sr), .mskr(mskr), .s0(s0), .s1(s1), .s2(s2), .s3(s3), .s4(s4), .mskl(mskl), .irbyte(irbyte), .ir(ir), .sh3(sh3), .sh4(sh4));

`define _source
`ifdef _source
   SOURCE cadr_source(.ir(ir), .iralu(iralu), .irbyte(irbyte), .destimod0(destimod0), .iwrited(iwrited), .idebug(idebug), .specalu(specalu), .nop(nop), .irdisp(irdisp), .irjump(irjump), .funct(funct), .div(div), .mul(mul), .srcq(srcq), .srcopc(srcopc), .srcpdltop(srcpdltop), .srcpdlpop(srcpdlpop), .srcpdlidx(srcpdlidx), .srcpdlptr(srcpdlptr), .srcspc(srcspc), .srcdc(srcdc), .srcspcpop(srcspcpop), .srclc(srclc), .srcmd(srcmd), .srcmap(srcmap), .srcvma(srcvma), .imod(imod), .destmem(destmem), .destvma(destvma), .destmdr(destmdr), .dest(dest), .destm(destm), .destintctl(destintctl), .destlc(destlc), .destimod1(destimod1), .destspc(destspc), .destpdlp(destpdlp), .destpdlx(destpdlx), .destpdl_x(destpdl_x), .destpdl_p(destpdl_p), .destpdltop(destpdltop));
`else
   // page SOURCE

   assign {irbyte,irdisp,irjump,iralu} =
	  nop ? 4'b0000 :
		({ir[44],ir[43]} == 2'b00) ? 4'b0001 :
		({ir[44],ir[43]} == 2'b01) ? 4'b0010 :
		({ir[44],ir[43]} == 2'b10) ? 4'b0100 :
	                                     4'b1000 ;

   assign funct = 
	  nop ? 4'b0000 :
		({ir[11],ir[10]} == 2'b00) ? 4'b0001 :
		({ir[11],ir[10]} == 2'b01) ? 4'b0010 :
		({ir[11],ir[10]} == 2'b10) ? 4'b0100 :
	                                     4'b1000 ;

   assign specalu  = ir[8] & iralu;

   assign {div,mul} =
		     ~specalu ? 2'b00 :
   		     ({ir[4],ir[3]} == 2'b00) ? 2'b01 : 2'b10;

   assign {srcq,srcopc,srcpdltop,srcpdlpop,
	   srcpdlidx,srcpdlptr,srcspc,srcdc} =
	  (~ir[31] | ir[29]) ? 8'b00000000 :
		({ir[28],ir[27],ir[26]} == 3'b000) ? 8'b00000001 :
		({ir[28],ir[27],ir[26]} == 3'b001) ? 8'b00000010 :
		({ir[28],ir[27],ir[26]} == 3'b010) ? 8'b00000100 :
		({ir[28],ir[27],ir[26]} == 3'b011) ? 8'b00001000 :
		({ir[28],ir[27],ir[26]} == 3'b100) ? 8'b00010000 :
		({ir[28],ir[27],ir[26]} == 3'b101) ? 8'b00100000 :
		({ir[28],ir[27],ir[26]} == 3'b110) ? 8'b01000000 :
		                                     8'b10000000;

   assign {srcspcpop,srclc,srcmd,srcmap,srcvma} =
	  (~ir[31] | ~ir[29]) ? 5'b00000 :
		({ir[28],ir[27],ir[26]} == 3'b000) ? 5'b00001 :
		({ir[28],ir[27],ir[26]} == 3'b001) ? 5'b00010 :
		({ir[28],ir[27],ir[26]} == 3'b010) ? 5'b00100 :
		({ir[28],ir[27],ir[26]} == 3'b011) ? 5'b01000 :
		({ir[28],ir[27],ir[26]} == 3'b100) ? 5'b10000 :
		                                     5'b00000 ;

   assign imod = destimod0 | destimod1 | iwrited | idebug;

   assign destmem = destm & ir[23];
   assign destvma = destmem & ~ir[22];
   assign destmdr = destmem & ir[22];

   assign dest = iralu | irbyte;	/* destination field is valid */
   assign destm = dest & ~ir[25];	/* functional destination */

   assign {destintctl,destlc} =
	  !(destm & ~ir[23] & ~ir[22]) ? 2'b00 :
		({ir[21],ir[20],ir[19]} == 3'b001) ? 2'b01 :
		({ir[21],ir[20],ir[19]} == 3'b010) ? 2'b10 :
		                                     2'b00 ;

   assign {destimod1,destimod0,destspc,destpdlp,
	   destpdlx,destpdl_x,destpdl_p,destpdltop} =
	  !(destm & ~ir[23] & ir[22]) ? 8'b00000000 :
		({ir[21],ir[20],ir[19]} == 3'b000) ? 8'b00000001 :
		({ir[21],ir[20],ir[19]} == 3'b001) ? 8'b00000010 :
		({ir[21],ir[20],ir[19]} == 3'b010) ? 8'b00000100 :
		({ir[21],ir[20],ir[19]} == 3'b011) ? 8'b00001000 :
		({ir[21],ir[20],ir[19]} == 3'b100) ? 8'b00010000 :
		({ir[21],ir[20],ir[19]} == 3'b101) ? 8'b00100000 :
		({ir[21],ir[20],ir[19]} == 3'b110) ? 8'b01000000 :
		({ir[21],ir[20],ir[19]} == 3'b111) ? 8'b10000000 :
		                                     8'b00000000;

`endif

`define _spc
`ifdef _spc
   SPC cadr_spc(.clk(clk), .reset(reset), .spcnt(spcnt), .state_fetch(state_fetch), .spush(spush), .spcptr(spcptr));
`else   
   // page SPC

   // orig rtl:
   //  pop  = read[p], decr p
   //  push = incr p, write[p]

   // spcpop = read[spcptr] (state_write), spcptr-- (state_fetch)
   // spcpush = write[spcptr+1] (state_write), spcptr++ (state_fetch)

   wire [4:0] spcptr_p1;

   assign spcptr_p1 = spcptr + 5'b00001;

`define old_spc
`ifdef old_spc
   wire [4:0] spcadr;
   assign spcadr = (spcnt && spush) ? spcptr_p1 : spcptr;
`else
   reg [4:0] spcadr;

   always @(posedge clk)
     if (reset)
       spcadr <= 0;
     else
//       if (state_read)
	 spcadr <= (spcnt && spush) ? spcptr_p1 : spcptr;
`endif
   
   part_32x19dpram i_SPC(
			 .reset(reset),

			 .clk_a(clk),
			 .address_a(spcptr),
			 .data_a(19'b0),
			 .q_a(spco),
			 .wren_a(1'b0),
			 .rden_a(srp && ~swp),

			 .clk_b(clk),
			 .address_b(spcadr),
			 .data_b(spcw),
			 .q_b(),
			 .wren_b(swp),
			 .rden_b(1'b0)
		       );
   
   always @(posedge clk)
     if (reset)
       spcptr <= 0;
     else
       if (state_fetch)
	 begin
	    if (spcnt)
	      begin
		 if (spush)
		   spcptr <= spcptr + 5'd1;
		 else
		   spcptr <= spcptr - 5'd1;
	      end
	 end
`endif

   SPCLCH cadr_spclch(.spc(spc), .spco(spco));

   // page SPCPAR -- empty
   
   SPCW cadr_spcw(.destspc(destspc), .l(l), .reta(reta), .spcw(spcw), .n(n), .ipc(ipc), .wpc(wpc));

   SPY12 cadr_spy12(.clk(clk), .reset(reset), .spy_out(spy_out), .ir(ir), .state_write(state_write), .spy_mdh(spy_mdh), .spy_vmah(spy_vmah), .spy_vmal(spy_vmal), .spy_obh_(spy_obh_), .spy_obl_(spy_obl_), .md(md), .vma(vma), .ob(ob), .opc(opc), .waiting(waiting), .boot(boot), .promdisable(promdisable), .stathalt(stathalt), .dbread(dbread), .nop(nop), .spy_obh(spy_obh), .spy_obl(spy_obl), .spy_pc(spy_pc), .spy_opc(spy_opc), .spy_scratch(spy_scratch), .spy_irh(spy_irh), .spy_irm(spy_irm), .spy_irl(spy_irl), .spy_disk(spy_disk), .spy_bd(spy_bd), .pc(pc), .err(err), .scratch(scratch), .spy_sth(spy_sth), .spy_stl(spy_stl), .spy_ah(spy_ah), .spy_al(spy_al), .spy_mh(spy_mh), .spy_ml(spy_ml), .spy_flag2(spy_flag2), .spy_flag1(spy_flag1), .m(m), .a(a), .bd_state_in(bd_state_in), .wmap(wmap), .ssdone(ssdone), .vmaok(vmaok), .destspc(destspc), .jcond(jcond), .srun(srun), .pcs1(pcs1), .pcs0(pcs0), .iwrited(iwrited), .imod(imod), .pdlwrite(pdlwrite), .spush(spush));

   TRAP cadr_trap(.trap(trap), .boot_trap(boot_trap));

`define _vctrl1
`ifdef _vctrl1
   VCTRL1 cadr_vctrl1(.clk(clk), .reset(reset), .lcinc(lcinc), .memrq(memrq), .ifetch(ifetch), .lvmo_22(lvmo_22), .lvmo_23(lvmo_23), .mbusy(mbusy), .memack(memack), .memcheck(memcheck), .memprepare(memprepare), .memrd(memrd), .memstart(memstart), .memwr(memwr), .needfetch(needfetch), .pfr(pfr), .pfw(pfw), .srcyc(srcyc), .state_alu(state_alu), .state_fetch(state_fetch), .state_prefetch(state_prefetch), .state_write(state_write), .vmaok(vmaok), .rdcyc(rdcyc), .wrcyc(wrcyc), .mfinish(mfinish), .waiting(waiting));
   
`else
   // page VCTRL1

   assign memop  = memrd | memwr | ifetch;

   always @(posedge clk)
     if (reset)
       memprepare <= 0;
     else
       if (state_alu || state_write)
	 memprepare <= memop;
       else
	 memprepare <= 0;

   // read vmem
   always @(posedge clk)
     if (reset)
       memstart <= 0;
     else
       if (~state_alu)
	 memstart <= memprepare;
       else
	 memstart <= 0;

   // check result of vmem
   always @(posedge clk)
     if (reset)
       memcheck <= 0;
     else
       memcheck <= memstart;

   assign pfw = (lvmo_23 & lvmo_22) & wrcyc;	/* write permission */
   assign pfr = lvmo_23 & ~wrcyc;		/* read permission */

   always @(posedge clk)
     if (reset)
       vmaok <= 1'b0;
     else
       if (memcheck)
	 vmaok <= pfr | pfw;
    
   always @(posedge clk)
     if (reset)
       begin
	  rdcyc <= 0;
	  wrcyc <= 0;
       end
     else
       if ((state_fetch || state_prefetch) && memstart && memcheck)
	 begin
	    if (memwr)
	      begin
		 rdcyc <= 0;
		 wrcyc <= 1;
	      end
	    else
	      begin
		 rdcyc <= 1;
		 wrcyc <= 0;
	      end
	 end
       else
	 if ((~memrq && ~memprepare && ~memstart) || mfinish)
	   begin
	      rdcyc <= 0;
	      wrcyc <= 0;
	   end

   assign memrq = mbusy | (memcheck & ~memstart & (pfr | pfw));

   always @(posedge clk)
     if (reset)
       mbusy <= 0;
     else
//       if (mfinish)
//	 mbusy <= 1'b0;
//       else
//	 mbusy <= memrq;
       if (mfinish)
	 mbusy <= 1'b0;
       else
	 if (memcheck & (pfr | pfw))
	   mbusy <= 1;

//always @(posedge clk) if (memstart) $display("memstart! %t", $time);
   

   //------

   assign mfinish = memack | reset;

   assign waiting =
		(memrq & mbusy) |
		(lcinc & needfetch & mbusy);		/* ifetch */
`endif

`define _vctrl2
`ifdef _vctrl2
   VCTRL2 cadr_vctrl2(.loadmd(loadmd), .nopa(nopa), .ir(ir), .wrcyc(wrcyc), .destmdr(destmdr), .srcmd(srcmd), .destmem(destmem), .srcmap(srcmap), .irdisp(irdisp), .memprepare(memprepare), .memstart(memstart), .destvma(destvma), .ifetch(ifetch), .state_decode(state_decode), .state_write(state_write), .state_read(state_read), .state_mmu(state_mmu), .mapwr0(mapwr0), .mapwr1( mapwr1), .vm0wp(vm0wp), .vm1wp(vm1wp), .wmap(wmap), .memwr(memwr), .memrd(memrd), .vma(vma), .dmapbenb(dmapbenb), .dispwr(dispwr));
`else
   // page VCTRL2

   /*
    * for memory cycle, we run mmu state and map vma during state_write & state_mmu
    * for dispatch,     we don't run mmy state and map md early
    *                   so dispatch ram has a chance to read and register during write state
    *
    * dispatch ram output has to be valid during fetch cycle to get npc correct
    */

   assign mapwr0 = wmap & vma[26];
   assign mapwr1 = wmap & vma[25];

   wire   early_vm0_rd;
   wire   early_vm1_rd;

   wire   normal_vm0_rd;
   wire   normal_vm1_rd;

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
`endif

   VMA cadr_vma(.clk(clk), .reset(reset), .state_alu(state_alu), .state_write(state_write), .state_fetch(state_fetch), .vmaenb(vmaenb), .vmas(vmas), .spy_in(spy_in), .srcvma(srcvma), .ldvmal(ldvmal), .ldvmah(ldvmah), .vma(vma), .vmadrive(vmadrive));

   VMAS cadr_vmas(.vmas(vmas), .mapi(mapi), .vmasel(vmasel), .ob(ob), .memprepare(memprepare), .md(md), .vma(vma), .lc(lc));

   VMEM0 cadr_vmem0(.clk(clk), .reset(reset), .vmem0_adr(vmem0_adr), .mapi(mapi), .vmap(vmap), .vm0rp(vm0rp), .vma(vma), .use_map(use_map), .srcmap(srcmap), .memstart(memstart), .vm0wp(vm0wp));

   VMEM12 cadr_vmem12(.clk(clk), .reset(reset), .vmem1_adr(vmem1_adr), .vmap(vmap), .mapi(mapi), .vma(vma), .vmo(vmo), .vm1rp(vm1rp), .vm1wp(vm1wp));

   VMEMDR cadr_vmemdr(.vmo(vmo), .srcmap(srcmap), .state_alu(state_alu), .state_write(state_write), .state_mmu(state_mmu), .state_fetch(state_fetch), .lvmo_23(lvmo_23), .lvmo_22(lvmo_22), .mapdrive(mapdrive), .pma(pma));

   DEBUG cadr_debug(.clk(clk), .reset(reset), .spy_ir(spy_ir), .spy_in(spy_in), .i(i), .idebug(idebug), .promenable(promenable), .iprom(iprom), .iram(iram), .lddbirh(lddbirh), .lddbirm(lddbirm), .lddbirl(lddbirl));

   wire   iwe;
   ICTL cadr_ictl(.ramdisable(ramdisable), .idebug(idebug), .promdisabled(promdisabled), .iwrited(iwrited), .state_write(state_write), .iwe(iwe));

`define _olord1
`ifdef _olord1
   OLORD1 cadr_olord1(.clk(clk), .reset(reset), .ldmode(ldmode), .ldscratch1(ldscratch1), .ldscratch2(ldscratch2), .ldclk(ldclk), .boot(boot), .run(run), .step(step), .promdisable(promdisable), .trapenb(trapenb), .stathenb(stathenb), .errstop(errstop), .scratch(scratch), .opcinh(opcinh), .opcclk(opcclk), .lpc_hold(lpc_hold), .ldstat(ldstat), .idebug(idebug), .nop11(nop11), .srun( srun), .sstep(sstep), .ssdone(ssdone), .promdisabled(promdisabled), .machrun(machrun), .stat_ovf(stat_ovf), .stathalt(stathalt), .errhalt(errhalt), .state_fetch(state_fetch), .statstop(statstop), .spy_in(spy_in), .ldopc(ldopc), .set_promdisable(set_promdisable), .waiting(waiting));
`else
   // page OLORD1 

   always @(posedge clk)
     if (reset)
       begin
	  promdisable <= 0;
	  trapenb <= 0;
	  stathenb <= 0;
	  errstop <= 0;
       end
     else
       if (ldmode)
	 begin
	    promdisable <= spy_in[5];
	    trapenb <= spy_in[4];
	    stathenb <= spy_in[3];
	    errstop <= spy_in[2];
	    //speed1 <= spy_in[1];
	    //speed0 <= spy_in[0];
	 end
       else
	 if (set_promdisable)
	   promdisable <= 1;

   always @(posedge clk)
     if (reset)
       begin
	  scratch <= 16'h1234;
       end
     else
       if (ldscratch2 || ldscratch1)
	 begin
	    scratch <= spy_in;
	 end
	   
   always @(posedge clk)
     if (reset)
       begin
	  opcinh <= 0;
	  opcclk <= 0;
	  lpc_hold <= 0;
       end
     else
       if (ldopc)
	 begin
	    opcinh <= spy_in[2];
	    opcclk <= spy_in[1];
	    lpc_hold <= spy_in[0];
	 end

   always @(posedge clk)
     if (reset)
       begin
	  ldstat <= 0;
	  idebug <= 0;
	  nop11 <= 0;
	  step <= 0;
       end
     else
       if (ldclk)
	 begin
	    ldstat <= spy_in[4];
	    idebug <= spy_in[3];
	    nop11 <= spy_in[2];
	    step <= spy_in[1];
	 end

   always @(posedge clk)
     if (reset)
       run <= 1'b0;
     else
       if (boot)
	 run <= 1'b1;
       else
	 if (ldclk)
	   run <= spy_in[0];

   always @(posedge clk)
     if (reset)
       begin
	  srun <= 1'b0;
	  sstep <= 1'b0;
	  ssdone <= 1'b0;
	  promdisabled <= 1'b0;
       end
     else
       begin
	  srun <= run;
//	  sstep <= step;
//	  ssdone <= sstep;
if (sstep == 0 && step) begin
   sstep <= step;
   ssdone <= 0;
end
else
  sstep <= step;
if (state_fetch) ssdone <= sstep;
	  promdisabled <= promdisable;
       end

   assign machrun = (sstep & ~ssdone) |
		    (srun & ~errhalt & ~waiting & ~stathalt);

   assign stat_ovf = 1'b0;
   assign stathalt = statstop & stathenb;
`endif


`define _olord2
`ifdef _olord2
   OLORD2 cadr_olord2(.clk(clk), .reset(reset), .statstop(statstop), .halted(halted), .prog_reset(prog_reset), .err(err), .errhalt(errhalt), .prog_bus_reset(prog_bus_reset), .bus_reset(bus_reset), .prog_boot(prog_boot), .boot(boot), .boot_trap(boot_trap), .ldmode(ldmode), .spy_in(spy_in), .errstop(errstop), .ext_reset(ext_reset), .ext_boot(ext_boot), .srun(srun), .ext_halt(ext_halt), .stat_ovf(stat_ovf));
`else
   // page OLORD2

   always @(posedge clk)
     if (reset)
       begin
	  halted <= 0;
	  statstop <= 0;
       end
     else
       begin
	  halted <= ext_halt;
	  statstop <= stat_ovf;
       end
   
   assign prog_reset = ldmode & spy_in[6];

   assign reset = ext_reset | prog_reset;

   assign err = halted;

   assign errhalt = errstop & err;

   // external
   assign prog_bus_reset = 0;

   assign bus_reset  = prog_bus_reset | ext_reset;

   // external

   assign prog_boot = ldmode & spy_in[7];

   assign boot  = ext_boot | prog_boot;

   always @(posedge clk)
     if (reset)
       boot_trap <= 0;
     else
       if (boot)
	 boot_trap <= 1'b1;
       else
	 if (srun)
           boot_trap <= 1'b0;
`endif

   OPCS cadr_opcs(.clk(clk), .reset(reset), .state_fetch(state_fetch), .opcclk(opcclk), .opcinh(opcinh), .opc(opc), .pc(pc));

   // With the machine stopped, taking OPCCLK high then low will
   // generate a clock to just the OPCS.
   // Setting OPCINH high will prevent the OPCS from clocking when
   // the machine runs.  Only change OPCINH when CLK is high 
   // (e.g. machine stopped).

   PCTL cadr_pctl(.pc(pc), .idebug(idebug), .promdisabled(promdisabled), .iwrited(iwrited), .prompc(prompc), .bottom_1k(bottom_1k), .promenable(promenable), .promce(promce), .promaddr(promaddr));

   PROM0 cadr_prom0(.clk(clk), .promaddr(promaddr), .iprom(iprom));

`define _iram
`ifdef _iram
   IRAM cadr_iram(.clk(clk), .reset(reset), .pc(pc), .pc_out(pc_out), .state_out(state_out), .iwr(iwr), .iwe(iwe), .iram(iram), .fetch_out(fetch_out), .prefetch_out(prefetch_out), .machrun_out(machrun_out), .mcr_data_in(mcr_data_in), .state_fetch(state_fetch), .machrun(machrun), .state(state));
`else
   // page IRAM
`ifdef use_ucode_ram
   part_16kx49ram i_IRAM(
			 .clk_a(clk),
			 .reset(reset),
			 .address_a(pc),
			 .q_a(iram),
			 .data_a(iwr),
			 .wren_a(iwe),
			 .rden_a(1'b1/*ice*/)
			 );

   assign fetch_out = 0;
   assign prefetch_out = 0;
`else
   // use top level ram controller
   assign mcr_addr = pc;
   assign iram = mcr_data_in;
   assign mcr_data_out = iwr;
   assign mcr_write = iwe;

   // for externals
   assign fetch_out = state_fetch && promdisabled;
   assign prefetch_out = ((need_mmu_state ? state_mmu : state_write) || state_prefetch) &&
			 promdisabled;
`endif

   assign pc_out = pc;
   assign state_out = state;
   assign machrun_out = machrun;
`endif
   
   SPY0 cadr_spy0(.spy_obh(spy_obh), .spy_obl(spy_obl), .spy_pc(spy_pc), .spy_opc(spy_opc), .spy_scratch(spy_scratch), .spy_irh(spy_irh), .spy_irm(spy_irm), .spy_irl(spy_irl), .spy_sth(spy_sth), .spy_stl(spy_stl), .spy_ah(spy_ah), .spy_al(spy_al), .spy_mh(spy_mh), .spy_ml(spy_ml), .spy_flag2(spy_flag2), .spy_flag1(spy_flag1), .ldscratch2(dscratch2), .ldscratch1(ldscratch1), .ldmode(ldmode), .ldopc(ldopc), .ldclk(ldclk), .lddbirh(lddbirh), .lddbirm(lddbirm), .lddbirl(lddbirl), .eadr(eadr), .dbread(dbread), .dbwrite(dbwrite), .spy_mdl(spy_mdl), .spy_vmal(spy_vmal), .spy_vmah(spy_vmah), .spy_mdh(spy_mdh), .spy_disk(spy_disk), .spy_bd(spy_bd));
   
   // *************
   // Bus Interface
   // *************

   wire [21:0] busint_addr;
   assign busint_addr = {pma, vma[7:0]};
   
   busint busint(
		 .mclk(clk),
		 .reset(reset),
		 .addr(busint_addr),
		 .busin(md),
		 .busout(busint_bus),
		 .spyin(spy_in),
		 .spyout(busint_spyout),
		 .spyreg(spy_reg),
		 .spyrd(spy_rd),
		 .spywr(spy_wr),
		 
		 .req(memrq),
		 .ack(memack),
		 .write(wrcyc),
		 .load(loadmd),
		 
		 .interrupt(bus_int),

		 .sdram_addr(sdram_addr),
		 .sdram_data_in(sdram_data_in),
		 .sdram_data_out(sdram_data_out),
		 .sdram_req(sdram_req),
		 .sdram_ready(sdram_ready),
		 .sdram_write(sdram_write),
		 .sdram_done(sdram_done),
      
		 .vram_addr(vram_addr),
		 .vram_data_in(vram_data_in),
		 .vram_data_out(vram_data_out),
		 .vram_req(vram_req),
		 .vram_ready(vram_ready),
		 .vram_write(vram_write),
		 .vram_done(vram_done),
		 
		 .bd_cmd(bd_cmd),
		 .bd_start(bd_start),
		 .bd_bsy(bd_bsy),
		 .bd_rdy(bd_rdy),
		 .bd_err(bd_err),
		 .bd_addr(bd_addr),
		 .bd_data_in(bd_data_in),
		 .bd_data_out(bd_data_out),
		 .bd_rd(bd_rd),
		 .bd_wr(bd_wr),
		 .bd_iordy(bd_iordy),
		 .bd_state_in(bd_state_in),

		 .kb_data(kb_data),
		 .kb_ready(kb_ready),
		 .ms_x(ms_x),
		 .ms_y(ms_y),
		 .ms_button(ms_button),
		 .ms_ready(ms_ready),

		 .promdisable(set_promdisable),
		 .disk_state(disk_state_out),
		 .bus_state(bus_state_out)
		 );


   assign disk_state_in = busint.disk.state;
   
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
		   busint.disk.state, //5  127
		   bd_state_in,       //12
		   state_decode,      //1
		   lpc,		      //14
		   a,		      //32
		   m,		      //32
		   md		      //32 0
		   };

   chipscope_icon_caddr icon1 (.CONTROL0(control0));
   chipscope_ila_caddr ila1 (.CONTROL(control0), .CLK(clk), .TRIG0(trig0));
`endif
   
endmodule

