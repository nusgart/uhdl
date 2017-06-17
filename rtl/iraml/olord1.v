// OLORD1
//
// TK		CADR	OVERLORD

module OLORD1(clk, reset, ldmode, ldscratch1, ldscratch2, ldclk, boot, run, step, promdisable, trapenb, stathenb, errstop, scratch, opcinh, opcclk, lpc_hold, ldstat, idebug, nop11, srun, sstep, ssdone, promdisabled, machrun, stat_ovf, stathalt, errhalt, state_fetch, statstop, spy_in, ldopc, set_promdisable, waiting);

   input clk;
   input reset;

   input	state_fetch;

   input [15:0] spy_in;
   input	boot;
   input	errhalt;
   input	ldclk;
   input	ldmode;
   input	ldopc;
   input	ldscratch1;
   input	ldscratch2;
   input	set_promdisable;
   input	statstop;
   input	waiting;
   output [15:0] scratch;
   output	 errstop;
   output	 idebug;
   output	 ldstat;
   output	 lpc_hold;
   output	 machrun;
   output	 nop11;
   output	 opcclk;
   output	 opcinh;
   output	 promdisable;
   output	 promdisabled;
   output	 run;
   output	 srun;
   output	 ssdone;
   output	 sstep;
   output	 stat_ovf;
   output	 stathalt;
   output	 stathenb;
   output	 step;
   output	 trapenb;

   ////////////////////////////////////////////////////////////////////////////////

   reg [15:0]	 scratch;
   reg		 errstop;
   reg		 ldstat;
   reg		 opcinh;
   reg		 promdisable;
   reg		 run;
   reg		 srun;
   reg		 stathenb;
   reg		 trapenb;
   reg		 opcclk;
   reg		 lpc_hold;
   reg		 idebug;
   reg		 nop11;
   reg		 step;
   reg		 sstep;
   reg		 ssdone;
   reg		 promdisabled;

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

endmodule
