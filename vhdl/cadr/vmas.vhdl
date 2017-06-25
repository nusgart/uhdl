-- VMAS
--
-- TK	CADR	VMA INPUT SELECTOR

entity VMAS is
  port (
    lc         : in  std_logic_vector (25 downto 0);
    md         : in  std_logic_vector (31 downto 0);
    ob         : in  std_logic_vector (31 downto 0);
    vma        : in  std_logic_vector (31 downto 0);
    memprepare : in  std_logic;
    vmasel     : in  std_logic;
    mapi       : out std_logic_vector (23 downto 8);
    vmas       : out std_logic_vector (31 downto 0);
    );
end entity;

architecture behavioral of VMAS is
begin

   assign vmas = vmasel ? ob : { 8'b0, lc[25:2] };

   assign mapi = ~memprepare ? md[23:8] : vma[23:8];

end architecture;
