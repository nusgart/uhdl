// MD
//
// TK		CADR	MEMORY DATA REGISTER

module MD(clk, reset, md, mddrive, mdgetspar, spy_in, loadmd, memrq, destmdr, mds, srcmd, state_alu, state_write, state_mmu, state_fetch, ldmdh, ldmdl);

   input clk;
   input reset;

   input	state_alu;
   input	state_fetch;
   input	state_mmu;
   input	state_write;

   input [15:0] spy_in;
   input [31:0] mds;
   input	destmdr;
   input	ldmdh;
   input	ldmdl;
   input	loadmd;
   input	memrq;
   input	srcmd;
   output [31:0] md;
   output	 mddrive;
   output	 mdgetspar;

   ////////////////////////////////////////////////////////////////////////////////

   reg [31:0]	 md;
   reg		 mdhaspar;
   reg		 mdpar;

   assign mdgetspar = ~destmdr & ~ignpar;
   assign ignpar = 1'b0;

   assign mdclk = loadmd | destmdr;

   always @(posedge clk)
     if (reset)
       begin
	  md <= 32'b0;
	  mdhaspar <= 1'b0;
	  mdpar <= 1'b0;
       end
     else
       if ((loadmd && memrq) || (state_alu && destmdr))
	 begin
	    md <= mds;
	    mdhaspar <= mdgetspar;
	 end
       else
	 if (ldmdh)
	   md[31:16] <= spy_in;
	 else
	   if (ldmdl)
	     md[15:0] <= spy_in;

   assign mddrive = srcmd &
		    (state_alu || state_write || state_mmu || state_fetch);

   assign mdgetspar = ~destmdr & ~ignpar;
   assign ignpar = 1'b0;

   assign mdclk = loadmd | destmdr;

endmodule
