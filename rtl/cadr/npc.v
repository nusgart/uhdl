// NPC
//
// TK CADR NPC,IPC,PC

module NPC(clk, reset, state_fetch, ipc, trap, pcs1, pcs0, ir, spc, spc1a, dpc, pc);

   input clk;
   input reset;

   input state_fetch;

   input [13:0] dpc;
   input [18:0] spc;
   input [48:0] ir;
   input pcs0;
   input pcs1;
   input spc1a;
   input trap;
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
     else
       if (state_fetch)
         pc <= npc;

   assign ipc = pc + 14'd1;

endmodule
