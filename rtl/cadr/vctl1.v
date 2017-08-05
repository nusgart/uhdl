// VCTL1 --- VMEMORY CONTROL

module VCTL1(clk, reset, lcinc, memrq, ifetch, lvmo_22, lvmo_23, memack, memprepare, memrd, memstart, memwr, needfetch, pfr, pfw, state_alu, state_fetch, state_prefetch, state_write, vmaok, wrcyc, waiting);

   input clk;
   input reset;

   input state_alu;
   input state_fetch;
   input state_prefetch;
   input state_write;

   input ifetch;
   input lcinc;
   input lvmo_22;
   input lvmo_23;
   input memack;
   input memrd;
   input memwr;
   input needfetch;
   output memprepare;
   output memrq;
   output memstart;
   output pfr;                  // VMA permissions (read).
   output pfw;                  // VMA permissions (write).
   output vmaok;                // VMA access OK.
   output waiting;
   output wrcyc;

   ////////////////////////////////////////////////////////////////////////////////

   reg mbusy;
   reg memcheck;
   reg memprepare;
   reg memstart;
   reg rdcyc;
   reg vmaok;
   reg wrcyc;
   wire mfinish;

   ////////////////////////////////////////////////////////////////////////////////

   assign memop = memrd | memwr | ifetch;

   always @(posedge clk)
     if (reset)
       memprepare <= 0;
     else
       if (state_alu || state_write)
         memprepare <= memop;
       else
         memprepare <= 0;

   // Read VMEM.
   always @(posedge clk)
     if (reset)
       memstart <= 0;
     else
       if (~state_alu)
         memstart <= memprepare;
       else
         memstart <= 0;

   // Check result of VMEM.
   always @(posedge clk)
     if (reset)
       memcheck <= 0;
     else
       memcheck <= memstart;

   // VMA permissions.
   assign pfw = (lvmo_23 & lvmo_22) & wrcyc;
   assign pfr = lvmo_23 & ~wrcyc;

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
       if (mfinish)
         mbusy <= 1'b0;
       else
         if (memcheck & (pfr | pfw))
           mbusy <= 1;

   assign mfinish = memack | reset;
   assign waiting = (memrq & mbusy) | (lcinc & needfetch & mbusy);

endmodule
