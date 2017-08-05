// PLATCH --- PDL BUFFER LATCH

module PLATCH(pdl, pdlo);

   input [31:0] pdlo;
   output [31:0] pdl;

   ////////////////////////////////////////////////////////////////////////////////

   assign pdl = pdlo;

endmodule
