// SPCW
//
// TK	CADR	SPC WRITE DATA SEL

module SPCW(destspc, l, spcw, n, wpc, ipc);

   input [13:0] ipc;
   input [13:0] wpc;
   input [31:0] l;
   input	destspc;
   input	n;
   output [18:0] spcw;

   ////////////////////////////////////////////////////////////////////////////////

   wire [13:0]	 reta;

   assign spcw = destspc ? l[18:0] : { 5'b0, reta };

   //   always @(posedge clk)
   //     if (reset)
   //       reta <= 0;
   //     else
   //       // n is not valid until after decode
   //       if (state_alu)
   //	 reta <= n ? wpc : ipc;

   assign reta = n ? wpc : ipc;

endmodule
