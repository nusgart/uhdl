// ICTL
//
// TK		CADR	I RAM CONTROL

module ICTL(ramdisable, idebug, promdisabled, iwrited, state_write, iwe);

   input idebug;
   input iwrited;
   input promdisabled;
   input state_write;
   output iwe;
   output ramdisable;

   ////////////////////////////////////////////////////////////////////////////////

   assign ramdisable = idebug | ~(promdisabled | iwrited);

   // see clocks below
   wire   iwe;
   assign iwe = iwrited & state_write;

endmodule
