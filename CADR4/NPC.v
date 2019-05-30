// NPC --- NPC,IPC,PC
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-15 04:53:07 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module NPC(/*AUTOARG*/
   // Outputs
   ipc, pc,
   // Inputs
   clk, reset, state_fetch, dpc, spc, ir, pcs0, pcs1, spc1a, trap
   );

   input wire clk;
   input wire reset;

   input wire state_fetch;

   input [13:0] dpc;
   input [18:0] spc;
   input [48:0] ir;
   input wire pcs0;
   input wire pcs1;
   input wire spc1a;
   input wire trap;
   output [13:0] ipc;
   output [13:0] pc;

   ////////////////////////////////////////////////////////////////////////////////

   reg [13:0] pc;
   wire [13:0] npc;

   ////////////////////////////////////////////////////////////////////////////////

   assign npc = trap ? 14'b0 :
		{pcs1, pcs0} == 2'b00 ? {spc[13:2], spc1a, spc[0]} :
		{pcs1, pcs0} == 2'b01 ? {ir[25:12]} :
		{pcs1, pcs0} == 2'b10 ? dpc :
		ipc;

   always @(posedge clk)
     if (reset)
       pc <= 0;
     else if (state_fetch)
       pc <= npc;

   assign ipc = pc + 14'd1;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
