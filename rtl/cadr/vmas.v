module VMAS(vmas, mapi, vmasel, ob, memprepare, md, vma, lc);
   output [31:0] vmas; 
   output [23:8] mapi;
   input 	 vmasel;
   input [31:0]  ob;
   input 	 memprepare;
   input [31:0]  md;
   input [31:0]  vma;
   input [25:0]  lc;
   
   assign vmas = vmasel ? ob : { 8'b0, lc[25:2] };
   
   assign mapi = ~memprepare ? md[23:8] : vma[23:8];
   
endmodule
