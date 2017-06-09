module VCTRL1(clk, reset, lcinc, memrq, ifetch, lvmo_22, lvmo_23, mbusy, memack, memcheck, memprepare, memrd, memstart, memwr, needfetch, pfr, pfw, srcyc, state_alu, state_fetch, state_prefetch, state_write, vmaok, rdcyc, wrcyc, mfinish, waiting);

   input clk;
   input reset;

   input ifetch;
   input lcinc;
   input lvmo_22;
   input lvmo_23;
   input memack;
   input memrd;
   input memwr;
   input needfetch;
   input srcyc;
   input state_alu;
   input state_fetch;
   input state_prefetch;
   input state_write;
   output mbusy;
   output memcheck;
   output memprepare;
   output memrq;
   output memstart;
   output mfinish;
   output pfr;
   output pfw;
   output rdcyc;
   output vmaok;
   output waiting;
   output wrcyc;

   ////////////////////////////////////////////////////////////////////////////////

   reg	  mbusy;
   reg	  memcheck;
   reg	  memprepare;
   reg	  memstart;
   reg	  rdcyc;
   reg	  vmaok;
   reg	  wrcyc;

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

endmodule
