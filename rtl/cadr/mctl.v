// MCTL
//
// TK CADR M CONTROL

module MCTL(mpassm, srcm, mrp, mwp, madr, ir, destm, wadr, state_decode, state_write);

   input state_decode;
   input state_write;

   input [48:0] ir;
   input [9:0] wadr;
   input destm;
   output [4:0] madr;
   output mpassm;
   output mrp;
   output mwp;
   output srcm;

   ////////////////////////////////////////////////////////////////////////////////

   assign mpassm = ~ir[31];
   assign srcm = ~ir[31];
   assign mrp = state_decode;
   assign mwp = destm & state_write;

   // Use WADR during STATE_WRITE.
   ///---!!! why use WADR during STATE_WRITE?
   assign madr = ~state_write ? ir[30:26] : wadr[4:0];

endmodule
