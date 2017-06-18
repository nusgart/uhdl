-- VMEMDR
--
-- TK	CADR	MAP OUTPUT DRIVE

entity VMEMDR is
  port (
    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_mmu   : in std_logic;
    state_write : in std_logic;

    vmo      : in  std_logic_vector(23 downto 0);
    srcmap   : in  std_logic;
    pma      : out std_logic_vector(21 downto 8);
    lvmo_22  : out std_logic;
    lvmo_23  : out std_logic;
    mapdrive : out std_logic;
    );
end entity;

architecture behavioral of VMEMDR is
begin

   -- output of vmem1 is registered
   assign lvmo_23 = vmo[23];
   assign lvmo_22 = vmo[22];
   assign pma = vmo[13:0];

   assign mapdrive = srcmap &
		     (state_alu || state_write || state_mmu || state_fetch);

end architecture;
