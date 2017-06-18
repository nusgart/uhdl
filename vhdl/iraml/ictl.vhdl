-- ICTL
--
-- TK           CADR    I RAM CONTROL

entity ICTL is
  port (
    state_write : in std_logic;

    idebug       : in  std_logic;
    iwrited      : in  std_logic;
    promdisabled : in  std_logic;
    iwe          : out std_logic
    );
end entity;

architecture behavioral of ICTL is
  signal ramdisable : std_logic;
begin

  ramdisable <= idebug or not(promdisabled or iwrited);

  -- see clocks below
  iwe <= iwrited and state_write;

end architecture;
