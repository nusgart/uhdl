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
   input	 dbread;
   input	 dbwrite;
   input [4:0]	 eadr;

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

   output [31:0] md;
   output	 memrq;
   output	 wrcyc;
   output [31:0] vma;
   output [21:8] pma;

   input [11:0]  bd_state_in;
   input [4:0]	 disk_state_in;

   input	 loadmd;		/* data available from busint */
   input [31:0]  busint_bus;
   input	 bus_int;
   input	 memack;
   input	 set_promdisable;

   // ------------------------------------------------------------

`ifdef debug
   integer	 debug;
`endif

   // ------------------------------------------------------------

   // ACTL
   wire [9:0]	 aadr;
   wire [9:0]	 wadr;
   wire		 arp;
   wire		 awp;

   // ALATCH
   wire [31:0]	 a;

   // ALU01
   wire [32:0]	 alu;
   wire		 aeqm;
   wire		 xout3, xout7, xout11, xout15, xout19, xout23, xout27, xout31;
   wire		 yout3, yout7, yout11, yout15, yout19, yout23, yout27, yout31;

   // ALUC4
   wire [1:0]	 osel;
   wire [3:0]	 aluf;
   wire		 alumode;
   wire		 cin0;
   wire		 cin4_n, cin8_n, cin12_n, cin16_n, cin20_n, cin24_n, cin28_n, cin32_n;

   // AMEM01
   wire [31:0]	 amem;

   // CONTRL
   wire		 iwrited;
   wire		 n;
   wire		 nop;
   wire		 nopa;
   wire		 pcs0;
   wire		 pcs1;
   wire		 spcdrive;
   wire		 spcenb;
   wire		 spcnt;
   wire		 spop;
   wire		 spush;
   wire		 srcspcpopreal;
   wire		 srp;
   wire		 swp;

   // DRAM02
   wire [13:0]	 dpc;
   wire		 dn;
   wire		 dp;
   wire		 dr;

   // DSPCTL
   wire [6:0]	 dmask;
   wire [9:0]	 dc;
   wire		 dispwr;
   wire		 dmapbenb;

   // FLAG
   wire		 int_enable;
   wire		 jcond;
   wire		 lc_byte_mode;
   wire		 prog_unibus_reset;
   wire		 sequence_break;

   // IOR
   wire [47:0]	 iob;

   // IREG
   wire [48:0]	 ir;

   // IWR
   wire [48:0]	 iwr;

   // LCC
   wire		 ifetch;
   wire		 lc0b;
   wire		 lcinc;
   wire		 needfetch;
   wire		 sh3;
   wire		 sh4;
   wire		 sintr;
   wire		 spc1a;

   // LC
   wire [25:0]	 lc;
   wire [31:0]	 mf;
   wire [3:0]	 lca;

   // LPC
   wire [13:0]	 wpc;

   // L
   wire [31:0]	 l;

   // MCTL
   wire [4:0]	 madr;
   wire		 mpassm;
   wire		 mrp;
   wire		 mwp;
   wire		 srcm;

   // MDS
   wire [31:0]	 mds;

   // MD
   wire [31:0]	 md;
   wire		 mddrive;
   wire		 mdgetspar;

   // MF
   wire		 mfdrive;

   // MLATCH
   wire [31:0]	 m;

   // MMEM
   wire [31:0]	 mmem;

   // MO01
   wire [31:0]	 ob;

   // MSKG4
   wire [31:0]	 msk;

   // NPC
   wire [13:0]	 ipc;
   wire [13:0]	 pc;

   // OPCD
   wire		 dcdrive;
   wire		 opcdrive;

   // PDL01
   wire [31:0]	 pdl;

   // PDLCTL
   wire [9:0]	 pdla;
   wire		 pdlcnt;
   wire		 pdldrive;
   wire		 pdlenb;
   wire		 pdlwrite;
   wire		 prp;
   wire		 pwp;

   // PDLPTR
   wire [9:0]	 pdlidx;
   wire [9:0]	 pdlptr;
   wire		 pidrive;
   wire		 ppdrive;

   // Q
   wire [31:0]	 q;
   wire		 qdrive;

   // SHIFT01
   wire [31:0]	 r;

   // SMCTL
   wire [4:0]	 mskl;
   wire [4:0]	 mskr;
   wire		 s0;
   wire		 s1;
   wire		 s2;
   wire		 s3;
   wire		 s4;

   // SOURCE
   wire [3:0]	 funct;
   wire		 dest;
   wire		 destimod0;
   wire		 destimod1;
   wire		 destintctl;
   wire		 destlc;
   wire		 destm;
   wire		 destmdr;
   wire		 destmem;
   wire		 destpdl_p;
   wire		 destpdl_x;
   wire		 destpdlp;
   wire		 destpdltop;
   wire		 destpdlx;
   wire		 destspc;
   wire		 destvma;
   wire		 div;
   wire		 imod;
   wire		 iralu;
   wire		 irbyte;
   wire		 irdisp;
   wire		 irjump;
   wire		 mul;
   wire		 srcdc;
   wire		 srclc;
   wire		 srcmap;
   wire		 srcmd;
   wire		 srcopc;
   wire		 srcpdlidx;
   wire		 srcpdlpop;
   wire		 srcpdlptr;
   wire		 srcpdltop;
   wire		 srcq;
   wire		 srcspc;
   wire		 srcspcpop;
   wire		 srcvma;

   // SPCLCH
   wire [18:0]	 spc;

   // SPC
   wire [18:0]	 spco;
   wire [4:0]	 spcptr;

   // SPCW
   wire [18:0]	 spcw;

   // SPY124
   wire [15:0]	 spy_out;

   // TRAP
   wire		 trap;

   // VCTL1
   wire		 memprepare;
   wire		 memrq;
   wire		 memstart;
   wire		 pfr;
   wire		 pfw;
   wire		 vmaok;
   wire		 waiting;
   wire		 wrcyc;

   // VCTL2
   wire		 mdsel;
   wire		 memdrive;
   wire		 memrd;
   wire		 memwr;
   wire		 vm0rp;
   wire		 vm0wp;
   wire		 vm1rp;
   wire		 vm1wp;
   wire		 vmaenb;
   wire		 vmasel;
   wire		 wmap;

   // VMAS
   wire [23:8]	 mapi;
   wire [31:0]	 vmas;

   // VMA
   wire [31:0]	 vma;;
   wire		 vmadrive;

   // VMEM0
   wire [4:0]	 vmap;

   // VMEM12
   wire [23:0]	 vmo;

   // VMEMDR
   wire [21:8]	 pma;
   wire		 lvmo_22;
   wire		 lvmo_23;
   wire		 mapdrive;

   // DEBUG
   wire [48:0]	 i;

   // ICTL
   wire		 iwe;

   // IRAM
   wire [13:0]	 pc_out;
   wire [48:0]	 iram;
   wire [5:0]	 state_out;
   wire		 fetch_out;
   wire		 machrun_out;
   wire		 prefetch_out;

   // OLORD1
   wire [15:0]	 scratch;
   wire		 errstop;
   wire		 idebug;
   wire		 lpc_hold;
   wire		 machrun;
   wire		 nop11;
   wire		 opcclk;
   wire		 opcinh;
   wire		 promdisable;
   wire		 promdisabled;
   wire		 srun;
   wire		 ssdone;
   wire		 stat_ovf;
   wire		 stathalt;

   // OLORD2
   wire		 boot;
   wire		 boot_trap;
   wire		 err;
   wire		 errhalt;
   wire		 reset;
   wire		 statstop;

   // OPCS
   wire [13:0]	 opc;

   // PCTL
   wire [8:0]	 promaddr;
   wire		 promenable;

   // PROM01
   wire [48:0]	 iprom;

   // SPY0
   wire		 ldclk;
   wire		 lddbirh;
   wire		 lddbirl;
   wire		 lddbirm;
   wire		 ldmdh;
   wire		 ldmdl;
   wire		 ldmode;
   wire		 ldopc;
   wire		 ldscratch1;
   wire		 ldscratch2;
   wire		 ldvmah;
   wire		 ldvmal;
   wire		 spy_ah;
   wire		 spy_al;
   wire		 spy_bd;
   wire		 spy_disk;
   wire		 spy_flag1;
   wire		 spy_flag2;
   wire		 spy_irh;
   wire		 spy_irl;
   wire		 spy_irm;
   wire		 spy_mdh;
   wire		 spy_mdl;
   wire		 spy_mh;
   wire		 spy_ml;
   wire		 spy_obh;
   wire		 spy_obh_;
   wire		 spy_obl;
   wire		 spy_obl_;
   wire		 spy_opc;
   wire		 spy_pc;
   wire		 spy_scratch;
   wire		 spy_sth;
   wire		 spy_stl;
   wire		 spy_vmah;
   wire		 spy_vmal;

   // *******************************************************************
   // Main CPU state machine.

   parameter STATE_RESET  = 6'b000000;
   parameter STATE_DECODE = 6'b000001;
   parameter STATE_READ   = 6'b000010;
   parameter STATE_ALU    = 6'b000100;
   parameter STATE_WRITE  = 6'b001000;
   parameter STATE_MMU    = 6'b010000;
   parameter STATE_FETCH  = 6'b100000;

   reg [5:0]	 state;
   wire [5:0]	 next_state;
   wire		 state_decode, state_read, state_alu, state_write, state_fetch;
   wire		 state_mmu, state_prefetch;

   always @(posedge clk)
     if (reset)
       state <= STATE_RESET;
     else
       state <= next_state;

   wire		 need_mmu_state;
   assign need_mmu_state = memprepare | wmap | srcmap;

   wire		 mcr_hold;
