// VMAS
//
// TK	CADR	VMA INPUT SELECTOR

module VMAS(vmas, mapi, vmasel, ob, memprepare, md, vma, lc);

   input [25:0] lc;
   input [31:0] md;
   input [31:0] ob;
   input [31:0] vma;
   input	memprepare;
   input	vmasel;
   //       22221111111111
   // mapi  32109876543210
   //       1
   // vmem0 09876543210
   //
   output [23:8] mapi;
   output [31:0] vmas;

   ////////////////////////////////////////////////////////////////////////////////

   assign vmas = vmasel ? ob : { 8'b0, lc[25:2] };

   assign mapi = ~memprepare ? md[23:8] : vma[23:8];

endmodule
