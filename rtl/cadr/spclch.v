// SPCLCH
//
// TK	CADR	SPC MEMORY LATCH

module SPCLCH(spc, spco);

   input [18:0] spco;
   output [18:0] spc;

   ////////////////////////////////////////////////////////////////////////////////

   // mux SPC
   assign spc = spco;

endmodule
