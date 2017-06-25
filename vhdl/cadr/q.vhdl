-- Q
--
-- TK	CADR	Q REGISTER

entity Q is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_mmu   : in std_logic;
    state_write : in std_logic;

    alu    : in  std_logic_vector (32 downto 0);
    ir     : in  std_logic_vector (48 downto 0);
    iralu  : in  std_logic;
    srcq   : in  std_logic;
    q      : out std_logic_vector (31 downto 0);
    qdrive : out std_logic;
    );
end entity;

architecture behavioral of Q is
  signal q   : std_logic_vector (31 downto 0);
  signal qs0 : std_logic;
  signal qs1 : std_logic;
begin

   assign qs1 = ir[1] & iralu;
   assign qs0 = ir[0] & iralu;

   assign qdrive = srcq &
		   (state_alu || state_write || state_mmu || state_fetch);

   always @(posedge clk)
     if (reset)
       q <= 0;
     else
       if (state_fetch && (qs1 | qs0))
	 begin
	    case ( {qs1,qs0} )
	      2'b00: q <= q;
	      2'b01: q <= { q[30:0], ~alu[31] };
	      2'b10: q <= { alu[0], q[31:1] };
	      2'b11: q <= alu[31:0];
	    endcase
	 end

end architecture;
