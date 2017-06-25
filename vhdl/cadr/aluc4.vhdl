-- ALUC4
--
-- TK		CADR	ALU CARRY AND FUNCTION

entity ALUC4 is
  port (
    a                                                                    : in  std_logic_vector (31 downto 0);
    q                                                                    : in  std_logic_vector (31 downto 0);
    ir                                                                   : in  std_logic_vector (48 downto 0);
    div                                                                  : in  std_logic;
    iralu                                                                : in  std_logic;
    irjump                                                               : in  std_logic;
    mul                                                                  : in  std_logic;
    xout3, xout7, xout11, xout15, xout19, xout23, xout27, xout31         : in  std_logic;
    yout3, yout7, yout11, yout15, yout19, yout23, yout27, yout31         : in  std_logic;
    osel                                                                 : out std_logic_vector (1 downto 0);
    aluf                                                                 : out std_logic_vector (3 downto 0);
    output alumode;
    cin0                                                                 : out std_logic;
    cin4_n, cin8_n, cin12_n, cin16_n, cin20_n, cin24_n, cin28_n, cin32_n : out std_logic;
    );
end entity;

architecture behavioral of ALUC4 is
  signal aluadd         : std_logic;
  signal alusub         : std_logic;
  signal divaddcond     : std_logic;
  signal divposlasttime : std_logic;
  signal divsubcond     : std_logic;
  signal mulnop         : std_logic;
  signal xx0, xx1       : std_logic;
  signal yy0, yy1       : std_logic;
begin

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

end architecture;
