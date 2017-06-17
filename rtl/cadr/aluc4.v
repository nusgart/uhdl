// ALUC4
//
// TK		CADR	ALU CARRY AND FUNCTION

module ALUC4(yout15, yout11, yout7, yout3, xout15, xout11, xout7, xout3, yout31, yout27, yout23, yout19, xout31, xout27, xout23, xout19, a, ir, iralu, irjump, mul, div, q, osel, divposlasttime, divsubcond, divaddcond, mulnop, aluadd, alusub, aluf, alumode, cin12_n, cin8_n, cin4_n, cin0, xx0, yy0, cin28_n, cin24_n, cin20_n, cin16_n, xx1, yy1, cin32_n);

   input [31:0] a;
   input [31:0] q;
   input [48:0] ir;
   input	div;
   input	iralu;
   input	irjump;
   input	mul;
   input	xout3, xout7, xout11, xout15, xout19, xout23, xout27, xout31;
   input	yout3, yout7, yout11, yout15, yout19, yout23, yout27, yout31;
   output [1:0] osel;
   output [3:0] aluf;
   output	aluadd;
   output	alumode;
   output	alusub;
   output	cin0;
   output	cin4_n, cin8_n, cin12_n, cin16_n, cin20_n, cin24_n, cin28_n, cin32_n;
   output	divaddcond;
   output	divposlasttime;
   output	divsubcond;
   output	mulnop;
   output	xx0;
   output	xx1;
   output	yy0;
   output	yy1;

   ////////////////////////////////////////////////////////////////////////////////

   ic_74S182  i_ALUC4_2A20 (
			    .Y( { yout15,yout11,yout7,yout3 } ),
			    .X( { xout15,xout11,xout7,xout3 } ),
			    .COUT2_N(cin12_n),
			    .COUT1_N(cin8_n),
			    .COUT0_N(cin4_n),
			    .CIN_N(~cin0),
			    .XOUT(xx0),
			    .YOUT(yy0)
			    );

   ic_74S182  i_ALUC4_2A19 (
			    .Y( { yout31,yout27,yout23,yout19 } ),
			    .X( { xout31,xout27,xout23,xout19 } ),
			    .COUT2_N(cin28_n),
			    .COUT1_N(cin24_n),
			    .COUT0_N(cin20_n),
			    .CIN_N(cin16_n),
			    .XOUT(xx1),
			    .YOUT(yy1)
			    );

   ic_74S182  i_ALUC4_2A18 (
			    .Y( { 2'b00, yy1,yy0 } ),
			    .X( { 2'b00, xx1,xx0 } ),
			    .COUT1_N(cin32_n),
			    .COUT0_N(cin16_n),
			    .CIN_N(~cin0),
			    .COUT2_N(),
			    .XOUT(),
			    .YOUT()
			    );


   assign    divposlasttime  = q[0] | ir[6];

   assign    divsubcond = div & divposlasttime;

   assign    divaddcond = div & (ir[5] | ~divposlasttime);

   assign    mulnop = mul & ~q[0];

   assign    aluadd = (divaddcond & ~a[31]) |
		      (divsubcond & a[31]) |
		      mul;

   assign    alusub = mulnop |
		      (divsubcond & ~a[31]) |
		      (divaddcond & a[31]) |
		      irjump;

   assign osel[1] = ir[13] & iralu;
   assign osel[0] = ir[12] & iralu;

   assign aluf =
		{alusub,aluadd} == 2'b00 ? { ir[3], ir[4], ~ir[6], ~ir[5] } :
		{alusub,aluadd} == 2'b01 ? { 1'b1,   1'b0,   1'b0,  1'b1 } :
		{alusub,aluadd} == 2'b10 ? { 1'b0,   1'b1,   1'b1,  1'b0 } :
		{ 1'b1,   1'b1,   1'b1,  1'b1 };

   assign alumode =
		   {alusub,aluadd} == 2'b00 ? ~ir[7] :
		   {alusub,aluadd} == 2'b01 ? 1'b0 :
		   {alusub,aluadd} == 2'b10 ? 1'b0 :
		   1'b1;

   assign cin0 =
		{alusub,aluadd} == 2'b00 ? ir[2] :
		{alusub,aluadd} == 2'b01 ? 1'b0 :
		{alusub,aluadd} == 2'b10 ? ~irjump :
		1'b1;

endmodule
