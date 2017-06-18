-- MMEM
--
-- TK		CADR	M MEMORY

entity MMEM is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    l    : in  std_logic_vector(31 downto 0);
    madr : in  std_logic_vector(4 downto 0);
    mrp  : in  std_logic;
    mwp  : in  std_logic;
    mmem : out std_logic_vector(31 downto 0);
    );
end entity;

architecture behavioral of MMEM is
begin

   part_32x32dpram i_MMEM(
			  .reset(reset),

			  .clk_a(clk),
			  .address_a(madr),
			  .data_a(32'b0),
			  .q_a(mmem),
			  .wren_a(1'b0),
			  .rden_a(mrp),

			  .clk_b(clk),
			  .address_b(madr),
			  .data_b(l),
			  .q_b(),
			  .wren_b(mwp),
			  .rden_b(1'b0)
			  );
end architecture;
