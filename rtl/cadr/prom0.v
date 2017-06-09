module PROM0(clk, promaddr, iprom);

   input clk;

   input [8:0] promaddr;
   output [48:0] iprom;

   ////////////////////////////////////////////////////////////////////////////////

   part_512x49prom i_PROM(
			  .clk(clk),
			  .addr(~promaddr),
			  .q(iprom)
			  );

endmodule
