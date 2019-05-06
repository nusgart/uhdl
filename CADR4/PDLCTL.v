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

   input clk;
   input reset;

   input state_alu;
   input state_fetch;
   input state_mmu;
   input state_read;
   input state_write;

   input [48:0] ir;
   input [9:0] pdlidx;
   input [9:0] pdlptr;
   input destpdl_p;
   input destpdl_x;
   input destpdltop;
   input nop;
   input srcpdlpop;
   input srcpdltop;
   output [9:0] pdla;
   output pdlcnt;
   output pdldrive;
   output pdlenb;
   output pdlwrite;
   output prp;
   output pwp;

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
