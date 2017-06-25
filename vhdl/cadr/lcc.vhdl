-- LCC
--
-- TK		CADR	LC CONTROL

entity LCC is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    spc           : in  std_logic_vector (18 downto 0);
    lc            : in  std_logic_vector (25 downto 0);
    ir            : in  std_logic_vector (48 downto 0);
    bus_int       : in  std_logic;
    destlc        : in  std_logic;
    ext_int       : in  std_logic;
    irdisp        : in  std_logic;
    lc_byte_mode  : in  std_logic;
    spop          : in  std_logic;
    srcspcpopreal : in  std_logic;
    ifetch        : out std_logic;
    lc0b          : out std_logic;
    lcinc         : out std_logic;
    needfetch     : out std_logic;
    sh3           : out std_logic;
    sh4           : out std_logic;
    sintr         : out std_logic;
    spc1a         : out std_logic;
    );
end entity;

architecture behavioral of LCC is
  signal newlc                      : std_logic_vector (1 downto 0);
  signal next_instrd                : std_logic_vector (1 downto 0);
  signal sintr                      : std_logic_vector (1 downto 0);
  signal have_wrong_word            : std_logic;
  signal inst_in_2nd_or_4th_quarter : std_logic;
  signal inst_in_left_half          : std_logic;
  signal last_byte_in_word          : std_logic;
  signal lc_modifies_mrot           : std_logic;
  signal newlc_in                   : std_logic;
  signal next_instr                 : std_logic;
  signal spcmung                    : std_logic;
begin

   assign lc0b = lc[0] & lc_byte_mode;
   assign next_instr  = spop & (~srcspcpopreal & spc[14]);

   assign newlc_in  = have_wrong_word & ~lcinc;
   assign have_wrong_word = newlc | destlc;
   assign last_byte_in_word  = ~lc[1] & ~lc0b;
   assign needfetch = have_wrong_word | last_byte_in_word;

   assign ifetch  = needfetch & lcinc;
   assign spcmung = spc[14] & ~needfetch;
   assign spc1a = spcmung | spc[1];

   assign lcinc = next_instrd | (irdisp & ir[24]);

   always @(posedge clk)
     if (reset)
       begin
	  newlc <= 0;
	  sintr <= 0;
	  next_instrd <= 0;
       end
     else
       if (state_fetch)
	 begin
	    newlc <= newlc_in;
	    sintr <= (ext_int | bus_int);
	    next_instrd <= next_instr;
	 end

   -- mustn't depend on nop

   assign lc_modifies_mrot  = ir[10] & ir[11];

   assign inst_in_left_half = !((lc[1] ^ lc0b) | ~lc_modifies_mrot);

   assign sh4  = ~(inst_in_left_half ^ ~ir[4]);

   -- LC<1:0>
   -- +---------------+
   -- | 0 | 3 | 2 | 1 |
   -- +---------------+
   -- |   0   |   2   |
   -- +---------------+

   assign inst_in_2nd_or_4th_quarter =
				      !(lc[0] | ~lc_modifies_mrot) & lc_byte_mode;

   assign sh3  = ~(~ir[3] ^ inst_in_2nd_or_4th_quarter);

end architecture;
