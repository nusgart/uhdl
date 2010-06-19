/*
 */

`define debug_vcd

`include "rtl.v"

`timescale 1ns / 1ns

module test;
   reg clk;
   reg reset;
   reg interrupt;

   // controlled by rc circuit at power up
   reg boot;

   wire [15:0] spy;
   wire        dbread, dbwrite;
   wire [3:0]  eadr;

   wire [15:0] 	ide_data_bus;
   wire 	ide_dior;
   wire 	ide_diow;
   wire [1:0] 	ide_cs;
   wire [2:0] 	ide_da;

   caddr cpu (.clk(clk),
	      .ext_int(interrupt),
	      .ext_reset(reset),
	      .ext_boot(boot),
	      .ext_halt(halt),
	      .spy(spy),
	      .dbread(dbread),
	      .dbwrite(dbwrite),
	      .eadr(eadr),
	      .ide_data_bus(ide_data_bus),
	      .ide_dior(ide_dior),
	      .ide_diow(ide_diow),
	      .ide_cs(ide_cs),
	      .ide_da(ide_da));
   
   integer     addr;
   integer     debug_level;
   integer     dumping;
   integer     cycles;
   integer     max_cycles;
     
   assign      eadr = 4'b0;
   assign      dbread = 0;
   assign      dbwrite = 0;

   reg [1023:0] arg;
   integer 	n;

   initial
     begin
	$timeformat(-9, 0, "ns", 7);

`ifdef debug_log
`else
`ifdef __CVER__
	$nolog;
`endif
`endif

	debug_level = 1;
	dumping = 0;
	cycles = 0;
	max_cycles = 0;

`ifdef debug_vcd
	$dumpfile("caddr.vcd");
	$dumpvars(0, test.cpu);
	dumping = 1;
`endif

