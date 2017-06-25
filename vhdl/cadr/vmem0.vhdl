-- VMEM0
--
-- TK	CADR	VIRTUAL MEMORY MAP STAGE 0

entity VMEM0 is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    mapi     : in  std_logic_vector (23 downto 8);
    vma      : in  std_logic_vector (31 downto 0);
    memstart : in  std_logic;
    srcmap   : in  std_logic;
    vm0rp    : in  std_logic;
    vm0wp    : in  std_logic;
    vmap     : out std_logic_vector (4 downto 0);
    );
end entity;

architecture behavioral of VMEM0 is
  signal vmem0_adr : std_logic_vector (10 downto 0);
  signal use_map   : std_logic;
begin

   assign vmem0_adr = mapi[23:13];

   part_2kx5dpram i_VMEM0(
			  .reset(reset),

			  .clk_a(clk),
			  .address_a(vmem0_adr),
			  .q_a(vmap),
			  .data_a(5'b0),
			  .wren_a(1'b0),
			  .rden_a(vm0rp && ~vm0wp),

			  .clk_b(clk),
			  .address_b(vmem0_adr),
			  .q_b(),
			  .data_b(vma[31:27]),
			  .wren_b(vm0wp),
			  .rden_b(1'b0)
			  );

   assign use_map = srcmap | memstart;

end architecture;
