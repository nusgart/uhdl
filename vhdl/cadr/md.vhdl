-- MD
--
-- TK		CADR	MEMORY DATA REGISTER

entity MD is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_mmu   : in std_logic;
    state_write : in std_logic;

    spy_in    : in  std_logic_vector(15 downto 0);
    mds       : in  std_logic_vector(31 downto 0);
    destmdr   : in  std_logic;
    ldmdh     : in  std_logic;
    ldmdl     : in  std_logic;
    loadmd    : in  std_logic;
    memrq     : in  std_logic;
    srcmd     : in  std_logic;
    md        : out std_logic_vector(31 downto 0);
    mddrive   : out std_logic;
    mdgetspar : out std_logic;
    );
end entity;

architecture behavioral of MD is
signal md : std_logic_vector(31 downto 0);
   reg		 mdhaspar;
   reg		 mdpar;
   signal ignpar:std_logic;
   signal mdclk:std_logic;
begin

   assign mdgetspar = ~destmdr & ~ignpar;
   assign ignpar = 1'b0;

   assign mdclk = loadmd | destmdr;

   always @(posedge clk)
     if (reset)
       begin
	  md <= 32'b0;
	  mdhaspar <= 1'b0;
	  mdpar <= 1'b0;
       end
     else
       if ((loadmd && memrq) || (state_alu && destmdr))
	 begin
	    md <= mds;
	    mdhaspar <= mdgetspar;
	 end
       else
	 if (ldmdh)
	   md[31:16] <= spy_in;
	 else
	   if (ldmdl)
	     md[15:0] <= spy_in;

   assign mddrive = srcmd &
		    (state_alu || state_write || state_mmu || state_fetch);

   assign mdgetspar = ~destmdr & ~ignpar;
   assign ignpar = 1'b0;

   assign mdclk = loadmd | destmdr;

end architecture;
