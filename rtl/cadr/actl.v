module ACTL(clk, reset,state_decode, state_write,wadr,destm,awp,arp,aadr,ir,dest);

   input clk, reset;
   input state_decode, state_write;
   output reg [9:0] wadr;
   input 	    destm;
   output 	    awp,arp;
   output [9:0] 	  aadr;
   input [48:0] 	  ir;
   input  dest;

   always @(posedge clk)
     if (reset)
       begin
	  wadr <= 0;
       end
     else
       if (state_decode)
	 begin
	    // wadr 9  8  7  6  5  4  3  2  1  0
	    //      0  0  0  0  0  18 17 16 15 14
	    // ir   23 22 21 20 19 18 17 16 15 14
	    wadr <= destm ? { 5'b0, ir[18:14] } : { ir[23:14] };
	 end

   assign awp = dest & state_write;
   assign arp = state_decode;

   // use wadr during state_write
   assign aadr = ~state_write ? { ir[41:32] } : wadr;

endmodule
