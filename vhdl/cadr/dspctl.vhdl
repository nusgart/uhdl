-- DSPCTL
--
-- TK		CADR	DISPATCH CONTROL

entity DSPCTL is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    funct    : in  std_logic_vector(3 downto 0);
    ir       : in  std_logic_vector(48 downto 0);
    irdisp   : in  std_logic;
    dmask    : out std_logic_vector(6 downto 0);
    dc       : out std_logic_vector(9 downto 0);
    dispwr   : out std_logic;
    dmapbenb : out std_logic;
    );
end entity;

architecture behavioral of DSPCTL is
signal dc : std_logic_vector(9 downto 0);
   signal nc_dmask:std_logic;
begin

   assign dmapbenb  = ir[8] | ir[9];

   assign dispwr = irdisp & funct[2];

   always @(posedge clk)
     if (reset)
       dc <= 0;
     else
       if (state_fetch && irdisp)
	 dc <= ir[41:32];

   part_32x8prom i_DMASK(
			 .clk(~clk),
			 .addr( {1'b0, 1'b0, ir[7], ir[6], ir[5]} ),
			 .q( {nc_dmask, dmask[6:0]} )
			 );

end architecture;
