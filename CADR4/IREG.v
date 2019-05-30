// IREG --- INSTRUCTION REGISTER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-01-24 13:34:10 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module IREG(/*AUTOARG*/
   // Outputs
   ir,
   // Inputs
   clk, reset, state_fetch, iob, i, destimod0, destimod1
   );

   input wire clk;
   input wire reset;

   input wire state_fetch;

   input [47:0] iob;
   input [48:0] i;
   input wire destimod0;
   input wire destimod1;
   output [48:0] ir;

   ////////////////////////////////////////////////////////////////////////////////

   reg [48:0] ir;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       ir <= 49'b0;
     else if (state_fetch) begin
	ir[48] <= ~destimod1 ? i[48] : 1'b0;
	ir[47:26] <= ~destimod1 ? i[47:26] : iob[47:26];
	ir[25:0] <= ~destimod0 ? i[25:0] : iob[25:0];
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
