-- ALATCH
--
-- TK		CADR	A MEMORY LATCH

entity ALATCH is
  port (
    amem : in std_logic_vector(31 downto 0);
    a    :out std_logic_vector(31 downto 0);
    );
end entity;

architecture behavioral of ALATCH is
begin

   assign a = amem;

end architecture;
