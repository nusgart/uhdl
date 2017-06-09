// TK		CADR	M MEMORY LATCH

module MLATCH(pdldrive, spcdrive, mfdrive, mmem, pdl, spcptr, spco, mf, m, mpassm);

   input [18:0] spco;
   input [31:0] mf;
   input [31:0] mmem;
   input [31:0] pdl;
   input [4:0]	spcptr;
   input	mfdrive;
   input	mpassm;
   input	pdldrive;
   input	spcdrive;
   output [31:0] m;

   ////////////////////////////////////////////////////////////////////////////////

`ifdef debug_with_usim // Does this belong here?
   // tell disk controller when each fetch passes to force sync with usim
   always @(posedge clk)
     if (state_fetch)
       busint.disk.fetch = 1;
     else
       busint.disk.fetch = 0;
`endif

   // mux M
   assign m =
	     /*same as srcm*/mpassm ? mmem :
	     pdldrive ? pdl :
	     spcdrive ? {3'b0, spcptr, 5'b0, spco} :
	     mfdrive ? mf :
	     32'b0;

endmodule
