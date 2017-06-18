-- MO1, MO2
--
-- TK		CADR	MASKER/OUTPUT SELECT

entity MO01 is
  port (
    osel : in  std_logic_vector(1 downto 0);
    a    : in  std_logic_vector(31 downto 0);
    msk  : in  std_logic_vector(31 downto 0);
    q    : in  std_logic_vector(31 downto 0);
    r    : in  std_logic_vector(31 downto 0);
    alu  : in  std_logic_vector(32 downto 0);
    ob   : out std_logic_vector(31 downto 0);
    );
end entity;

architecture behavioral of MO01 is
signal mo:std_logic_vector(31 downto 0);
begin

   --for (i = 0; i < 31; i++)
   --  assign mo[i] =
   --	osel == 2'b00 ? (msk[i] ? r[i] : a[i]) : a[i];

   -- msk r  a       (msk&r)|(~msk&a)
   --  0  0  0   0      0 0  0
   --  0  0  1   1      0 1  1
   --  0  1  0   0      0 0  0
   --  0  1  1   1      0 1  1
   --  1  0  0   0      0 0  0
   --  1  0  1   0      0 0  0
   --  1  1  0   1      1 0  1
   --  1  1  1   1      1 0  1

   -- masker output
   assign mo = (msk & r) | (~msk & a);

   assign ob =
	      osel == 2'b00 ? mo :
	      osel == 2'b01 ? alu[31:0] :
	      osel == 2'b10 ? alu[32:1] :
	      /*2'b11*/ {alu[30:0],q[31]};

end architecture;
