module PCTL(pc, idebug, promdisabled, iwrited, prompc, bottom_1k, promenable, promce, promaddr);

   input [13:0] pc;
   input	idebug;
   input	iwrited;
   input	promdisabled;
   output [11:0] prompc;
   output [8:0]  promaddr;
   output	 bottom_1k;
   output	 promce;
   output	 promenable;

   ////////////////////////////////////////////////////////////////////////////////

   assign bottom_1k = ~(pc[13] | pc[12] | pc[11] | pc[10]);
   assign promenable = bottom_1k & ~idebug & ~promdisabled & ~iwrited;

   assign promce = promenable & ~pc[9];

   assign prompc = pc[11:0];

   assign promaddr = prompc[8:0];

endmodule
