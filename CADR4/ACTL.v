// ACTL --- A CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-03 06:46:20 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module ACTL(/*AUTOARG*/
   // Outputs
   aadr, wadr, arp, awp,
   // Inputs
   clk, reset, state_decode, state_write, ir, dest, destm
   );

   input clk;
   input reset;

   input state_decode;
   input state_write;

   input [48:0] ir;
   input dest;
   input destm;
   output [9:0] aadr;
   output [9:0] wadr;
   output arp;
   output awp;

   ////////////////////////////////////////////////////////////////////////////////

   reg [9:0] wadr;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       wadr <= 0;
     else if (state_decode)
       wadr <= destm ? {5'b0, ir[18:14]} : {ir[23:14]};

   assign awp = dest & state_write;
   assign arp = state_decode;

   // Use WADR during STATE_WRITE.
   ///---!!! why use WADR during STATE_WRITE?
   assign aadr = ~state_write ? {ir[41:32]} : wadr;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
