// OPCS --- OLD PC SAVE SHIFTER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-06-24 04:24:21 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module OPCS(/*AUTOARG*/
   // Outputs
   opc,
   // Inputs
   clk, reset, state_fetch, pc, opcclk, opcinh
   );

   input wire clk;
   input wire reset;

   input wire state_fetch;

   input [13:0] pc;
   input wire opcclk;
   input wire opcinh;
   output [13:0] opc;

   ////////////////////////////////////////////////////////////////////////////////

   reg [13:0] opc;
   wire opcclka;

   ////////////////////////////////////////////////////////////////////////////////

   assign opcclka = (state_fetch | opcclk) & ~opcinh;

   always @(posedge clk)
     if (reset)
       opc <= 0;
     else if (opcclka)
       opc <= pc;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
