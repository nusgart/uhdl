// DEBUG --- PDP11 DEBUG INSTRUCTION
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-01-26 22:52:51 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module DEBUG(/*AUTOARG*/
   // Outputs
   i,
   // Inputs
   clk, reset, spy_in, iprom, iram, idebug, lddbirh, lddbirl, lddbirm,
   promenable
   );

   input wire clk;
   input wire reset;

   input [15:0] spy_in;
   input [48:0] iprom;
   input [48:0] iram;
   input wire idebug;
   input wire lddbirh;
   input wire lddbirl;
   input wire lddbirm;
   input wire promenable;
   output [48:0] i;

   ////////////////////////////////////////////////////////////////////////////////

   reg [47:0] spy_ir;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       spy_ir[47:32] <= 16'b0;
     else if (lddbirh)
       spy_ir[47:32] <= spy_in;

   always @(posedge clk)
     if (reset)
       spy_ir[31:16] <= 16'b0;
     else if (lddbirm)
       spy_ir[31:16] <= spy_in;

   always @(posedge clk)
     if (reset)
       spy_ir[15:0] <= 16'b0;
     else if (lddbirl)
       spy_ir[15:0] <= spy_in;

   // Put latched value on I bus when IDEBUG is asserted.
   ///---!!! Why are we putting SPY_IR on the I bus?
   assign i = idebug ? {1'b0, spy_ir} :
	      promenable ? iprom :
	      iram;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
