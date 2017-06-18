-- NPC
--
-- TK		CADR	NPC,IPC,PC

entity NPC is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    dpc   : in  std_logic_vector(13 downto 0);
    spc   : in  std_logic_vector(18 downto 0);
    ir    : in  std_logic_vector(48 downto 0);
    pcs0  : in  std_logic;
    pcs1  : in  std_logic;
    spc1a : in  std_logic;
    trap  : in  std_logic;
    ipc   : out std_logic_vector(13 downto 0);
    pc    : out std_logic_vector(13 downto 0);
    );
end entity;

architecture behavioral of NPC is
  signal pc : std_logic_vector(13 downto 0);
  signal 	 npc:std_logic_vector(13 downto 0);
begin

   assign npc =
		trap ? 14'b0 :
		{pcs1,pcs0} == 2'b00 ? { spc[13:2], spc1a, spc[0] } :
		{pcs1,pcs0} == 2'b01 ? { ir[25:12] } :
		{pcs1,pcs0} == 2'b10 ? dpc :
		/*2'b11*/ ipc;

   always @(posedge clk)
     if (reset)
       pc <= 0;
     else
       if (state_fetch)
	 pc <= npc;

   assign ipc = pc + 14'd1;

end architecture;
