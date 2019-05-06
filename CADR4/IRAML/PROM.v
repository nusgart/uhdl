// PROM --- PROM
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog; merge of PROM0 and PROM1.
//	???: Nets added.
//	???: Nets removed.
//   (1978-03-09 18:33:32 TK) PROM1: Initial.
//   (1978-02-06 10:16:30 TK) PROM0: Initial.

`timescale 1ns/1ps
`default_nettype none

module PROM(/*AUTOARG*/
   // Outputs
   iprom,
   // Inputs
   clk, promaddr
   );

   input clk;

   input [8:0] promaddr;
   output [48:0] iprom;

   ////////////////////////////////////////////////////////////////////////////////

   rom #(.ADDRESS_WIDTH(9), .DATA_WIDTH(49), .MEM_DEPTH(512),
	 .MEM_FILE("promh.hex")) PROM
     (.clk_i(clk), .addr_i(promaddr), .q_o(iprom));

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
