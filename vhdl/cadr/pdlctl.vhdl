-- PDLCTL
--
-- TK	CADR	PDL BUFFER CONTROL

entity PDLCTL is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_mmu   : in std_logic;
    state_read  : in std_logic;
    state_write : in std_logic;

    ir         : in  std_logic_vector (48 downto 0);
    pdlidx     : in  std_logic_vector (9 downto 0);
    pdlptr     : in  std_logic_vector (9 downto 0);
    destpdl_p  : in  std_logic;
    destpdl_x  : in  std_logic;
    destpdltop : in  std_logic;
    nop        : in  std_logic;
    srcpdlpop  : in  std_logic;
    srcpdltop  : in  std_logic;
    pdla       : out std_logic_vector (9 downto 0);
    pdlcnt     : out std_logic;
    pdldrive   : out std_logic;
    pdlenb     : out std_logic;
    pdlwrite   : out std_logic;
    prp        : out std_logic;
    pwp        : out std_logic;
    );
end entity;

architecture behavioral of PDLCTL is
  signal pwidx : std_logic_vector (1 downto 0);
  signal pdlp  : std_logic;
begin

   /* m-src = pdl buffer, or index based write */
   assign pdlp = (state_read & ir[30]) | (~state_read & ~pwidx);

   assign pdla = pdlp ? pdlptr : pdlidx;

   assign pdlwrite = destpdltop | destpdl_x | destpdl_p;

   always @(posedge clk)
     if (reset)
       begin
	  pwidx <= 0;
       end
     else
       if (state_alu | state_write)
	 begin
	    pwidx <= destpdl_x;
	 end

   assign pwp = pdlwrite & state_write;
   assign prp = pdlenb && state_read;

   assign pdlenb = srcpdlpop | srcpdltop;

   assign pdldrive = pdlenb &
		     (state_alu || state_write || state_mmu || state_fetch);

   assign pdlcnt = (~nop & srcpdlpop) | destpdl_p;

end architecture;
