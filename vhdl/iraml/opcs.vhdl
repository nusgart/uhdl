-- OPCS
--
-- TK		CADR	OLD PC SAVE SHIFTER

entity OPCS is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    pc     : in  std_logic_vector (13 downto 0);
    opcclk : in  std_logic;
    opcinh : in  std_logic;
    opc    : out std_logic_vector (13 downto 0);
    );
end entity;

architecture behavioral of OPCS is
  signal opc : std_logic_vector (13 downto 0);
begin

   assign opcclka = (state_fetch | opcclk) & ~opcinh;

   always @(posedge clk)
     if (reset)
       opc <= 0;
     else
       if (opcclka)
	 opc <= pc;

end architecture;
