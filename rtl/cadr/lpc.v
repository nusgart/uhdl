// LPC
//
// CADR LAST PC

module LPC(clk, reset, lpc_hold, pc, wpc, irdisp, ir, state_fetch);

   input clk;
   input reset;

   input state_fetch;

   input lpc_hold;
   input [13:0] pc;
   input [48:0] ir;
   input irdisp;
   output [13:0] wpc;

   ////////////////////////////////////////////////////////////////////////////////

   reg [13:0] lpc;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       lpc <= 0;
     else
       if (state_fetch)
         begin
            if (~lpc_hold)
              lpc <= pc;
         end

   assign wpc = (irdisp & ir[25]) ? lpc : pc;

endmodule
