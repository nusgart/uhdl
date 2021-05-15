// FLAG --- FLAGS, CONDITIONALS
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-17 14:57:25 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module FLAG
  (input wire	     state_fetch,

   input wire [31:0] ob,
   input wire [31:0] r,
   input wire [32:0] alu,
   input wire [48:0] ir,
   input wire	     aeqm,
   input wire	     destintctl,
   input wire	     nopa,
   input wire	     sintr,
   input wire	     vmaok,
   output reg	     int_enable,
   output wire	     jcond,
   output reg	     lc_byte_mode,
   output reg	     prog_unibus_reset,
   output reg	     sequence_break,

   input wire	     clk,
   input wire	     reset);

   wire [2:0]	     conds;
   wire		     ilong;
   wire		     pgf_or_int;
   wire		     pgf_or_int_or_sb;
   wire		     sint;
   wire		     statbit;
   wire		     aluneg;

   ////////////////////////////////////////////////////////////////////////////////

   assign statbit = ~nopa & ir[46];
   assign ilong = ~nopa & ir[45];
   assign aluneg = ~aeqm & alu[32];
   assign sint = sintr & int_enable;
   assign pgf_or_int = ~vmaok | sint;
   assign pgf_or_int_or_sb = ~vmaok | sint | sequence_break;
   assign conds = ir[2:0] & {ir[5], ir[5], ir[5]};
   assign jcond = conds == 3'b000 ? r[0] :
		  conds == 3'b001 ? aluneg :
		  conds == 3'b010 ? alu[32] :
		  conds == 3'b011 ? aeqm :
		  conds == 3'b100 ? ~vmaok :
		  conds == 3'b101 ? pgf_or_int :
		  conds == 3'b110 ? pgf_or_int_or_sb :
		  1'b1;

   always @(posedge clk)
     if (reset) begin
	lc_byte_mode <= 0;
	prog_unibus_reset <= 0;
	int_enable <= 0;
	sequence_break <= 0;
     end else if (state_fetch && destintctl) begin
	lc_byte_mode <= ob[29];
	prog_unibus_reset <= ob[28];
	int_enable <= ob[27];
	sequence_break <= ob[26];
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
