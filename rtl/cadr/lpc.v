module LPC (clk, reset, lpc, lpc_hold, pc, wpc, irdisp, ir, state_fetch);

   input clk, reset;
   output reg [13:0] lpc;
   input [13:0]      pc;
   input	     irdisp;
   input [48:0]      ir;
   input	     lpc_hold;
   output [13:0]     wpc;
   input	     state_fetch;

   always @(posedge clk)
     if (reset)
       lpc <= 0;
     else
       if (state_fetch)
	 begin
	    if (~lpc_hold)
	      lpc <= pc;
	 end

   /* dispatch and instruction as N set */
   assign wpc = (irdisp & ir[25]) ? lpc : pc;

endmodule
