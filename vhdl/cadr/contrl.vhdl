-- CONTRL
--
-- TK		CADR	PC, SPC CONTROL

entity CONTRL is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_write : in std_logic;

    funct         : in  std_logic_vector(3 downto 0);
    ir            : in  std_logic_vector(48 downto 0);
    destspc       : in  std_logic;
    dn            : in  std_logic;
    dp            : in  std_logic;
    dr            : in  std_logic;
    irdisp        : in  std_logic;
    irjump        : in  std_logic;
    jcond         : in  std_logic;
    nop11         : in  std_logic;
    srcspc        : in  std_logic;
    srcspcpop     : in  std_logic;
    trap          : in  std_logic;
    iwrited       : out std_logic;
    n             :out  std_logic;
    nop           : out std_logic;
    nopa          : out std_logic;
    pcs0          : out std_logic;
    pcs1          : out std_logic;
    spcdrive      : out std_logic;
    spcenb        : out std_logic;
    spcnt         : out std_logic;
    spop          : out std_logic;
    spush         : out std_logic;
    srcspcpopreal : out std_logic;
    srp           : out std_logic;
    swp           : out std_logic;
    );
end entity;

architecture behavioral of CONTRL is
   reg		inop;
   reg		iwrited;
   signal dfall:std_logic;
   signal dispenb:std_logic;
   signal ignpopj:std_logic;
   signal ipopj:std_logic;
   signal iwrite:std_logic;
   signal jcalf:std_logic;
   signal jfalse:std_logic;
   signal jret:std_logic;
   signal jretf:std_logic;
   signal popjwire:std_logic;
   signal popj:std_logic;
begin

   assign dfall  = dr & dp;			/* push-pop fall through */

   assign dispenb = irdisp & ~funct[2];

   assign ignpopj  = irdisp & ~dr;

   assign jfalse = irjump & ir[6];		/* jump and inverted-sense */

   assign jcalf = jfalse & ir[8];		/* call and inverted-sense */

   assign jret = irjump & ~ir[8] & ir[9];	/* return */

   assign jretf = jret & ir[6];			/* return and inverted-sense */

   assign iwrite = irjump & ir[8] & ir[9];	/* microcode write */

   assign ipopj = ir[42] & ~nop;

   assign popj = ipopj | iwrited;

   assign srcspcpopreal  = srcspcpop & ~nop;

   assign spop =
		((srcspcpopreal | popj) & ~ignpopj) |
		(dispenb & dr & ~dp) |
		(jret & ~ir[6] & jcond) |
		(jretf & ~jcond);

   assign spush =
		  destspc |
		  (jcalf & ~jcond) |
		  (dispenb & dp & ~dr) |
		  (irjump & ~ir[6] & ir[8] & jcond);

   assign srp = state_write;
   assign swp = spush & state_write;
   assign spcenb = srcspc | srcspcpop;
   assign spcdrive = spcenb &
		     (state_alu || state_write || state_fetch);
   assign spcnt = spush | spop;

   always @(posedge clk)
     if (reset)
       begin
	  iwrited <= 0;
       end
     else
       if (state_fetch)
	 begin
	    iwrited <= iwrite;
	 end

   /*
    * select new pc
    * {pcs1,pcs0}
    * 00 0 spc
    * 01 1 ir
    * 10 2 dpc
    * 11 3 ipc
    */

   assign pcs1 =
		!(
		  (popj & ~ignpopj) |		/* popj & !ignore */
		  (jfalse & ~jcond) |		/* jump & invert & cond-not-satisfied */
		  (irjump & ~ir[6] & jcond) |	/* jump & !invert & cond-satisfied */
		  (dispenb & dr & ~dp)		/* dispatch + return & !push */
		  );

   assign pcs0 =
		!(
		  (popj) |
		  (dispenb & ~dfall) |
		  (jretf & ~jcond) |
		  (jret & ~ir[6] & jcond)
		  );

   /*
    * N set if:
    *  trap						or
    *  iwrite (microcode write)				or
    *  dispatch & disp-N				or
    *  jump & invert-jump-selse & cond-false & !next	or
    *  jump & !invert-jump-sense & cond-true & !next
    */
   assign n =
	     trap |
	     iwrited |
	     (dispenb & dn) |
	     (jfalse & ~jcond & ir[7]) |
	     (irjump & ~ir[6] & jcond & ir[7]);

   assign nopa = inop | nop11;

   assign nop = trap | nopa;

   always @(posedge clk)
     if (reset)
       inop <= 0;
     else
       if (state_fetch)
	 inop <= n;

end architecture;
