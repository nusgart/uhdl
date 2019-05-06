// LPC --- LAST PC
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-03 04:36:14) Initial.

`timescale 1ns/1ps
`default_nettype none

module LPC(/*AUTOARG*/
   // Outputs
   wpc,
   // Inputs
   clk, reset, state_fetch, lpc_hold, pc, ir, irdisp
   );

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
     else if (state_fetch) begin
	if (~lpc_hold)
	  lpc <= pc;
     end

   assign wpc = (irdisp & ir[25]) ? lpc : pc;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
