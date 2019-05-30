// VMAS --- VMA INPUT SELECTOR
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-05-08 07:24:22 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module VMAS(/*AUTOARG*/
   // Outputs
   mapi, vmas,
   // Inputs
   lc, md, ob, vma, memprepare, vmasel
   );

   input [25:0] lc;
   input [31:0] md;
   input [31:0] ob;
   input [31:0] vma;
   input wire memprepare;
   input wire vmasel;

   output [23:8] mapi;
   output [31:0] vmas;

   ////////////////////////////////////////////////////////////////////////////////

   assign vmas = vmasel ? ob : {8'b0, lc[25:2]};
   assign mapi = ~memprepare ? md[23:8] : vma[23:8];

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
