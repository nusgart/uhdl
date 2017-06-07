module NPC( clk,reset, state_fetch, ipc, npc,    	 trap, 	 pcs1, pcs0,  ir,  spc, 	 spc1a,  dpc, pc,);

   input clk,reset;
   input state_fetch;
   output [13:0] ipc;
   output [13:0] npc;   
   input 	 trap;
   input 	 pcs1, pcs0;
   input [48:0]  ir;
   input [18:0]  spc;
   input 	 spc1a;
   input [13:0]  dpc;
   output reg [13:0] pc;
   
   assign npc =
		trap ? 14'b0 :
		{pcs1,pcs0} == 2'b00 ? { spc[13:2], spc1a, spc[0] } :
		{pcs1,pcs0} == 2'b01 ? { ir[25:12] } :
		{pcs1,pcs0} == 2'b10 ? dpc :
		/*2'b11*/ ipc;

   always @(posedge clk)
     if (reset)
       pc <= 0;
     else
       if (state_fetch)
	 pc <= npc;

   assign ipc = pc + 14'd1;

endmodule
