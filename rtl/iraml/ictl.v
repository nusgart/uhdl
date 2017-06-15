// TK		CADR	I RAM CONTROL

module ICTL(idebug, promdisabled, iwrited, state_write, iwe);

   input state_write;

   input idebug;
   input iwrited;
   input promdisabled;
   output iwe;

   ////////////////////////////////////////////////////////////////////////////////

   wire   ramdisable;

   assign ramdisable = idebug | ~(promdisabled | iwrited);

   // see clocks below
   assign iwe = iwrited & state_write;

endmodule
