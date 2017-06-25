// MO1, MO2
//
// TK		CADR	MASKER/OUTPUT SELECT

module MO01(msk, r, a, alu, q, osel, ob);

   input [1:0] osel;
   input [31:0] a;
   input [31:0] msk;
   input [31:0] q;
   input [31:0] r;
   input [32:0] alu;
   output [31:0] ob;

   ////////////////////////////////////////////////////////////////////////////////

   wire [31:0]	 mo;

   ////////////////////////////////////////////////////////////////////////////////

   //for (i = 0; i < 31; i++)
   //  assign mo[i] =
   //	osel == 2'b00 ? (msk[i] ? r[i] : a[i]) : a[i];

   // msk r  a       (msk&r)|(~msk&a)
   //  0  0  0   0      0 0  0
   //  0  0  1   1      0 1  1
   //  0  1  0   0      0 0  0
   //  0  1  1   1      0 1  1
   //  1  0  0   0      0 0  0
   //  1  0  1   0      0 0  0
   //  1  1  0   1      1 0  1
   //  1  1  1   1      1 0  1

   // masker output
   assign mo = (msk & r) | (~msk & a);

   assign ob =
	      osel == 2'b00 ? mo :
	      osel == 2'b01 ? alu[31:0] :
	      osel == 2'b10 ? alu[32:1] :
	      //2'b11
	      {alu[30:0],q[31]};

endmodule
