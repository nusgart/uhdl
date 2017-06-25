-- SPCLCH
--
-- TK	CADR	SPC MEMORY LATCH

entity SPCLCH is
  port (
    spco : in  std_logic_vector (18 downto 0);
    spc  : out std_logic_vector (18 downto 0);
    );
end entity;

architecture behavioral of SPCLCH is
begin

   -- mux SPC
   assign spc = spco;

end architecture;
