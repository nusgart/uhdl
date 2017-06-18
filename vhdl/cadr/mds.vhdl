-- MDS
--
-- TK		CADR	MEMORY DATA SELECTOR

entity MDS is
  port (
    busint_bus : in  std_logic_vector(31 downto 0);
    md         : in  std_logic_vector(31 downto 0);
    ob         : in  std_logic_vector(31 downto 0);
    loadmd     : in  std_logic;
    mdsel      : in  std_logic;
    memdrive   : in  std_logic;
    mds        : out std_logic_vector(31 downto 0);
    );
end entity;

architecture behavioral of MDS is
signal mem:std_logic_vector(31 downto 0);
begin

   assign mds = mdsel ? ob : mem;

   -- mux MEM
   assign mem =
	       memdrive ? md :
	       loadmd ? busint_bus :
	       32'b0;

end architecture;
