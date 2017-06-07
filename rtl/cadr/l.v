module L (clk, reset, vmaenb, state_write, state_alu, ob, l);

   input clk, reset;
   input vmaenb;
   input state_write, state_alu;
   input [31:0] ob;
   output reg [31:0] l;

   always @(posedge clk)
     if (reset)
       l <= 0;
     else
       // vma is latched during alu, so this must be too
       if ((vmaenb && (state_write||state_alu)) || (~vmaenb && state_alu))
	 l <= ob;

endmodule
