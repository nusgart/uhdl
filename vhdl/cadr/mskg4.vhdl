-- MSKG4
--
-- TK		CADR	MASK GENERATION

entity MSKG4 is
  port (
    clk : in std_logic;

    mskl : in  std_logic_vector (4 downto 0);
    mskr : in  std_logic_vector (4 downto 0);
    msk  : out std_logic_vector (31 downto 0);
    );
end entity;

architecture behavioral of MSKG4 is
  signal msk_left_out  : std_logic_vector (31 downto 0);
  signal msk_right_out : std_logic_vector (31 downto 0);
begin

   part_32x32prom_maskleft i_MSKR(
				  .clk(~clk),
				  .q(msk_left_out),
				  .addr(mskl)
				  );

   part_32x32prom_maskright i_MSKL(
				   .clk(~clk),
				   .q(msk_right_out),
				   .addr(mskr)
				   );

   assign msk = msk_right_out & msk_left_out;

end architecture;