`define use_ucode_ram
`ifdef use_ucode_ram
   assign mcr_hold = 0;
`else
   assign mcr_hold = promdisabled && ~mcr_ready;
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

   // *******************************************************************

   ACTL cadr_actl(.clk, .reset, .state_decode, .state_write, .wadr, .destm, .awp, .arp, .aadr, .ir, .dest);

   ALATCH cadr_alatch(.a, .amem);

   ALU01 cadr_alu01(.a, .m, .aluf, .alumode, .aeqm, .alu, .cin12_n, .cin16_n, .cin20_n, .cin24_n, .cin28_n, .cin32_n, .cin4_n, .cin8_n, .cin0, .xout11, .xout15, .xout19, .xout23, .xout27, .xout3, .xout31, .xout7, .yout11, .yout15, .yout19, .yout23, .yout27, .yout3, .yout31, .yout7);

   ALUC4 cadr_aluc4(.yout15, .yout11, .yout7, .yout3, .xout15, .xout11, .xout7, .xout3, .yout31, .yout27, .yout23, .yout19, .xout31, .xout27, .xout23, .xout19, .a, .ir, .iralu, .irjump, .mul, .div, .q, .osel, .aluf, .alumode, .cin12_n, .cin8_n, .cin4_n, .cin0, .cin28_n, .cin24_n, .cin20_n, .cin16_n, .cin32_n);

   AMEM01 cadr_amem01(.amem, .clk, .reset, .aadr, .awp, .arp, .l);

   CONTRL cadr_contrl(.clk, .reset, .iwrited, .nopa, .pcs0, .pcs1, .spcdrive, .spcenb, .spcnt, .spop, .spush, .srcspcpopreal, .srp, .swp, .dr, .dp, .irdisp, .funct, .irjump, .ir, .srcspcpop, .jcond, .destspc, .state_write, .srcspc, .state_alu, .state_fetch, .trap, .dn, .nop11, .n, .nop);

   DRAM02 cadr_dram02(.clk, .reset, .a, .ir, .vmo, .dmask, .r, .dr, .dp, .dn, .dpc, .dispwr, .state_write, .state_prefetch);

   DSPCTL cadr_dspctl(.clk, .reset, .state_fetch, .irdisp, .funct, .ir, .dmask, .dmapbenb, .dispwr, .dc);

   FLAG cadr_flag(.clk, .reset, .ir, .nopa, .aeqm, .sintr, .int_enable, .vmaok, .sequence_break, .alu, .lc_byte_mode, .prog_unibus_reset, .ob, .r, .state_fetch, .destintctl, .jcond);

   IOR cadr_ior(.iob, .i, .ob);

   IREG cadr_ireg(.clk, .reset, .i, .iob, .ir, .state_fetch, .destimod1, .destimod0);

   IWR cadr_iwr(.clk, .reset, .state_fetch, .iwr, .a, .m);

   L cadr_l(.clk, .reset, .vmaenb, .state_write, .state_alu, .ob, .l);

   LC cadr_lc(.clk, .reset, .destlc, .lca, .lcinc, .lc_byte_mode, .lc, .srclc, .state_alu, .state_write, .state_mmu, .state_fetch, .ob, .opcdrive, .opc, .dcdrive, .dc, .pdlptr, .pidrive, .pdlidx, .qdrive, .q, .mddrive, .md, .vmadrive, .vma, .mapdrive, .pfw, .needfetch, .int_enable, .prog_unibus_reset, .sequence_break, .lc0b, .ppdrive, .vmap, .pfr, .vmo, .mf);

   LCC cadr_lcc(.clk, .reset, .state_fetch, .lc0b, .needfetch, .ifetch, .spc1a, .sh4, .sh3, .sintr, .lc, .lc_byte_mode, .spop, .srcspcpopreal, .spc, .lcinc, .destlc, .irdisp, .ir, .ext_int, .bus_int);

   LPC cadr_lpc(.clk, .reset, .lpc_hold, .pc, .wpc, .irdisp, .ir, .state_fetch);

   MCTL cadr_mctl(.mpassm, .srcm, .mrp, .mwp, .madr, .ir, .destm, .wadr, .state_decode, .state_write);

   MD cadr_md(.clk, .reset, .md, .mddrive, .spy_in, .loadmd, .memrq, .destmdr, .mds, .srcmd, .state_alu, .state_write, .state_mmu, .state_fetch, .ldmdh, .ldmdl);

   MDS cadr_mds(.mds, .mdsel, .ob, .memdrive, .loadmd, .busint_bus, .md);

   MF cadr_mf(.mfdrive, .srcm, .spcenb, .pdlenb, .state_alu, .state_write, .state_mmu, .state_fetch);

   MLATCH cadr_mlatch(.pdldrive, .spcdrive, .mfdrive, .mmem, .pdl, .spcptr, .spco, .mf, .m, .mpassm);

   MMEM cadr_mmem(.clk, .reset, .mrp, .mwp, .madr, .l, .mmem);

   MO01 cadr_mo01(.msk, .r, .a, .alu, .q, .osel, .ob);

   MSKG4 cadr_mskg4(.clk, .mskl, .mskr, .msk);

   NPC cadr_npc(.clk, .reset, .state_fetch, .ipc, .trap, .pcs1, .pcs0, .ir, .spc, .spc1a, .dpc, .pc);

   OPCD cadr_opcd(.dcdrive, .opcdrive, .srcdc, .srcopc, .state_alu, .state_write, .state_mmu, .state_fetch);

   PDL01 cadr_pdl01(.clk, .reset, .prp, .pdla, .l, .pwp, .pdl);

   PDLCTL cadr_pdlctl(.clk, .reset, .pdlidx, .pdla, .pdlwrite, .state_alu, .state_write, .state_read, .ir, .pwp, .prp, .pdlenb, .pdldrive, .pdlcnt, .pdlptr, .destpdltop, .destpdl_x, .destpdl_p, .srcpdlpop, .state_mmu, .nop, .srcpdltop, .state_fetch);

   PDLPTR cadr_pdlptr(.clk, .reset, .pidrive, .ppdrive, .pdlidx, .pdlptr, .state_alu, .state_write, .state_fetch, .state_read, .destpdlx, .srcpdlidx, .srcpdlptr, .ob, .destpdlp, .pdlcnt, .srcpdlpop);

   Q cadr_q(.clk, .reset, .state_alu, .state_write, .state_mmu, .state_fetch, .alu, .srcq, .qdrive, .q, .ir, .iralu);

   SHIFT01 cadr_shift01(.r, .s0, .s1, .s2, .s3, .s4, .m);

   SMCTL cadr_smctl(.mskr, .s0, .s1, .s2, .s3, .s4, .sh3, .sh4, .mskl, .irbyte, .ir);

   SOURCE cadr_source(.ir, .iralu, .irbyte, .destimod0, .destimod1, .iwrited, .idebug, .nop, .irdisp, .irjump, .funct, .div, .mul, .srcq, .srcopc, .srcpdltop, .srcpdlpop, .srcpdlidx, .srcpdlptr, .srcspc, .srcdc, .srcspcpop, .srclc, .srcmd, .srcmap, .srcvma, .imod, .destmem, .destvma, .destmdr, .dest, .destm, .destintctl, .destlc, .destspc, .destpdlp, .destpdlx, .destpdl_x, .destpdl_p, .destpdltop);

   SPC cadr_spc(.clk, .reset, .spcnt, .state_fetch, .spush, .spcptr, .spco, .spcw, .srp, .swp);

   SPCLCH cadr_spclch(.spc, .spco);

   SPCW cadr_spcw(.destspc, .l, .spcw, .n, .wpc, .ipc);

   SPY124 cadr_spy124(.clk, .reset, .spy_out, .ir, .spy_mdh, .spy_mdl, .state_write, .spy_vmah, .spy_vmal, .spy_obh_, .spy_obl_, .md, .vma, .ob, .opc, .waiting, .boot, .promdisable, .stathalt, .dbread, .nop, .spy_obh, .spy_obl, .spy_pc, .spy_opc, .spy_scratch, .spy_irh, .spy_irm, .spy_irl, .spy_disk, .spy_bd, .pc, .err, .scratch, .spy_sth, .spy_stl, .spy_ah, .spy_al, .spy_mh, .spy_ml, .spy_flag2, .spy_flag1, .m, .a, .bd_state_in, .wmap, .ssdone, .vmaok, .destspc, .jcond, .srun, .pcs1, .pcs0, .iwrited, .imod, .pdlwrite, .spush, .disk_state_in);

   TRAP cadr_trap(.trap, .boot_trap);

   VCTL1 cadr_vctl1(.clk, .reset, .lcinc, .memrq, .ifetch, .lvmo_22, .lvmo_23, .memack, .memprepare, .memrd, .memstart, .memwr, .needfetch, .pfr, .pfw, .state_alu, .state_fetch, .state_prefetch, .state_write, .vmaok, .wrcyc, .waiting);

   VCTL2 cadr_vctl2(.loadmd, .nopa, .ir, .wrcyc, .destmdr, .srcmd, .destmem, .srcmap, .irdisp, .memprepare, .memstart, .destvma, .ifetch, .state_decode, .state_write, .state_read, .state_mmu, .vm0wp, .vm1wp, .wmap, .memwr, .memrd, .vma, .dmapbenb, .dispwr, .vm0rp, .vm1rp, .vmaenb, .vmasel, .memdrive, .mdsel);

   VMA cadr_vma(.clk, .reset, .state_alu, .state_write, .state_fetch, .vmaenb, .vmas, .spy_in, .srcvma, .ldvmal, .ldvmah, .vma, .vmadrive);

   VMAS cadr_vmas(.vmas, .mapi, .vmasel, .ob, .memprepare, .md, .vma, .lc);

   VMEM0 cadr_vmem0(.clk, .reset, .mapi, .vmap, .vm0rp, .vma, .srcmap, .memstart, .vm0wp);

   VMEM12 cadr_vmem12(.clk, .reset, .vmap, .mapi, .vm1rp, .vma, .vmo, .vm1wp);

   VMEMDR cadr_vmemdr(.vmo, .srcmap, .state_alu, .state_write, .state_mmu, .state_fetch, .lvmo_23, .lvmo_22, .mapdrive, .pma);

   DEBUG cadr_debug(.clk, .reset, .spy_in, .i, .idebug, .promenable, .iprom, .iram, .lddbirh, .lddbirm, .lddbirl);

   ICTL cadr_ictl(.idebug, .promdisabled, .iwrited, .state_write, .iwe);

   OLORD1 cadr_olord1(.clk, .reset, .ldmode, .ldscratch1, .ldscratch2, .ldclk, .boot, .promdisable, .errstop, .scratch, .opcinh, .opcclk, .lpc_hold, .idebug, .nop11, .srun, .ssdone, .promdisabled, .machrun, .stat_ovf, .stathalt, .errhalt, .state_fetch, .statstop, .spy_in, .ldopc, .set_promdisable, .waiting);

   OLORD2 cadr_olord2(.clk, .reset, .statstop, .err, .errhalt, .boot, .boot_trap, .ldmode, .spy_in, .errstop, .ext_reset, .ext_boot, .srun, .ext_halt, .stat_ovf);

   OPCS cadr_opcs(.clk, .reset, .opcclk, .opcinh, .pc, .opc, .state_fetch);

   PCTL cadr_pctl(.pc, .idebug, .promdisabled, .iwrited, .promenable, .promaddr);

   PROM01 cadr_prom01(.clk, .promaddr, .iprom);

   IRAM cadr_iram(.clk, .reset, .pc, .pc_out, .state_out, .iwr, .iwe, .iram, .fetch_out, .prefetch_out, .machrun_out, .mcr_data_in, .state_fetch, .machrun, .state, .need_mmu_state, .state_mmu, .state_write, .state_prefetch, .promdisabled);

   SPY0 cadr_spy0(.spy_obh, .spy_obl, .spy_pc, .spy_opc, .spy_scratch, .spy_irh, .spy_irm, .spy_irl, .spy_stl, .spy_ah, .spy_al, .spy_mh, .spy_ml, .spy_flag2, .spy_flag1, .ldscratch2, .ldscratch1, .ldmode, .ldopc, .ldclk, .lddbirh, .lddbirm, .lddbirl, .eadr, .dbread, .dbwrite, .spy_mdl, .spy_vmal, .spy_vmah, .spy_sth, .spy_mdh, .spy_disk, .spy_bd, .ldmdh, .ldmdl, .ldvmah, .ldvmal, .spy_obl_, .spy_obh_);

   // ======================================================================================
   // monitors
`ifdef debug
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
	if (state_fetch && irdisp/*({pcs1, pcs0} == 2'b10)*/)
	  begin
	     $display("dispatch: dadr=%o %b%b%b %o; dmask %o r %o ir %b vmo %b md %o",
		      dadr, dr, dp, dn, dpc, dmask, r[11:0],
		      {ir[8], ir[9]}, {vmo[19], vmo[18]}, md);
	     $display("dispatch: mapi %o vmap %o vmem1_adr %o vmo %o",
		      mapi[23:13], vmap, vmem1_adr, vmo);
	     $display("dispatch: pcs %b, dispenb %b dfall %b; vmo[19:18] %o, npc %o",
		      {pcs1, pcs0}, dispenb, dfall, vmo[19:18], npc);
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
	     $display("; conds=%b, aeqm=%b, aeqm_bits=%b",
		      conds, aeqm, aeqm_bits);
	     $display("; trap=%b, trapenb=%b boot_trap=%b",
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
	  $display("%t req lvmo_23, 22 %b%b, pma=%o",
		   $time, lvmo_23, lvmo_22, pma);
       end
 `endif

`endif

`ifdef __CVER__
 `ifdef CHIPSCOPE_CADDR
  `undef CHIPSCOPE_CADDR
 `endif
`endif

`ifdef CHIPSCOPE_CADDR
   // chipscope
   wire [35:0] control0;
   wire [127:0] trig0;
   wire		mclk_en;
   wire		mclk;

   assign trig0 = {
		   busint.disk.state,
		   bd_state_in,
		   state_decode,
		   lpc,
		   a,
		   m,
		   md
		   };

   chipscope_icon_caddr icon1 (.CONTROL0(control0));
   chipscope_ila_caddr ila1 (.CONTROL(control0), .CLK(clk), .TRIG0(trig0));
`endif

endmodule
