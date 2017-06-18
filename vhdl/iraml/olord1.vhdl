-- OLORD1
--
-- TK		CADR	OVERLORD

entity OLORD1 is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    spy_in          : in  std_logic_vector(15 downto 0);
    boot            : in  std_logic;
    errhalt         : in  std_logic;
    ldclk           : in  std_logic;
    ldmode          : in  std_logic;
    ldopc           : in  std_logic;
    ldscratch1      : in  std_logic;
    ldscratch2      : in  std_logic;
    set_promdisable : in  std_logic;
    statstop        : in  std_logic;
    waiting         : in  std_logic;
    scratch         : out std_logic_vector(15 downto 0);
    errstop         : out std_logic;
    idebug          : out std_logic;
    lpc_hold        : out std_logic;
    machrun         : out std_logic;
    nop11           : out std_logic;
    opcclk          : out std_logic;
    opcinh          : out std_logic;
    promdisable     : out std_logic;
    promdisabled    : out std_logic;
    srun            : out std_logic;
    ssdone          : out std_logic;
    stat_ovf        : out std_logic;
    stathalt        : out std_logic;
    );
end entity;

architecture behavioral of OLORD1 is
   reg [15:0]	 scratch;
   reg		 errstop;
   reg		 idebug;
   reg		 ldstat;
   reg		 lpc_hold;
   reg		 nop11;
   reg		 opcclk;
   reg		 opcinh;
   reg		 promdisable;
   reg		 promdisabled;
   reg		 run;
   reg		 srun;
   reg		 ssdone;
   reg		 sstep;
   reg		 stathenb;
   reg		 step;
   reg		 trapenb;
begin

   always @(posedge clk)
     if (reset)
       begin
	  promdisable <= 0;
	  trapenb <= 0;
	  stathenb <= 0;
	  errstop <= 0;
       end
     else
       if (ldmode)
	 begin
	    promdisable <= spy_in[5];
	    trapenb <= spy_in[4];
	    stathenb <= spy_in[3];
	    errstop <= spy_in[2];
	    --speed1 <= spy_in[1];
	    --speed0 <= spy_in[0];
	 end
       else
	 if (set_promdisable)
	   promdisable <= 1;

   always @(posedge clk)
     if (reset)
       begin
	  scratch <= 16'h1234;
       end
     else
       if (ldscratch2 || ldscratch1)
	 begin
	    scratch <= spy_in;
	 end

   always @(posedge clk)
     if (reset)
       begin
	  opcinh <= 0;
	  opcclk <= 0;
	  lpc_hold <= 0;
       end
     else
       if (ldopc)
	 begin
	    opcinh <= spy_in[2];
	    opcclk <= spy_in[1];
	    lpc_hold <= spy_in[0];
	 end

   always @(posedge clk)
     if (reset)
       begin
	  ldstat <= 0;
	  idebug <= 0;
	  nop11 <= 0;
	  step <= 0;
       end
     else
       if (ldclk)
	 begin
	    ldstat <= spy_in[4];
	    idebug <= spy_in[3];
	    nop11 <= spy_in[2];
	    step <= spy_in[1];
	 end

   always @(posedge clk)
     if (reset)
       run <= 1'b0;
     else
       if (boot)
	 run <= 1'b1;
       else
	 if (ldclk)
	   run <= spy_in[0];

   always @(posedge clk)
     if (reset)
       begin
	  srun <= 1'b0;
	  sstep <= 1'b0;
	  ssdone <= 1'b0;
	  promdisabled <= 1'b0;
       end
     else
       begin
	  srun <= run;
	  --	  sstep <= step;
	  --	  ssdone <= sstep;
	  if (sstep == 0 && step) begin
	     sstep <= step;
	     ssdone <= 0;
	  end
	  else
	    sstep <= step;
	  if (state_fetch) ssdone <= sstep;
	  promdisabled <= promdisable;
       end

   assign machrun = (sstep & ~ssdone) |
		    (srun & ~errhalt & ~waiting & ~stathalt);

   assign stat_ovf = 1'b0;
   assign stathalt = statstop & stathenb;

end architecture;
