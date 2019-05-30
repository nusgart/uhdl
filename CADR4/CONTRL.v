// CONTRL --- PC, SPC CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-15 18:23:57 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module CONTRL(/*AUTOARG*/
   // Outputs
   iwrited, n, nop, nopa, pcs0, pcs1, spcdrive, spcenb, spcnt, spop,
   spush, srcspcpopreal, srp, swp,
   // Inputs
   clk, reset, state_alu, state_fetch, state_write, funct, ir,
   destspc, dn, dp, dr, irdisp, irjump, jcond, nop11, srcspc,
   srcspcpop, trap
   );

   input wire clk;
   input wire reset;

   input wire state_alu;
   input wire state_fetch;
   input wire state_write;

   input [3:0] funct;
   input [48:0] ir;
   input wire destspc;
   input wire dn;
   input wire dp;
   input wire dr;
   input wire irdisp;
   input wire irjump;
   input wire jcond;
   input wire nop11;
   input wire srcspc;
   input wire srcspcpop;
   input wire trap;
   output iwrited;
   output wire n;
   output wire nop;
   output wire nopa;
   output wire pcs0;
   output wire pcs1;
   output wire spcdrive;
   output wire spcenb;
   output wire spcnt;
   output wire spop;
   output wire spush;
   output wire srcspcpopreal;
   output wire srp;
   output wire swp;

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
     else if (state_fetch)
       iwrited <= iwrite;

   assign pcs1 = !((popj & ~ignpopj) | (jfalse & ~jcond) | (irjump & ~ir[6] & jcond) | (dispenb & dr & ~dp));
   assign pcs0 = !((popj) | (dispenb & ~dfall) | (jretf & ~jcond) | (jret & ~ir[6] & jcond));
   assign n = trap | iwrited | (dispenb & dn) | (jfalse & ~jcond & ir[7]) | (irjump & ~ir[6] & jcond & ir[7]);
   assign nopa = inop | nop11;
   assign nop = trap | nopa;

   always @(posedge clk)
     if (reset)
       inop <= 0;
     else if (state_fetch)
       inop <= n;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
