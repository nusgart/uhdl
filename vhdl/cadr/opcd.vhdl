-- OPCD
--
-- TK		CADR	OPC, DC, ZERO DRIVE

entity OPCD is
  port (
    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_mmu   : in std_logic;
    state_write : in std_logic;

    srcdc    : in  std_logic;
    srcopc   : in  std_logic;
    dcdrive  : out std_logic;
    opcdrive : out std_logic;
    );
end entity;

architecture behavioral of OPCD is
begin

   assign dcdrive = srcdc &	/* dispatch constant */
		    (state_alu || state_write || state_mmu || state_fetch);

   assign opcdrive = srcopc &
		     (state_alu | state_write);

end architecture;
