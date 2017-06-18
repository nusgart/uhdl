-- PCTL

library ieee;
use ieee.std_logic_1164.all;

entity PCTL is
  port (
    pc           : in     std_logic_vector(13 downto 0);
    idebug       : in     std_logic;
    iwrited      : in     std_logic;
    promdisabled : in     std_logic;
    promaddr     : out    std_logic_vector(8 downto 0);
    promenable   : buffer std_logic
    );
end entity;

architecture behavioral of PCTL is
  signal prompc    : std_logic_vector(11 downto 0);
  signal bottom_1k : std_logic;
  signal promce    : std_logic;
begin

  bottom_1k  <= not(pc(13) or pc(12) or pc(11) or pc(10));
  promenable <= bottom_1k and not idebug and not promdisabled and not iwrited;

  promce <= promenable and not pc(9);

  prompc <= pc(11 downto 0);

  promaddr <= prompc(8 downto 0);

end architecture;
