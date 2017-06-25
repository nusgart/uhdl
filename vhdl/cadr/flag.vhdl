-- FLAG
--
-- TK		CONS	FLAGS,CONDITIONALS

entity FLAG is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    ob                : in  std_logic_vector (31 downto 0);
    r                 : in  std_logic_vector (31 downto 0);
    alu               : in  std_logic_vector (32 downto 0);
    ir                : in  std_logic_vector (48 downto 0);
    aeqm              : in  std_logic;
    destintctl        : in  std_logic;
    nopa              : in  std_logic;
    sintr             : in  std_logic;
    vmaok             : in  std_logic;
    int_enable        : out std_logic;
    jcond             : out std_logic;
    lc_byte_mode      : out std_logic;
    prog_unibus_reset : out std_logic;
    sequence_break    : out std_logic;
    );
end entity;

architecture behavioral of FLAG is
  signal int_enable        : std_logic_vector (1 downto 0);
  signal lc_byte_mode      : std_logic_vector (1 downto 0);
  signal prog_unibus_reset : std_logic_vector (1 downto 0);
  signal sequence_break    : std_logic_vector (1 downto 0);
  signal conds             : std_logic_vector (2 downto 0);
  signal ilong             : std_logic;
  signal pgf_or_int        : std_logic;
  signal pgf_or_int_or_sb  : std_logic;
  signal sint              : std_logic;
  signal statbit           : std_logic;
begin

   assign statbit = ~nopa & ir[46];
   assign ilong  = ~nopa & ir[45];

   assign aluneg = ~aeqm & alu[32];

   assign sint = sintr & int_enable;

   assign pgf_or_int = ~vmaok | sint;
   assign pgf_or_int_or_sb = ~vmaok | sint | sequence_break;

   assign conds = ir[2:0] & {ir[5],ir[5],ir[5]};

   assign jcond =
		  conds == 3'b000 ? r[0] :
		  conds == 3'b001 ? aluneg :
		  conds == 3'b010 ? alu[32] :
		  conds == 3'b011 ? aeqm :
		  conds == 3'b100 ? ~vmaok :
		  conds == 3'b101 ? pgf_or_int :
		  conds == 3'b110 ? pgf_or_int_or_sb :
		  1'b1;

   always @(posedge clk)
     if (reset)
       begin
	  lc_byte_mode <= 0;
	  prog_unibus_reset <= 0;
	  int_enable <= 0;
	  sequence_break <= 0;
       end
     else
       if (state_fetch && destintctl)
	 begin
	    lc_byte_mode <= ob[29];
	    prog_unibus_reset <= ob[28];
	    int_enable <= ob[27];
	    sequence_break <= ob[26];
	 end

end architecture;
