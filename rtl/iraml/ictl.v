// ICTL --- I RAM CONTROL

`include "defines.vh"

module ICTL(idebug, promdisabled, iwrited, state_write, iwe);

   input state_write;

   input idebug;
   input iwrited;
   input promdisabled;
   output iwe;

   ////////////////////////////////////////////////////////////////////////////////

   wire ramdisable;

   ////////////////////////////////////////////////////////////////////////////////

   assign ramdisable = idebug | ~(promdisabled | iwrited);
   assign iwe = iwrited & state_write;

endmodule
