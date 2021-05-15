// SPCW --- SPC WRITE DATA SEL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-01-23 12:29:26 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module SPCW
  (input wire [13:0]  ipc,
   input wire [13:0]  wpc,
   input wire [31:0]  l,
   input wire	      destspc,
   input wire	      n,
   output wire [18:0] spcw,

   input wire	      clk,
   input wire	      reset);

   wire [13:0]	      reta;

   ////////////////////////////////////////////////////////////////////////////////

   assign spcw = destspc ? l[18:0] : {5'b0, reta};
   assign reta = n ? wpc : ipc;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
