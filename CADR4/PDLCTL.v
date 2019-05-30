// PDLCTL --- PDL BUFFER CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-15 06:09:35 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module PDLCTL(/*AUTOARG*/
   // Outputs
   pdla, pdlcnt, pdldrive, pdlenb, pdlwrite, prp, pwp,
   // Inputs
   clk, reset, state_alu, state_fetch, state_mmu, state_read,
   state_write, ir, pdlidx, pdlptr, destpdl_p, destpdl_x, destpdltop,
   nop, srcpdlpop, srcpdltop
   );

   input wire clk;
   input wire reset;

   input wire state_alu;
   input wire state_fetch;
   input wire state_mmu;
   input wire state_read;
   input wire state_write;

   input [48:0] ir;
   input [9:0] pdlidx;
   input [9:0] pdlptr;
   input wire destpdl_p;
   input wire destpdl_x;
   input wire destpdltop;
   input wire nop;
   input wire srcpdlpop;
   input wire srcpdltop;
   output [9:0] pdla;
   output wire pdlcnt;
   output wire pdldrive;
   output wire pdlenb;
   output wire pdlwrite;
   output wire prp;
   output wire pwp;

   ////////////////////////////////////////////////////////////////////////////////

   reg pwidx;
   wire pdlp;

   ////////////////////////////////////////////////////////////////////////////////

   assign pdlp = (state_read & ir[30]) | (~state_read & ~pwidx);
   assign pdla = pdlp ? pdlptr : pdlidx;
   assign pdlwrite = destpdltop | destpdl_x | destpdl_p;

   always @(posedge clk)
     if (reset) begin
	pwidx <= 0;
     end else if (state_alu | state_write) begin
	pwidx <= destpdl_x;
     end

   assign pwp = pdlwrite & state_write;
   assign prp = pdlenb && state_read;
   assign pdlenb = srcpdlpop | srcpdltop;
   assign pdldrive = pdlenb & (state_alu || state_write || state_mmu || state_fetch);
   assign pdlcnt = (~nop & srcpdlpop) | destpdl_p;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
