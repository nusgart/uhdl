-- VCTL1
--
-- TK	CADR	VMEMORY CONTROL

entity VCTL1 is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_alu      : in std_logic;
    state_fetch    : in std_logic;
    state_prefetch : in std_logic;
    state_write    : in std_logic;

    ifetch     : in  std_logic;
    lcinc      : in  std_logic;
    lvmo_22    : in  std_logic;
    lvmo_23    : in  std_logic;
    memack     : in  std_logic;
    memrd      : in  std_logic;
    memwr      : in  std_logic;
    needfetch  : in  std_logic;
    memprepare : out std_logic;
    memrq      : out std_logic;
    memstart   : out std_logic;
    pfr        : out std_logic;
    pfw        : out std_logic;
    vmaok      : out std_logic;
    waiting    : out std_logic;
    wrcyc      : out std_logic;
    );
end entity;

architecture behavioral of VCTL1 is
  signal mbusy      : std_logic_vector (1 downto 0);
  signal memcheck   : std_logic_vector (1 downto 0);
  signal memprepare : std_logic_vector (1 downto 0);
  signal memstart   : std_logic_vector (1 downto 0);
  signal rdcyc      : std_logic_vector (1 downto 0);
  signal vmaok      : std_logic_vector (1 downto 0);
  signal wrcyc      : std_logic_vector (1 downto 0);
  signal mfinish    : std_logic;
begin

   assign memop  = memrd | memwr | ifetch;

   always @(posedge clk)
     if (reset)
       memprepare <= 0;
     else
       if (state_alu || state_write)
	 memprepare <= memop;
       else
	 memprepare <= 0;

   -- read vmem
   always @(posedge clk)
     if (reset)
       memstart <= 0;
     else
       if (~state_alu)
	 memstart <= memprepare;
       else
	 memstart <= 0;

   -- check result of vmem
   always @(posedge clk)
     if (reset)
       memcheck <= 0;
     else
       memcheck <= memstart;

   assign pfw = (lvmo_23 & lvmo_22) & wrcyc;	/* write permission */
   assign pfr = lvmo_23 & ~wrcyc;		/* read permission */

   always @(posedge clk)
     if (reset)
       vmaok <= 1'b0;
     else
       if (memcheck)
	 vmaok <= pfr | pfw;

   always @(posedge clk)
     if (reset)
       begin
	  rdcyc <= 0;
	  wrcyc <= 0;
       end
     else
       if ((state_fetch || state_prefetch) && memstart && memcheck)
	 begin
	    if (memwr)
	      begin
		 rdcyc <= 0;
		 wrcyc <= 1;
	      end
	    else
	      begin
		 rdcyc <= 1;
		 wrcyc <= 0;
	      end
	 end
       else
	 if ((~memrq && ~memprepare && ~memstart) || mfinish)
	   begin
	      rdcyc <= 0;
	      wrcyc <= 0;
	   end

   assign memrq = mbusy | (memcheck & ~memstart & (pfr | pfw));

   always @(posedge clk)
     if (reset)
       mbusy <= 0;
     else
       --       if (mfinish)
       --	 mbusy <= 1'b0;
       --       else
       --	 mbusy <= memrq;
       if (mfinish)
	 mbusy <= 1'b0;
       else
	 if (memcheck & (pfr | pfw))
	   mbusy <= 1;

   --always @(posedge clk) if (memstart) $display("memstart! %t", $time);

   --------

   assign mfinish = memack | reset;

   assign waiting =
		   (memrq & mbusy) |
		   (lcinc & needfetch & mbusy);		/* ifetch */

end architecture;
