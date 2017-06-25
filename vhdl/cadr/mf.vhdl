-- MF
--
-- TK		CADR	DRIVE MF ONTO M

entity MF is
  port (
    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_mmu   : in std_logic;
    state_write : in std_logic;

    pdlenb  : in  std_logic;
    spcenb  : in  std_logic;
    srcm    : in  std_logic;
    mfdrive : out std_logic;
    );
end entity;

architecture behavioral of MF is
  signal mfenb : std_logic;
begin

   assign mfenb = ~srcm & !(spcenb | pdlenb);
   assign mfdrive = mfenb &
		    (state_alu || state_write || state_mmu || state_fetch);

end architecture;
