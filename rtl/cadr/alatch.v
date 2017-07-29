// ALATCH
//
// TK CADR A MEMORY LATCH

module ALATCH(amem, a);

   input [31:0] amem;
   output [31:0] a;

   ////////////////////////////////////////////////////////////////////////////////

   assign a = amem;

endmodule
