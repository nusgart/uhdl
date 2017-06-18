-- IREG
--
-- TK		CADR	INSTRUCTION REGISTER

entity IREG is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    iob       : in  std_logic_vector(47 downto 0);
    i         : in  std_logic_vector(48 downto 0);
    destimod0 : in  std_logic;
    destimod1 : in  std_logic;
    ir        : out std_logic_vector(48 downto 0);
    );
end entity;

architecture behavioral of IREG is
signal ir : std_logic_vector(48 downto 0);
begin

   always @(posedge clk)
     if (reset)
       ir <= 49'b0;
     else
       if (state_fetch)
	 begin
	    ir[48] <= ~destimod1 ? i[48] : 1'b0;
	    ir[47:26] <= ~destimod1 ? i[47:26] : iob[47:26];
	    ir[25:0] <= ~destimod0 ? i[25:0] : iob[25:0];
	 end

end architecture;
