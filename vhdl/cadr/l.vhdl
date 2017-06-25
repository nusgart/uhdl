-- L

entity L is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_alu   : in std_logic;
    state_write : in std_logic;

    ob     : in  std_logic_vector (31 downto 0);
    vmaenb : in  std_logic;
    l      : out std_logic_vector (31 downto 0);
    );
end entity;

architecture behavioral of L is
  signal l : std_logic_vector (31 downto 0);
begin

   always @(posedge clk)
     if (reset)
       l <= 0;
     else
       -- vma is latched during alu, so this must be too
       if ((vmaenb && (state_write||state_alu)) || (~vmaenb && state_alu))
	 l <= ob;

end architecture;