`ifdef __ICARUS__
       n = $value$plusargs("cycles=%d", arg);
	if (n > 0)
	  begin
	     max_cycles = arg;
	     $display("arg cycles %d", max_cycles);
	  end
`endif       
`ifdef __CVER__
       n = $scan$plusargs("cycles=", arg);
	if (n > 0)
	  begin
	     n = $sscanf(arg, "%d", max_cycles);
	     $display("arg cycles %d", max_cycles);
	  end
`endif
     end

   initial
     begin
	clk = 0;
	interrupt = 0;
	reset = 0;

	#1 begin
	   reset = 1;
	   boot = 0;

        end

	#240 boot = 1;

	#10 reset = 0;
	#10 boot = 0;
     end

   // 50mhz clock
   always
     begin
	#10 clk = 0;
	#10 clk = 1;
     end

   always @(posedge cpu.clk)
     begin
	if (cpu.state == 5'b00001)
	  cycles = cycles + 1;

	if (cycles > 25 && (cpu.lpc > 7 && cpu.lpc < 14'o50) &&
	    (cpu.npc < 14'o50))
	  begin
	     $display("in microcode error routine; lpc %o", cpu.lpc);
	     $finish;
	  end

	if (max_cycles > 0 && cycles >= max_cycles)
	  begin
	     $display("maximum cycles count (%0d) exceeded", max_cycles);
	     $finish;
	  end
     end

   always @(posedge cpu.clk)
     #1 if (debug_level == 1 && cpu.state == 5'b00001)
       begin
	  $display("%0o %o A=%x M=%x N=%b Q=%x R=%x L=%x",
		   cpu.lpc, cpu.ir,
		   cpu.a, cpu.m, cpu.n, cpu.q, cpu.r, cpu.l);

	  if (dumping)
	    begin
	       $dumpoff;
	       dumping = 0;
	       $display("dumping: off");
	    end
	  
//	  if (cpu.promdisable == 1 && cpu.npc == 14'o21636)
//	    debug_level = 3;
     end 
   
   always @(posedge cpu.clk)
     #1 if (debug_level == 2 && cpu.state == 5'b00001)
       begin
	if (cpu.state == 5'b00001) $display("-----");

	$display("LPC=%o PC=%o NPC=%o PCS=%b%b IR=%o",
		 cpu.lpc, cpu.pc, cpu.npc, cpu.pcs1, cpu.pcs0, cpu.ir);
	$display("     A=%x M=%x N=%b Q=%x R=%x L=%x",
		 cpu.a, cpu.m, cpu.n, cpu.q, cpu.r, cpu.l);
     end 
   
   always @(posedge cpu.clk)
     #1 if (debug_level == 3)
       begin
`ifdef debug_vcd
	  if (dumping == 0)
	    begin
	       dumping = 1;
	       $dumpon;
	       $dumpall;
	       $display("dumping: on");
	    end
`endif

	  if (0)
	    begin
	       cpu.i_AMEM.debug = 1;
	       cpu.i_MMEM.debug = 1;
	    end
	  
	if (cpu.state == 5'b00001) $display("-----");

	case (cpu.state)
	  5'b00000: $display("%0o %o reset  %t", cpu.lpc, cpu.ir, $time);
	  5'b00001: $display("%0o %o decode %t", cpu.lpc, cpu.ir, $time);
	  5'b00010: $display("%0o %o exec   %t", cpu.lpc, cpu.ir, $time);
	  5'b00100: $display("%0o %o write  %t", cpu.lpc, cpu.ir, $time);
	  5'b01000: $display("%0o %o fetch  %t", cpu.lpc, cpu.ir, $time);
	  5'b10000: $display("%0o %o wait   %t", cpu.lpc, cpu.ir, $time);
	endcase
	  
	$display("     A=%x M=%x, N=%x, Q=%x s=%b%b%b%b%b R=%x, L=%x",
		 cpu.a, cpu.m, cpu.n, cpu.q,
		 cpu.s4, cpu.s3, cpu.s2, cpu.s1, cpu.s0, cpu.r, cpu.l);

	$display("     conds=%b, jcond=%b, jfalse=%b (%b), npc %o pcs=%b",
		 cpu.conds, cpu.jcond, cpu.jfalse, cpu.jfalse & ~cpu.jcond,
		 cpu.npc, {cpu.pcs1, cpu.pcs0});

	$display("     a_latch=%x m.latched=%x, aeqm %b %b",
		 cpu.a_latch, cpu.mmem_latched, cpu.aeqm, cpu.aeqm_bits);
	  
//	$display("     vmaok %b, pfr %b, pfw %b; vmaenb %b",
//		 cpu.vmaok, cpu.pfr, cpu.pfw, cpu.vmaenb);

//	$display("     apass=%b, apassenb=%b, amemenb=%b",
//		 cpu.apass, cpu.amemenb, cpu.apassenb);

//	$display("     wadr %o, dest %o, destd %o, ir[41:32] %o",
//		 cpu.wadr, cpu.dest, cpu.destd, cpu.ir[41:32]);

//	$display("     mpass=%b, mpassl=%b, mpassm=%b",
//		 cpu.mpass, cpu.mpassl, cpu.mpassm);

	$display("     mdrive: mp%b pdl%b spc%b mf%b destmdr%b; adrive amemenb%b apassenb%b",
		 cpu.mpassm, cpu.pdldrive, cpu.spcdrive, cpu.mfdrive,
		 cpu.destmdr,
		 cpu.amemenb, cpu.apassenb);

	$display("     mfdrive: lc%b ipc%b dc%b pp%b pi%b q%b md%b mp%b vma%b map%b",
		 cpu.lcdrive, cpu.opcdrive, cpu.dcdrive, cpu.ppdrive,
		 cpu.pidrive, cpu.qdrive, cpu.mddrive, cpu.mpassl,
		 cpu.vmadrive, cpu.mapdrive);
	  
	$display("     vma %o, vmas %o, md %o, mds %o",
		 cpu.vma, cpu.vmas, cpu.md, cpu.mds);

	$display("     vmap %o, mapi %o",
		 cpu.vmap, cpu.mapi);

//		 cpu.pdldrive, cpu.spcdrive, cpu.mfdrive);

//	$display("     md=%x, mds=%x, loadmd=%b, busint_bus=%o",
//		 cpu.md, cpu.mds, cpu.mdsel, cpu.mdclk, cpu.loadmd, cpu.busint_bus);

//	$display("     mf=%x, mfenb=%b, srcm=%b, srcq=%b",
//		 cpu.mf, cpu.mfenb, cpu.srcm, cpu.srcq);

//	$display("     popj %b, nop %b, jret %b, jretf %b, jcond %b, spop %b",
//		 cpu.popj, cpu.nop, cpu.jret, cpu.jretf, cpu.jcond, cpu.spop);


	$display("     aluf=%o, alu=%x, qs=%b%b, ob=%o, osel=%b",
		 cpu.aluf, cpu.alu, cpu.qs1, cpu.qs0, cpu.ob, cpu.osel);

	$display("     spcptr=%o, spc=%o, spco=%o, spco_latched=%o, jret=%b",
		 cpu.spcptr, cpu.spc, cpu.spco, cpu.spco_latched, cpu.jret);

//        $display("     spop%b, spush%b, spcnt%b",
//		 cpu.spop, cpu.spush, cpu.spcnt);

// ---------------------------------------------------------------

//	$display("     destimod %b%b, iob %o, ob %o",
//		 cpu.destimod0, cpu.destimod1, cpu.iob, cpu.ob, cpu.mo, cpu.msk);

//	$display("     mo %o, msk %o, s %b, sr %b mr %b",
//		 cpu.mo, cpu.msk,
//		 { cpu.s4, cpu.s3, cpu.s2, cpu.s1, cpu.s0 }, cpu.sr, cpu.mr);

//	$display("     destpdlx %b, pdlidx %o, pdlptr %o",
//		 cpu.destpdlx, cpu.pdlidx, cpu.pdlptr);

//	$display("     destm %b, destpdlx %b, ir[23:22] %b, ir[21:19]",
//		 cpu.destm, cpu.destpdlx, cpu.ir[23:22], cpu.ir[21:19]);

//        $display("     div %b, mul %b, divposlastime %b, divsubcond %d, divaddcond %b",
//		 cpu.div, cpu.mul,
//		 cpu.divposlasttime, cpu.divsubcond, cpu.divaddcond);

`ifdef xxx	  
	$display("     wmap %b, wmapd %b, wmapwr0d %b, wmapwr1d %b, vma %o, vmas %o",
		 cpu.wmap, cpu.wmapd, cpu.mapwr0d, cpu.mapwr1d,
		 cpu.vma, cpu.vmas);

//	$display("     trap=%x dispenb=%x dn=%x jfalse=%x jcond=%b, popj=%b",
//		 cpu.trap, cpu.dispenb, cpu.dn,
//		 cpu.jfalse, cpu.jcond, cpu.popj);

//	$display("     vma0wp=%b, vma1wp=%b, mapwr0d=%b, mapwr1=%b, wmapd=%b",
//		 cpu.vm0wp, cpu.vm1wp, cpu.mapwr0d, cpu.mapwr1d, cpu.wmapd);
		 
	$display("     mwp=%x madr=%o awp=%x aadr=%o, aeqm %b %b",
		 cpu.mwp, cpu.madr, cpu.awp, cpu.aadr, cpu.aeqm, cpu.aeqm_bits);

	$display("     mf=%x, mfenb=%b, srcm=%b, srcq=%b, spcenb=%b, pdlenb=%b",
		 cpu.mf, cpu.mfenb, cpu.srcm, cpu.srcq, cpu.spcenb, cpu.pdlenb);

	$display("     mddrive=%b, m-src %b, src %b%b%b%b%b, mmem_latched=%x",
		 cpu.mddrive, cpu.ir[31:26],
		 cpu.srcspcpop,cpu.srclc,cpu.srcmd,cpu.srcmap,cpu.srcvma,
		 cpu.mmem_latched);
	  
	$display("     amemenb=%b, apassenb=%b, a_latch=%x",
		 cpu.amemenb, cpu.apassenb, cpu.a_latch);

//	$display("     mpassm=%b, pdldrive=%b, spcdrive=%b, mfdrive=%b",
//		 cpu.mpassm, cpu.pdldrive, cpu.spcdrive, cpu.mfdrive);
	  
//	$display("     nop=%x inop=%x", cpu.nop, cpu.inop);
//	$display("     dest=%x ir[25]=%x", cpu.dest, cpu.ir[25]);

//	$display("     iwrite=%x, iwrited=%x, destm=%x, destmd=%x",
//		 cpu.iwrite, cpu.iwrited, cpu.destm, cpu.destmd);

	$display("     trap=%x dispenb=%x dn=%x jfalse=%x jcond=%b, popj=%b",
		 cpu.trap, cpu.dispenb, cpu.dn,
		 cpu.jfalse, cpu.jcond, cpu.popj);

	$display("     osel=%b, alusub=%b, aluadd=%b, aluf=%o, alu=%x, qs=%b%b",
		 cpu.osel, cpu.alusub, cpu.aluadd, cpu.aluf, cpu.alu,
		 cpu.qs1, cpu.qs0);

        $display("     conds=%b, jcond=%b, jfalse=%b (%b)",
		 cpu.conds, cpu.jcond, cpu.jfalse, cpu.jfalse & ~cpu.jcond);

	$display("     md=%x, mds=%x, mdsel=%b, mdclk=%b, loadmd=%b, busint_bus=%o",
		 cpu.md, cpu.mds, cpu.mdsel, cpu.mdclk, cpu.loadmd, cpu.busint_bus);

//	$display("     ir-dst=%o, destm=%b, destmem=%b, destvma=%b, destmdr=%b",
//		 cpu.ir[25:19], cpu.destm,
//		 cpu.destmem, cpu.destvma, cpu.destmdr);
		 
	$display("     destspc=%b, destpdl_p=%b, spush=%b, spop=%b",
		 cpu.destspc, cpu.destpdl_p, cpu.spush, cpu.spop);
		 
	$display("     ob=%x, mem=%x, vma=%x, vmas=%x",
		 cpu.ob, cpu.mem, cpu.vma, cpu.vmas);
		 
	$display("     spcnt=%b, spcptr=%o, pdlcnt=%b, pdlptr=%o",
		 cpu.spcnt, cpu.spcptr, cpu.pdlcnt, cpu.pdlptr);
		 
	$display("     pwp=%b, pdlwrite=%o, pdlwrited=%b, pldp=%b, pdla=%o",
		 cpu.pwp, cpu.pdlwrite, cpu.pdlwrited,
		 cpu.pdlp, cpu.pdla);

	$display("     pdl=%x, pdl_latch=%x",
		 cpu.pdl, cpu.pdl_latch);
	  
//	$display("     iwrite=%b, iwrited=%b, popj=%b, imod=%b, ramdisable=%b",
//		 cpu.iwrite, cpu.iwrited, cpu.popj, cpu.imod, cpu.ramdisable);
	  
//	$display("     iralu=%x irjump=%x irdisp=%x irbyte=%x",
//		 cpu.iralu, cpu.irjump, cpu.irdisp, cpu.irbyte);
`endif
	  
     end 

   always @(posedge clk)
     begin
	$pli_ide(ide_data_bus, ide_dior, ide_diow, ide_cs, ide_da);
     end
   
endmodule