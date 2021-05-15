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

module PROM
  (input wire [8:0]   promaddr,
   output wire [48:0] iprom,

   input wire	      clk,
   input wire	      reset);

   localparam	      ADDR_WIDTH = 9;
   localparam	      DATA_WIDTH = 49;
   localparam	      MEM_DEPTH = 512;

   ////////////////////////////////////////////////////////////////////////////////

   rom #(.ADDRESS_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEM_DEPTH(MEM_DEPTH),
	 .MEM_FILE("CADR4/IRAML/promh.hex")) PROM
     (.clk_i(clk), .addr_i(promaddr), .q_o(iprom));

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
