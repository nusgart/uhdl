// L --- ---!!!
`include "defines.vh"


module L(clk, reset, vmaenb, state_write, state_alu, ob, l);

   input clk;
   input reset;

   input state_alu;
   input state_write;

   input [31:0] ob;
   input vmaenb;
   output [31:0] l;

   ////////////////////////////////////////////////////////////////////////////////

   reg [31:0] l;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       l <= 0;
     else
       // VMA is latched during STATE_ALU, so this must be too.
       if ((vmaenb && (state_write || state_alu)) || (~vmaenb && state_alu))
         l <= ob;

endmodule
