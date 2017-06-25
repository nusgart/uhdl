-- SPC
--
-- TK	CADR	SPC MEMORY AND POINTER

entity SPC is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch : in std_logic;

    spcw   : in  std_logic_vector (18 downto 0);
    spcnt  : in  std_logic;
    spush  : in  std_logic;
    srp    : in  std_logic;
    swp    : in  std_logic;
    spco   : out std_logic_vector (18 downto 0);
    spcptr : out std_logic_vector (4 downto 0);
    );
end entity;

architecture behavioral of SPC is
  signal spcptr    : std_logic_vector (4 downto 0);
  signal spcadr    : std_logic_vector (4 downto 0);
  signal spcptr_p1 : std_logic_vector (4 downto 0);
  signal spcadr    : std_logic_vector (4 downto 0);
begin

   -- orig rtl:
   --  pop  = read[p], decr p
   --  push = incr p, write[p]

   -- spcpop = read[spcptr] (state_write), spcptr-- (state_fetch)
   -- spcpush = write[spcptr+1] (state_write), spcptr++ (state_fetch)

   assign spcptr_p1 = spcptr + 5'b00001;

`define old_spc
`ifdef old_spc
   assign spcadr = (spcnt && spush) ? spcptr_p1 : spcptr;
`else
   always @(posedge clk)
     if (reset)
       spcadr <= 0;
     else
       --       if (state_read)
       spcadr <= (spcnt && spush) ? spcptr_p1 : spcptr;
`endif

   part_32x19dpram i_SPC(
			 .reset(reset),

			 .clk_a(clk),
			 .address_a(spcptr),
			 .data_a(19'b0),
			 .q_a(spco),
			 .wren_a(1'b0),
			 .rden_a(srp && ~swp),

			 .clk_b(clk),
			 .address_b(spcadr),
			 .data_b(spcw),
			 .q_b(),
			 .wren_b(swp),
			 .rden_b(1'b0)
			 );

   always @(posedge clk)
     if (reset)
       spcptr <= 0;
     else
       if (state_fetch)
	 begin
	    if (spcnt)
	      begin
		 if (spush)
		   spcptr <= spcptr + 5'd1;
		 else
		   spcptr <= spcptr - 5'd1;
	      end
	 end

end architecture;
