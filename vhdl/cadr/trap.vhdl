-- TRAP
--
-- TK	CADR	PARITY ERROR TRAP

entity TRAP is
  port (
    boot_trap : in  std_logic;
    trap      : out std_logic;
    );
end entity;

architecture behavioral of TRAP is
begin

   assign trap = boot_trap;

end architecture;
