module ICTL (ramdisable, idebug, promdisabled, iwrited, state_write, iwe);

   output ramdisable;
   input  idebug, promdisabled, iwrited;
   input  state_write;
   output iwe;

   assign ramdisable = idebug | ~(promdisabled | iwrited);

   // see clocks below
   wire   iwe;
   assign iwe = iwrited & state_write;

endmodule
