-- AMEM0, AMEM1
--
-- TK		CADR	A MEMORY LEFT
-- TK		CADR	A MEMORY RIGHT

entity AMEM01 is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    l    : in  std_logic_vector (31 downto 0);
    aadr : in  std_logic_vector (9 downto 0);
    arp  : in  std_logic;
    awp  : in  std_logic;
    amem : out std_logic_vector (31 downto 0);
    );
end entity;

architecture behavioral of AMEM01 is
begin

   part_1kx32dpram_a i_AMEM(
			    .reset(reset),

			    .clk_a(clk),
			    .address_a(aadr),
			    .data_a(32'b0),
			    .q_a(amem),
			    .wren_a(1'b0),
			    .rden_a(arp),

			    .clk_b(clk),
			    .address_b(aadr),
			    .data_b(l),
			    .q_b(),
			    .wren_b(awp),
			    .rden_b(1'b0)
			    );

end architecture;
