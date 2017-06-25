-- IWR
--
-- TK		CADR	INSTRUCTION WRITE REGISTER

entity IWR is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    a   : in  std_logic_vector (31 downto 0);
    m   : in  std_logic_vector (31 downto 0);
    iwr : out std_logic_vector (48 downto 0);
    );
end entity;

architecture behavioral of IWR is
  signal iwr : std_logic_vector (48 downto 0);
begin

   always @(posedge clk)
     if (reset)
       iwr <= 0;
     else
       if (state_fetch)
	 begin
	    iwr[48] <= 0;
	    iwr[47:32] <= a[15:0];
	    iwr[31:0] <= m[31:0];
	 end

end architecture;
