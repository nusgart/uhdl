// PCTL

module PCTL(pc, idebug, promdisabled, iwrited, promenable, promaddr);

   input [13:0] pc;
   input idebug;
   input iwrited;
   input promdisabled;
   output [8:0] promaddr;
   output promenable;

   ////////////////////////////////////////////////////////////////////////////////

   wire [11:0] prompc;
   wire bottom_1k;
   wire promce;

   ////////////////////////////////////////////////////////////////////////////////

   assign bottom_1k = ~(pc[13] | pc[12] | pc[11] | pc[10]);
   assign promenable = bottom_1k & ~idebug & ~promdisabled & ~iwrited;
   assign promce = promenable & ~pc[9];
   assign prompc = pc[11:0];
   assign promaddr = prompc[8:0];

endmodule
