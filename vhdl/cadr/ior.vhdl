-- IOR
--
-- TK		CADR	INST. MODIFY OR

entity IOR is
  port (
    ob  : in  std_logic_vector (31 downto 0);
    i   : in  std_logic_vector (48 downto 0);
    iob : out std_logic_vector (47 downto 0);
    );
end entity;

architecture behavioral of IOR is
begin

   -- iob 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26
   -- i   47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26
   -- ob  21 20 19 18 17 16 15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0

   -- iob 25 24 ... 1  0
   -- i   25 24 ... 1  0
   -- ob  25 24 ... 1  0

   assign iob = i[47:0] | { ob[21:0], ob[25:0] };

end architecture;
