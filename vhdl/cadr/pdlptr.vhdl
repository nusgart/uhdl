-- PDLPTR
--
-- TK	CADR	PDL INDEX AND POINTER

entity PDLPTR is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_read  : in std_logic;
    state_write : in std_logic;

    ob        : in  std_logic_vector (31 downto 0);
    destpdlp  : in  std_logic;
    destpdlx  : in  std_logic;
    pdlcnt    : in  std_logic;
    srcpdlidx : in  std_logic;
    srcpdlpop : in  std_logic;
    srcpdlptr : in  std_logic;
    pdlidx    : out std_logic_vector (9 downto 0);
    pdlptr    : out std_logic_vector (9 downto 0);
    pidrive   : out std_logic;
    ppdrive   : out std_logic;
    );
end entity;

architecture behavioral of PDLPTR is
  signal pdlidx : std_logic_vector (9 downto 0);
  signal pdlptr : std_logic_vector (9 downto 0);
begin

   assign pidrive = srcpdlidx & (state_alu || state_write || state_fetch);

   assign ppdrive  = srcpdlptr & (state_alu || state_write || state_fetch);

   always @(posedge clk)
     if (reset)
       pdlidx <= 0;
     else
       if (state_write && destpdlx)
	 pdlidx <= ob[9:0];

   -- pdlpop = read[pdlptr] (state_read), pdlptr-- (state_fetch)
   -- pdlpush = pdlptr++ (state_read), write[pdlptr] (state_write)

   always @(posedge clk)
     if (reset)
       pdlptr <= 0;
     else
       if (state_read)
	 begin
	    if (~destpdlp && pdlcnt && ~srcpdlpop)
	      pdlptr <= pdlptr + 10'd1;
	 end
       else
	 if (state_fetch)
	   begin
	      if (destpdlp)
		pdlptr <= ob[9:0];
	      else
		if (pdlcnt && srcpdlpop)
		  pdlptr <= pdlptr - 10'd1;
	   end

   --       if (state_fetch)
   --	 begin
   --	    if (destpdlp)
   --	      pdlptr <= ob[9:0];
   --	    else
   --	      if (pdlcnt)
   --		begin
   --		   if (srcpdlpop)
   --		     pdlptr <= pdlptr - 10'd1;
   --		   else
   --		     pdlptr <= pdlptr + 10'd1;
   --		end
   --	 end

end architecture;
