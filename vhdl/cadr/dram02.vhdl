-- DRAM0, DRAM1, DRAM2
--
-- TK		CADR	DISPATCH RAM

entity DRAM02 is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_prefetch : in std_logic;
    state_write    : in std_logic;

    vmo    : in  std_logic_vector (23 downto 0);
    a;     : in  std_logic_vector (31 downto 0);
    r      : in  std_logic_vector (31 downto 0);
    ir     : in  std_logic_vector (48 downto 0);
    dmask  : in  std_logic_vector (6 downto 0);
    dispwr : in  std_logic;
    dpc    : out std_logic_vector (13 downto 0);
    dn     : out std_logic;
    dp     : out std_logic;
    dr     : out std_logic;
    );
end entity;

architecture behavioral of DRAM02 is
  signal dadr   : std_logic_vector (10 downto 0);
  signal daddr0 : std_logic;
  signal dwe    : std_logic;
begin

   -- dadr  10 9  8  7  6  5  4  3  2  1  0
   -- -------------------------------------
   -- ir    22 21 20 19 18 17 16 15 14 13 d
   -- dmask x  x  x  x  6  5  4  3  2  1  x
   -- r     x  x  x  x  6  5  4  3  2  1  x

   assign daddr0 =
		   (ir[8] & vmo[18]) |
		   (ir[9] & vmo[19]) |
		   --note: the hardware shows bit 0 replaced,
		   --	but usim or's it instead.
		   (/*~dmapbenb &*/ dmask[0] & r[0]) |
		   (ir[12]);

   assign dadr =
		{ ir[22:13], daddr0 } |
		({ 4'b0000, dmask[6:1], 1'b0 } &
		 { 4'b0000, r[6:1],     1'b0 });

   assign dwe = dispwr & state_write;

   -- dispatch ram
   part_2kx17dpram i_DRAM(
			  .reset(reset),

			  .clk_a(clk),
			  .address_a(dadr),
			  .q_a({dr,dp,dn,dpc}),
			  .data_a(17'b0),
			  .wren_a(1'b0),
			  .rden_a(~state_prefetch && ~dwe),

			  .clk_b(clk),
			  .address_b(dadr),
			  .q_b(),
			  .data_b(a[16:0]),
			  .wren_b(dwe),
			  .rden_b(1'b0)
			  );

end architecture;
