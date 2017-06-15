// TK		CADR	ALU CARRY AND FUNCTION

module ALUC4(yout15, yout11, yout7, yout3, xout15, xout11, xout7, xout3, yout31, yout27, yout23, yout19, xout31, xout27, xout23, xout19, a, ir, iralu, irjump, mul, div, q, osel, aluf, alumode, cin12_n, cin8_n, cin4_n, cin0, cin28_n, cin24_n, cin20_n, cin16_n, cin32_n);

   input [31:0] a;
   input [31:0] q;
   input [48:0] ir;
   input	div;
   input	iralu;
   input	irjump;
   input	mul;
   input	xout11;
   input	xout15;
   input	xout19;
   input	xout23;
   input	xout27;
   input	xout31;
   input	xout3;
   input	xout7;
   input	yout11;
   input	yout15;
   input	yout19;
   input	yout23;
   input	yout27;
   input	yout31;
   input	yout3;
   input	yout7;
   output [1:0] osel;
   output [3:0] aluf;
   output	alumode;
   output	cin0;
   output	cin12_n;
   output	cin16_n;
   output	cin20_n;
   output	cin24_n;
   output	cin28_n;
   output	cin32_n;
   output	cin4_n;
   output	cin8_n;

   ////////////////////////////////////////////////////////////////////////////////

   wire		aluadd;
   wire		alusub;
   wire		divaddcond;
   wire		divposlasttime;
   wire		divsubcond;
   wire		mulnop;
   wire		xx0;
   wire		xx1;
   wire		yy0;
   wire		yy1;

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
