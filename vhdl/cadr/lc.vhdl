-- LC
--
-- TK		CADR	LOCATION COUNTER

entity LC is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_mmu   : in std_logic;
    state_write : in std_logic;

    opc               : in  std_logic_vector(13 downto 0);
    vmo               : in  std_logic_vector(23 downto 0);
    md                : in  std_logic_vector(31 downto 0);
    ob                : in  std_logic_vector(31 downto 0);
    q                 : in  std_logic_vector(31 downto 0);
    vma               : in  std_logic_vector(31 downto 0);
    vmap              : in  std_logic_vector(4 downto 0);
    dc                : in  std_logic_vector(9 downto 0);
    pdlidx            : in  std_logic_vector(9 downto 0);
    pdlptr            : in  std_logic_vector(9 downto 0);
    dcdrive           : in  std_logic;
    destlc            : in  std_logic;
    int_enable        : in  std_logic;
    lc0b              : in  std_logic;
    lc_byte_mode      : in  std_logic;
    lcinc             : in  std_logic;
    mapdrive          : in  std_logic;
    mddrive           : in  std_logic;
    needfetch         : in  std_logic;
    opcdrive          : in  std_logic;
    pfr               : in  std_logic;
    pfw               : in  std_logic;
    pidrive           : in  std_logic;
    ppdrive           : in  std_logic;
    prog_unibus_reset : in  std_logic;
    qdrive            : in  std_logic;
    sequence_break    : in  std_logic;
    srclc             : in  std_logic;
    vmadrive          : in  std_logic;
    lc                : out std_logic_vector(25 downto 0);
    mf                : out std_logic_vector(31 downto 0);
    );
end entity;

architecture behavioral of LC is
signal lc : std_logic_vector(25 downto 0);
signal lca:std_logic_vector(3 downto 0);		-- ---!!! This can't be a wire for whatever reason...
   signal lcdrive:std_logic;
   signal lcry3:std_logic;
begin

   always @(posedge clk)
     if (reset)
       lc <= 0;
     else
       if (state_fetch)
	 begin
	    if (destlc)
	      lc <= { ob[25:4], ob[3:0] };
	    else
	      lc <= { lc[25:4] + { 21'b0, lcry3 }, lca[3:0] };
	 end

   assign {lcry3, lca[3:0]} =
			     lc[3:0] +
			     { 3'b0, lcinc & ~lc_byte_mode } +
			     { 3'b0, lcinc };

   assign lcdrive  = srclc &&
		     (state_alu || state_write || state_mmu || state_fetch);

   -- xxx
   -- I think the above is really
   --
   -- always @(posedge clk)
   --   begin
   --     if (destlc_n == 0)
   --       lc <= ob;
   --     else
   --       lc <= lc +
   --             !(lcinc_n | lc_byte_mode) ? 1 : 0 +
   --             lcinc ? 1 : 0;
   --   end
   --

   -- mux MF
   assign mf =
	lcdrive ?
	      { needfetch, 1'b0, lc_byte_mode, prog_unibus_reset,
		int_enable, sequence_break, lc[25:1], lc0b } :
	opcdrive ?
	      { 16'b0, 2'b0, opc[13:0] } :
	dcdrive ?
	      { 16'b0, 4'b0, 2'b0, dc[9:0] } :
	ppdrive ?
	      { 16'b0, 4'b0, 2'b0, pdlptr[9:0] } :
	pidrive ?
	      { 16'b0, 4'b0, 2'b0, pdlidx[9:0] } :
	qdrive ?
	      q :
	mddrive ?
	      md :
--	mpassl ?
--	      l :
	vmadrive ?
	      vma :
	mapdrive ?
	      { ~pfw, ~pfr, 1'b1, vmap[4:0], vmo[23:0] } :
	      32'b0;

end architecture;
