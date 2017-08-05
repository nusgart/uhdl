// CONTRL --- PC, SPC CONTROL

module CONTRL(clk, reset, state_alu, state_fetch, state_write, funct, ir, destspc, dn, dp, dr, irdisp, irjump, jcond, nop11, srcspc, srcspcpop, trap, iwrited, n, nop, nopa, pcs0, pcs1, spcdrive, spcenb, spcnt, spop, spush, srcspcpopreal, srp, swp);

   input clk;
   input reset;

   input state_alu;
   input state_fetch;
   input state_write;

   input [3:0] funct;
   input [48:0] ir;
   input destspc;
   input dn;
   input dp;
   input dr;
   input irdisp;
   input irjump;
   input jcond;
   input nop11;
   input srcspc;
   input srcspcpop;
   input trap;
   output iwrited;
   output n;
   output nop;
   output nopa;
   output pcs0;
   output pcs1;
   output spcdrive;
   output spcenb;
   output spcnt;
   output spop;
   output spush;
   output srcspcpopreal;
   output srp;
   output swp;

   ////////////////////////////////////////////////////////////////////////////////

   reg inop;
   reg iwrited;
   wire dfall;
   wire dispenb;
   wire ignpopj;
   wire ipopj;
   wire iwrite;
   wire jcalf;
   wire jfalse;
   wire jret;
   wire jretf;
   wire popjwire;
   wire popj;

   ////////////////////////////////////////////////////////////////////////////////

   assign dfall = dr & dp;
   assign dispenb = irdisp & ~funct[2];
   assign ignpopj = irdisp & ~dr;
   assign jfalse = irjump & ir[6];
   assign jcalf = jfalse & ir[8];
   assign jret = irjump & ~ir[8] & ir[9];
   assign jretf = jret & ir[6];
   assign iwrite = irjump & ir[8] & ir[9];
   assign ipopj = ir[42] & ~nop;
   assign popj = ipopj | iwrited;
   assign srcspcpopreal = srcspcpop & ~nop;
   assign spop = ((srcspcpopreal | popj) & ~ignpopj) | (dispenb & dr & ~dp) | (jret & ~ir[6] & jcond) | (jretf & ~jcond);
   assign spush = destspc | (jcalf & ~jcond) | (dispenb & dp & ~dr) | (irjump & ~ir[6] & ir[8] & jcond);
   assign srp = state_write;
   assign swp = spush & state_write;
   assign spcenb = srcspc | srcspcpop;
   assign spcdrive = spcenb & (state_alu || state_write || state_fetch);
   assign spcnt = spush | spop;

   always @(posedge clk)
     if (reset)
       iwrited <= 0;
     else
       if (state_fetch)
         iwrited <= iwrite;

   assign pcs1 = !((popj & ~ignpopj) | (jfalse & ~jcond) | (irjump & ~ir[6] & jcond) | (dispenb & dr & ~dp));
   assign pcs0 = !((popj) | (dispenb & ~dfall) | (jretf & ~jcond) | (jret & ~ir[6] & jcond));
   assign n = trap | iwrited | (dispenb & dn) | (jfalse & ~jcond & ir[7]) | (irjump & ~ir[6] & jcond & ir[7]);
   assign nopa = inop | nop11;
   assign nop = trap | nopa;

   always @(posedge clk)
     if (reset)
       inop <= 0;
     else
       if (state_fetch)
         inop <= n;

endmodule
