// DEBUG
//
// TK CADR PDP11 DEBUG INSTRUCTION

module DEBUG(clk, reset, spy_in, i, idebug, promenable, iprom, iram, lddbirh, lddbirm, lddbirl);

   input clk;
   input reset;

   input [15:0] spy_in;
   input [48:0] iprom;
   input [48:0] iram;
   input idebug;
   input lddbirh;
   input lddbirl;
   input lddbirm;
   input promenable;
   output [48:0] i;

   ////////////////////////////////////////////////////////////////////////////////

   reg [47:0] spy_ir;

   ////////////////////////////////////////////////////////////////////////////////

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

   // Put latched value on I bus when IDEBUG is asserted.
   ///---!!! Why are we putting SPY_IR on the I bus?
   assign i = idebug ? {1'b0, spy_ir} :
              promenable ? iprom :
              iram;

endmodule
