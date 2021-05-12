// IOR --- INST. MODIFY OR
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-01-22 12:19:30 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module IOR
  (input wire [31:0]  ob,
   input wire [48:0]  i,
   output wire [47:0] iob,

   input wire	      clk,
   input wire	      reset);

   ////////////////////////////////////////////////////////////////////////////////

   assign iob = i[47:0] | {ob[21:0], ob[25:0]};

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
