// LC --- LOCATION COUNTER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-05-08 07:09:38 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module LC(/*AUTOARG*/
   // Outputs
   lc, mf, lca,
   // Inputs
   clk, reset, state_alu, state_fetch, state_mmu, state_write, opc,
   vmo, md, ob, q, vma, vmap, dc, pdlidx, pdlptr, dcdrive, destlc,
   int_enable, lc0b, lc_byte_mode, lcinc, mapdrive, mddrive,
   needfetch, opcdrive, pfr, pfw, pidrive, ppdrive, prog_unibus_reset,
   qdrive, sequence_break, srclc, vmadrive
   );

   input wire clk;
   input wire reset;

   input wire state_alu;
   input wire state_fetch;
   input wire state_mmu;
   input wire state_write;

   input [13:0] opc;
   input [23:0] vmo;
   input [31:0] md;
   input [31:0] ob;
   input [31:0] q;
   input [31:0] vma;
   input [4:0] vmap;
   input [9:0] dc;
   input [9:0] pdlidx;
   input [9:0] pdlptr;
   input wire dcdrive;
   input wire destlc;
   input wire int_enable;
   input wire lc0b;
   input wire lc_byte_mode;
   input wire lcinc;
   input wire mapdrive;
   input wire mddrive;
   input wire needfetch;
   input wire opcdrive;
   input wire pfr;
   input wire pfw;
   input wire pidrive;
   input wire ppdrive;
   input wire prog_unibus_reset;
   input wire qdrive;
   input wire sequence_break;
   input wire srclc;
   input wire vmadrive;
   output [25:0] lc;
   output [31:0] mf;

   ////////////////////////////////////////////////////////////////////////////////

   reg [25:0] lc;
   output [3:0] lca; // ---!!! This can't be a wire for whatever reason...
   wire lcdrive;
   wire lcry3;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       lc <= 0;
     else if (state_fetch) begin
	if (destlc)
	  lc <= {ob[25:4], ob[3:0]};
	else
	  lc <= {lc[25:4] + { 21'b0, lcry3}, lca[3:0] };
     end

   assign {lcry3, lca[3:0]} = lc[3:0] + {3'b0, lcinc & ~lc_byte_mode} + {3'b0, lcinc};
   assign lcdrive = srclc && (state_alu || state_write || state_mmu || state_fetch);
   assign mf =
	      lcdrive ? {needfetch, 1'b0, lc_byte_mode, prog_unibus_reset, int_enable, sequence_break, lc[25:1], lc0b} :
	      opcdrive ? {16'b0, 2'b0, opc[13:0]} :
	      dcdrive ? {16'b0, 4'b0, 2'b0, dc[9:0]} :
	      ppdrive ? {16'b0, 4'b0, 2'b0, pdlptr[9:0]} :
	      pidrive ? {16'b0, 4'b0, 2'b0, pdlidx[9:0]} :
	      qdrive ? q :
	      mddrive ? md :
	      vmadrive ? vma :
	      mapdrive ? {~pfw, ~pfr, 1'b1, vmap[4:0], vmo[23:0]} :
	      32'b0;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
