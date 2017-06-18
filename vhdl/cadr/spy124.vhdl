-- SPY1, SPY2, SPY4
--
-- TK	CADR	PDP11 EXAMINE (IR, OB)
-- TK	CADR	PDP11 EXAMINE (A, M, FLAG2)
-- TK	CADR	PDP11 EXAMINE (OPC, FLAG1, PC)

entity SPY124 is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_write : in std_logic;

    bd_state_in   : in  std_logic_vector(11 downto 0);
    opc           : in  std_logic_vector(13 downto 0);
    pc            : in  std_logic_vector(13 downto 0);
    scratch       : in  std_logic_vector(15 downto 0);
    a             : in  std_logic_vector(31 downto 0);
    m             : in  std_logic_vector(31 downto 0);
    md            : in  std_logic_vector(31 downto 0);
    ob            : in  std_logic_vector(31 downto 0);
    vma           : in  std_logic_vector(31 downto 0);
    ir            : in  std_logic_vector(48 downto 0);
    disk_state_in : in  std_logic_vector(4 downto 0);
    boot          : in  std_logic;
    dbread        : in  std_logic;
    destspc       : in  std_logic;
    err           : in  std_logic;
    imod          : in  std_logic;
    iwrited       : in  std_logic;
    jcond         : in  std_logic;
    nop           : in  std_logic;
    pcs0          : in  std_logic;
    pcs1          : in  std_logic;
    pdlwrite      : in  std_logic;
    promdisable   : in  std_logic;
    spush         : in  std_logic;
    spy_ah        : in  std_logic;
    spy_al        : in  std_logic;
    spy_bd        : in  std_logic;
    spy_disk      : in  std_logic;
    spy_flag1     : in  std_logic;
    spy_flag2     : in  std_logic;
    spy_irh       : in  std_logic;
    spy_irl       : in  std_logic;
    spy_irm       : in  std_logic;
    spy_mdh       : in  std_logic;
    spy_mdl       : in  std_logic;
    spy_mh        : in  std_logic;
    spy_ml        : in  std_logic;
    spy_obh       : in  std_logic;
    spy_obh_      : in  std_logic;
    spy_obl       : in  std_logic;
    spy_obl_      : in  std_logic;
    spy_opc       : in  std_logic;
    spy_pc        : in  std_logic;
    spy_scratch   : in  std_logic;
    spy_sth       : in  std_logic;
    spy_stl       : in  std_logic;
    spy_vmah      : in  std_logic;
    spy_vmal      : in  std_logic;
    srun          : in  std_logic;
    ssdone        : in  std_logic;
    stathalt      : in  std_logic;
    vmaok         : in  std_logic;
    waiting       : in  std_logic;
    wmap          : in  std_logic;
    spy_out       : out std_logic_vector(15 downto 0);
    );
end entity;

architecture behavioral of SPY124 is
signal ob_last : std_logic_vector(31 downto 0);
signal spy_mux:std_logic_vector(15 downto 0);
signal disk_state_in:std_logic_vector(4 downto 0);
begin

   /* grab ob from last cycle for spy */
   always @(posedge clk)
     if (reset)
       ob_last <= 0;
     else
       if (/*state_fetch*/state_write)
	 ob_last <= ob;

   assign spy_out = dbread ? spy_mux : 16'b1111111111111111;

   assign spy_mux =
		   spy_irh ? ir[47:32] :
		   spy_irm ? ir[31:16] :
		   spy_irl ? ir[15:0] :
		   spy_obh ? ob_last[31:16] :
		   spy_obl ? ob_last[15:0] :
		   spy_obh_ ? ob[31:16] :
		   spy_obl_ ? ob[15:0] :
		   spy_disk ? { 11'b0, disk_state_in } :
		   spy_bd ? { 4'b0, bd_state_in } :
		   spy_ah ? a[31:16] :
		   spy_al ? a[15:0] :
		   spy_mh ? m[31:16] :
		   spy_ml ? m[15:0] :
		   spy_mdh ? md[31:16] :
		   spy_mdl ? md[15:0] :
		   spy_vmah ? vma[31:16] :
		   spy_vmal ? vma[15:0] :
		   spy_flag2 ?
		   { 2'b0,wmap,destspc,iwrited,imod,pdlwrite,spush,
		     2'b0,ir[48],nop,vmaok,jcond,pcs1,pcs0 } :
		   spy_opc ?
		   { 2'b0,opc } :
		   spy_flag1 ?
		   { waiting, 1'b0, boot, promdisable,
		     stathalt, err, ssdone, srun,
		     1'b0, 1'b0, 1'b0, 1'b0,
		     1'b0, 1'b0, 1'b0, 1'b0 } :
		   spy_pc ?
		   { 2'b0,pc } :
		   spy_scratch ? scratch :
		   16'b1111111111111111;

end architecture;
