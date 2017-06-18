-- VMEM1, VMEM2
--
-- TK	CADR	VIRTUAL MEMORY MAP STAGE 1

entity VMEM12 is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    mapi  : in  std_logic_vector(23 downto 8);
    vma   : in  std_logic_vector(31 downto 0);
    vmap  : in  std_logic_vector(4 downto 0);
    vm1rp : in  std_logic;
    vm1wp : in  std_logic;
    vmo   : out std_logic_vector(23 downto 0);
    );
end entity;

architecture behavioral of VMEM12 is
signal vmem1_adr:std_logic_vector(9 downto 0);
begin


   assign vmem1_adr = {vmap[4:0], mapi[12:8]};

   part_1kx24dpram i_VMEM1(
			   .reset(reset),

			   .clk_a(clk),
			   .address_a(vmem1_adr),
			   .q_a(vmo),
			   .data_a(24'b0),
			   .wren_a(1'b0),
			   .rden_a(vm1rp && ~vm1wp),

			   .clk_b(clk),
			   .address_b(vmem1_adr),
			   .q_b(),
			   .data_b(vma[23:0]),
			   .wren_b(vm1wp),
			   .rden_b(1'b0)
			   );

end architecture;
