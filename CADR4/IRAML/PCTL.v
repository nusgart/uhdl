// PCTL --- PROM CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-27 09:45:25 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module PCTL
  (input wire [13:0] pc,
   input wire	     idebug,
   input wire	     iwrited,
   input wire	     promdisabled,

   output wire [8:0] promaddr,
   output wire	     promenable,
   input wire	     clk,
   input wire	     reset);

   wire [11:0]	     prompc;
   wire		     bottom_1k;
   wire		     promce;

   ////////////////////////////////////////////////////////////////////////////////

   assign bottom_1k = ~(pc[13] | pc[12] | pc[11] | pc[10]);
   assign promenable = bottom_1k & ~idebug & ~promdisabled & ~iwrited;
   assign promce = promenable & ~pc[9];
   assign prompc = pc[11:0];
   assign promaddr = prompc[8:0];

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
