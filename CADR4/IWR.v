// IWR --- INSTRUCTION WRITE REGISTER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-02 20:02:15 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module IWR(/*AUTOARG*/
   // Outputs
   iwr,
   // Inputs
   clk, reset, state_fetch, a, m
   );

   input wire clk;
   input wire reset;

   input wire state_fetch;

   input [31:0] a;
   input [31:0] m;

   output [48:0] iwr;

   ////////////////////////////////////////////////////////////////////////////////

   reg [48:0] iwr;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       iwr <= 0;
     else if (state_fetch) begin
	iwr[48] <= 0;
	iwr[47:32] <= a[15:0];
	iwr[31:0] <= m[31:0];
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
