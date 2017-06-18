-- PROM0, PROM1
--
-- TK	CADR	PROM 0-511
-- TK	CADR	PROM 512-1023

entity PROM01 is
  port (
    clk : in std_logic;

    promaddr : in  std_logic_vector(8 downto 0);
    iprom    : out std_logic_vector(48 downto 0);
    );
end entity;

architecture behavioral of PROM01 is
begin

   part_512x49prom i_PROM(
			  .clk(clk),
			  .addr(~promaddr),
			  .q(iprom)
			  );

end architecture;
