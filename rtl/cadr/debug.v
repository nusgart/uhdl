module DEBUG(clk, reset, spy_ir, spy_in, i, idebug, promenable, iprom, iram, lddbirh, lddbirm, lddbirl);

   input  clk, reset;
output     reg [47:0] 	spy_ir;
   input [15:0] spy_in;
   output     [48:0] 	i;
   input 		idebug,promenable;
input [48:0] 	iprom;
input [48:0] 	iram;
   input 	lddbirh, lddbirm, lddbirl;
   
   always @(posedge clk)
     if (reset)
       spy_ir[47:32] <= 16'b0;
     else
       if (lddbirh)
	 spy_ir[47:32] <= spy_in;

   always @(posedge clk)
     if (reset)
       spy_ir[31:16] <= 16'b0;
     else
       if (lddbirm)
	 spy_ir[31:16] <= spy_in;

   always @(posedge clk)
     if (reset)
       spy_ir[15:0] <= 16'b0;
     else
       if (lddbirl)
	 spy_ir[15:0] <= spy_in;

   // put latched value on I bus when idebug asserted
   assign i =
	     idebug ? {1'b0, spy_ir} :
	     promenable ? iprom :
	     iram;

endmodule
