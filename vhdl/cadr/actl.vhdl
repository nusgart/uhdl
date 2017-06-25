-- ACTL
--
-- TK		CADR	A CONTROL

entity ACTL is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_decode : in std_logic;
    state_write  : in std_logic;

    ir    : in  std_logic_vector (48 downto 0);
    dest  : in  std_logic;
    destm : in  std_logic;
    aadr  : out std_logic_vector (9 downto 0);
    wadr  : out std_logic_vector (9 downto 0);
    arp   : out std_logic;
    awp   : out std_logic;
    );
end entity;

architecture behavioral of ACTL is
  signal wadr : std_logic_vector (9 downto 0);
begin

   always @(posedge clk)
     if (reset)
       begin
	  wadr <= 0;
       end
     else
       if (state_decode)
	 begin
	    -- wadr 9  8  7  6  5  4  3  2  1  0
	    --      0  0  0  0  0  18 17 16 15 14
	    -- ir   23 22 21 20 19 18 17 16 15 14
	    wadr <= destm ? { 5'b0, ir[18:14] } : { ir[23:14] };
	 end

   assign awp = dest & state_write;
   assign arp = state_decode;

   -- use wadr during state_write
   assign aadr = ~state_write ? { ir[41:32] } : wadr;

end architecture;
