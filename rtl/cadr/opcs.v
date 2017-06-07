module OPCS (clk, reset, opcclk, opcinh, pc, opc, state_fetch);

   input clk, reset;
   input state_fetch;
   input opcclk;
   input opcinh;
   output reg [13:0] opc;
   input [13:0]      pc;

   assign opcclka = (state_fetch | opcclk) & ~opcinh;

   always @(posedge clk)
     if (reset)
       opc <= 0;
     else
       if (opcclka)
	 opc <= pc;

endmodule
