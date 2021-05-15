// LCC --- LC CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-16 05:15:35 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module LCC
  (input wire	     state_fetch,

   input wire [18:0] spc,
   input wire [25:0] lc,
   input wire [48:0] ir,
   input wire	     bus_int,
   input wire	     destlc,
   input wire	     ext_int,
   input wire	     irdisp,
   input wire	     lc_byte_mode,
   input wire	     spop,
   input wire	     srcspcpopreal,
   output wire	     ifetch,
   output wire	     lc0b,
   output wire	     lcinc,
   output wire	     needfetch,
   output wire	     sh3,
   output wire	     sh4,
   output reg	     sintr,
   output wire	     spc1a,

   input wire	     clk,
   input wire	     reset);

   reg		     newlc;
   reg		     next_instrd;
   wire		     have_wrong_word;
   wire		     inst_in_2nd_or_4th_quarter;
   wire		     inst_in_left_half;
   wire		     last_byte_in_word;
   wire		     lc_modifies_mrot;
   wire		     newlc_in;
   wire		     next_instr;
   wire		     spcmung;

   ////////////////////////////////////////////////////////////////////////////////

   assign lc0b = lc[0] & lc_byte_mode;
   assign next_instr = spop & (~srcspcpopreal & spc[14]);
   assign newlc_in = have_wrong_word & ~lcinc;
   assign have_wrong_word = newlc | destlc;
   assign last_byte_in_word = ~lc[1] & ~lc0b;
   assign needfetch = have_wrong_word | last_byte_in_word;
   assign ifetch = needfetch & lcinc;
   assign spcmung = spc[14] & ~needfetch;
   assign spc1a = spcmung | spc[1];
   assign lcinc = next_instrd | (irdisp & ir[24]);

   always @(posedge clk)
     if (reset) begin
	newlc <= 0;
	sintr <= 0;
	next_instrd <= 0;
     end else if (state_fetch) begin
	newlc <= newlc_in;
	sintr <= (ext_int | bus_int);
	next_instrd <= next_instr;
     end

   assign lc_modifies_mrot = ir[10] & ir[11];
   assign inst_in_left_half = !((lc[1] ^ lc0b) | ~lc_modifies_mrot);
   assign sh4 = ~(inst_in_left_half ^ ~ir[4]);
   assign inst_in_2nd_or_4th_quarter = !(lc[0] | ~lc_modifies_mrot) & lc_byte_mode;
   assign sh3 = ~(~ir[3] ^ inst_in_2nd_or_4th_quarter);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
