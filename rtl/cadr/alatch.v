// ALATCH --- A MEMORY LATCH
`include "defines.vh"


module ALATCH(amem, a);

   input [31:0] amem;
   output [31:0] a;

   ////////////////////////////////////////////////////////////////////////////////

   assign a = amem;

endmodule
