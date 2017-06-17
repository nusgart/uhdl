// MCTL
//
// TK		CADR	M CONTROL

module MCTL(mpassm, srcm, mrp, mwp, madr, ir, destm, wadr, state_decode, state_write);

   input [48:0] ir;
   input [9:0]	wadr;
   input	destm;
   input	state_decode;
   input	state_write;
   output [4:0] madr;
   output	mpassm;
   output	mrp;
   output	mwp;
   output	srcm;

   ////////////////////////////////////////////////////////////////////////////////

   // assign mpass = { 1'b1, ir[30:26] } == { destm, wadr[4:0] };
   // assign mpassl = mpass & phase1 & ~ir[31];
   assign mpassm = /*~mpass & phase1 &*/ ~ir[31];

   assign srcm = ~ir[31]/* & ~mpass*/;	/* srcm = m-src is m-memory */

   assign mrp = state_decode;
   assign mwp = destm & state_write;

   // use wadr during state_write
   assign madr = ~state_write ? ir[30:26] : wadr[4:0];

endmodule
