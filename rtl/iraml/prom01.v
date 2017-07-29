// PROM0, PROM1
//
// TK CADR PROM 0-511
// TK CADR PROM 512-1023

module PROM01(clk, promaddr, iprom);

   input clk;

   input [8:0] promaddr;
   output [48:0] iprom;

   ////////////////////////////////////////////////////////////////////////////////

   part_512x49prom i_PROM(.clk(clk), .addr(~promaddr), .q(iprom));

endmodule
