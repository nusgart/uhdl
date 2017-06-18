-- PDL0, PDL1
--
-- TK		CADR	PDL BUFFER LEFT
-- TK		CADR	PDL BUFFER RIGHT

entity PDL01 is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    l    : in  std_logic_vector(31 downto 0);
    pdla : in  std_logic_vector(9 downto 0);
    prp  : in  std_logic;
    pwp  : in  std_logic;
    pdl  : out std_logic_vector(31 downto 0);
    );
end entity;

architecture behavioral of PDL01 is
begin

   part_1kx32dpram_p i_PDL(
			   .reset(reset),

			   .clk_a(clk),
			   .address_a(pdla),
			   .q_a(pdl),
			   .data_a(32'b0),
			   .rden_a(prp),
			   .wren_a(1'b0),

			   .clk_b(clk),
			   .address_b(pdla),
			   .q_b(),
			   .data_b(l),
			   .rden_b(1'b0),
			   .wren_b(pwp)
			   );
end architecture;
