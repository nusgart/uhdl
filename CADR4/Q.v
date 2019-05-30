// Q --- Q REGISTER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-15 03:17:39 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module Q(/*AUTOARG*/
   // Outputs
   q,
   // Inputs
   clk, reset, state_fetch, qs0, qs1, alu
   );

   input wire clk;
   input wire reset;

   input wire state_fetch;

   input wire qs0;
   input wire qs1;

   input [32:0] alu;
   output [31:0] q;

   ////////////////////////////////////////////////////////////////////////////////

   reg [31:0] q;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       q <= 0;
     else if (state_fetch && (qs1 | qs0)) begin
	case({qs1, qs0})
	  2'b00: q <= q;
	  2'b01: q <= {q[30:0], ~alu[31]};
	  2'b10: q <= {alu[0], q[31:1]};
	  2'b11: q <= alu[31:0];
	endcase
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
