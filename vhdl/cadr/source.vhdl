-- SOURCE
--
-- TK	CADR	SOURCE, DEST, OP DECODE

entity SOURCE is
  port (
    ir         : in  std_logic_vector (48 downto 0);
    idebug     : in  std_logic;
    iwrited    : in  std_logic;
    nop        : in  std_logic;
    funct      : out std_logic_vector (3 downto 0);
    dest       : out std_logic;
    destimod0  : out std_logic;
    destimod1  : out std_logic;
    destintctl : out std_logic;
    destlc     : out std_logic;
    destm      : out std_logic;
    destmdr    : out std_logic;
    destmem    : out std_logic;
    destpdl_p  : out std_logic;
    destpdl_x  : out std_logic;
    destpdlp   : out std_logic;
    destpdltop : out std_logic;
    destpdlx   : out std_logic;
    destspc    : out std_logic;
    destvma    : out std_logic;
    div        : out std_logic;
    imod       : out std_logic;
    iralu      : out std_logic;
    irbyte     : out std_logic;
    irdisp     : out std_logic;
    irjump     : out std_logic;
    mul        : out std_logic;
    srcdc      : out std_logic;
    srclc      : out std_logic;
    srcmap     : out std_logic;
    srcmd      : out std_logic;
    srcopc     : out std_logic;
    srcpdlidx  : out std_logic;
    srcpdlpop  : out std_logic;
    srcpdlptr  : out std_logic;
    srcpdltop  : out std_logic;
    srcq       : out std_logic;
    srcspc     : out std_logic;
    srcspcpop  : out std_logic;
    srcvma     : out std_logic;
    );
end entity;

architecture behavioral of SOURCE is
  signal specalu : std_logic;
begin

   assign {irbyte,irdisp,irjump,iralu} =
					nop ? 4'b0000 :
					({ir[44],ir[43]} == 2'b00) ? 4'b0001 :
					({ir[44],ir[43]} == 2'b01) ? 4'b0010 :
					({ir[44],ir[43]} == 2'b10) ? 4'b0100 :
					4'b1000 ;

   assign funct =
		  nop ? 4'b0000 :
		  ({ir[11],ir[10]} == 2'b00) ? 4'b0001 :
		  ({ir[11],ir[10]} == 2'b01) ? 4'b0010 :
		  ({ir[11],ir[10]} == 2'b10) ? 4'b0100 :
		  4'b1000 ;

   assign specalu  = ir[8] & iralu;

   assign {div,mul} =
		     ~specalu ? 2'b00 :
		     ({ir[4],ir[3]} == 2'b00) ? 2'b01 : 2'b10;

   assign {srcq,srcopc,srcpdltop,srcpdlpop,
	   srcpdlidx,srcpdlptr,srcspc,srcdc} =
					      (~ir[31] | ir[29]) ? 8'b00000000 :
					      ({ir[28],ir[27],ir[26]} == 3'b000) ? 8'b00000001 :
					      ({ir[28],ir[27],ir[26]} == 3'b001) ? 8'b00000010 :
					      ({ir[28],ir[27],ir[26]} == 3'b010) ? 8'b00000100 :
					      ({ir[28],ir[27],ir[26]} == 3'b011) ? 8'b00001000 :
					      ({ir[28],ir[27],ir[26]} == 3'b100) ? 8'b00010000 :
					      ({ir[28],ir[27],ir[26]} == 3'b101) ? 8'b00100000 :
					      ({ir[28],ir[27],ir[26]} == 3'b110) ? 8'b01000000 :
					      8'b10000000;

   assign {srcspcpop,srclc,srcmd,srcmap,srcvma} =
						 (~ir[31] | ~ir[29]) ? 5'b00000 :
						 ({ir[28],ir[27],ir[26]} == 3'b000) ? 5'b00001 :
						 ({ir[28],ir[27],ir[26]} == 3'b001) ? 5'b00010 :
						 ({ir[28],ir[27],ir[26]} == 3'b010) ? 5'b00100 :
						 ({ir[28],ir[27],ir[26]} == 3'b011) ? 5'b01000 :
						 ({ir[28],ir[27],ir[26]} == 3'b100) ? 5'b10000 :
						 5'b00000 ;

   assign imod = destimod0 | destimod1 | iwrited | idebug;

   assign destmem = destm & ir[23];
   assign destvma = destmem & ~ir[22];
   assign destmdr = destmem & ir[22];

   assign dest = iralu | irbyte;	/* destination field is valid */
   assign destm = dest & ~ir[25];	/* functional destination */

   assign {destintctl,destlc} =
			       !(destm & ~ir[23] & ~ir[22]) ? 2'b00 :
			       ({ir[21],ir[20],ir[19]} == 3'b001) ? 2'b01 :
			       ({ir[21],ir[20],ir[19]} == 3'b010) ? 2'b10 :
			       2'b00 ;

   assign {destimod1,destimod0,destspc,destpdlp,
	   destpdlx,destpdl_x,destpdl_p,destpdltop} =
						     !(destm & ~ir[23] & ir[22]) ? 8'b00000000 :
						     ({ir[21],ir[20],ir[19]} == 3'b000) ? 8'b00000001 :
						     ({ir[21],ir[20],ir[19]} == 3'b001) ? 8'b00000010 :
						     ({ir[21],ir[20],ir[19]} == 3'b010) ? 8'b00000100 :
						     ({ir[21],ir[20],ir[19]} == 3'b011) ? 8'b00001000 :
						     ({ir[21],ir[20],ir[19]} == 3'b100) ? 8'b00010000 :
						     ({ir[21],ir[20],ir[19]} == 3'b101) ? 8'b00100000 :
						     ({ir[21],ir[20],ir[19]} == 3'b110) ? 8'b01000000 :
						     ({ir[21],ir[20],ir[19]} == 3'b111) ? 8'b10000000 :
						     8'b00000000;

end architecture;
