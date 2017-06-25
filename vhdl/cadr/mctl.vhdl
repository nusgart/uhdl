-- MCTL
--
-- TK		CADR	M CONTROL

entity MCTL is
  port (
    state_decode : in std_logic;
    state_write  : in std_logic;

    ir     : in  std_logic_vector (48 downto 0);
    wadr   : in  std_logic_vector (9 downto 0);
    destm  : in  std_logic;
    madr   : out std_logic_vector (4 downto 0);
    mpassm : out std_logic;
    mrp    : out std_logic;
    mwp    : out std_logic;
    srcm   : out std_logic;
    );
end entity;

architecture behavioral of MCTL is
begin

   -- assign mpass = { 1'b1, ir[30:26] } == { destm, wadr[4:0] };
   -- assign mpassl = mpass & phase1 & ~ir[31];
   assign mpassm = /*~mpass & phase1 &*/ ~ir[31];

   assign srcm = ~ir[31]/* & ~mpass*/;	/* srcm = m-src is m-memory */

   assign mrp = state_decode;
   assign mwp = destm & state_write;

   -- use wadr during state_write
   assign madr = ~state_write ? ir[30:26] : wadr[4:0];

end architecture;
