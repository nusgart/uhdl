// MO1, MO2 --- MASKER/OUTPUT SELECT

`include "defines.vh"

module MO01(msk, r, a, alu, q, osel, ob);

   input [1:0] osel;
   input [31:0] a;
   input [31:0] msk;
   input [31:0] q;
   input [31:0] r;
   input [32:0] alu;
   output [31:0] ob;

   ////////////////////////////////////////////////////////////////////////////////

   wire [31:0] mo;              // Masker output.

   ////////////////////////////////////////////////////////////////////////////////

   assign mo = (msk & r) | (~msk & a);
   assign ob = osel == 2'b00 ? mo :
               osel == 2'b01 ? alu[31:0] :
               osel == 2'b10 ? alu[32:1] :
               {alu[30:0], q[31]};

endmodule
