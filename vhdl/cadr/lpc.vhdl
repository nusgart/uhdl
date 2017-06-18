-- LPC
--
-- CADR	LAST PC

entity LPC is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    pc       : in  std_logic_vector(13 downto 0);
    ir       : in  std_logic_vector(48 downto 0);
    irdisp   : in  std_logic;
    lpc_hold : in  std_logic;
    wpc      : out std_logic_vector(13 downto 0);
    );
end entity;

architecture behavioral of LPC is
signal lpc : std_logic_vector(13 downto 0);
begin

   always @(posedge clk)
     if (reset)
       lpc <= 0;
     else
       if (state_fetch)
	 begin
	    if (~lpc_hold)
	      lpc <= pc;
	 end

   /* dispatch and instruction as N set */
   assign wpc = (irdisp & ir[25]) ? lpc : pc;

end architecture;
