// OPCS
//
// TK		CADR	OLD PC SAVE SHIFTER

module OPCS(clk, reset, opcclk, opcinh, pc, opc, state_fetch);

   input clk;
   input reset;

   input [13:0] pc;
   input	opcclk;
   input	opcinh;
   input	state_fetch;
   output [13:0] opc;

   ////////////////////////////////////////////////////////////////////////////////

   reg [13:0]	 opc;

   assign opcclka = (state_fetch | opcclk) & ~opcinh;

   always @(posedge clk)
     if (reset)
       opc <= 0;
     else
       if (opcclka)
	 opc <= pc;

endmodule
