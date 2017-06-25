// IREG
//
// TK		CADR	INSTRUCTION REGISTER

module IREG(clk, reset, i, iob, ir, state_fetch, destimod1, destimod0);

   input clk;
   input reset;

   input state_fetch;

   input [47:0] iob;
   input [48:0] i;
   input	destimod0;
   input	destimod1;
   output [48:0] ir;

   ////////////////////////////////////////////////////////////////////////////////

   reg [48:0]	 ir;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       ir <= 49'b0;
     else
       if (state_fetch)
	 begin
	    ir[48] <= ~destimod1 ? i[48] : 1'b0;
	    ir[47:26] <= ~destimod1 ? i[47:26] : iob[47:26];
	    ir[25:0] <= ~destimod0 ? i[25:0] : iob[25:0];
	 end

endmodule
