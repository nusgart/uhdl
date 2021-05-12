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

module NPC
  (input wire	      state_fetch,

   input wire [13:0]  dpc,
   input wire [18:0]  spc,
   input wire [48:0]  ir,
   input wire	      pcs0,
   input wire	      pcs1,
   input wire	      spc1a,
   input wire	      trap,
   output wire [13:0] ipc,
   output reg [13:0]  pc,

   input wire	      clk,
   input wire	      reset);

   wire [13:0]	      npc;

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
