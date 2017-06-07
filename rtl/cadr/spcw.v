module SPCW(destspc, l, reta, spcw, n, wpc, ipc);
   
   input  destspc;
   input [31:0] l;
   output [18:0] spcw;
   output [13:0] reta;
   input n;
   input [13:0] 	wpc;
	   input [13:0] 	ipc;
		
   assign spcw = destspc ? l[18:0] : { 5'b0, reta };

   //   always @(posedge clk)
   //     if (reset)
   //       reta <= 0;
   //     else
   //       /* n is not valid until after decode */
   //       if (state_alu)
   //	 reta <= n ? wpc : ipc;

   assign reta = n ? wpc : ipc;

endmodule
