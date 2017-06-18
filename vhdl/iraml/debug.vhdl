-- DEBUG
--
-- TK		CADR	PDP11 DEBUG INSTRUCTION

entity DEBUG is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    spy_in     : in std_logic_vector(15 downto 0);
    iprom      : in std_logic_vector(48 downto 0);
    iram       : in std_logic_vector(48 downto 0);
    idebug     : in std_logic;
    lddbirh    : in std_logic;
    lddbirl    : in std_logic;
    lddbirm    : in std_logic;
    promenable : in std_logic;
    i          :out std_logic_vector(48 downto 0);
    );
end entity;

architecture behavioral of DEBUG is
   reg [47:0]	 spy_ir;
begin

   always @(posedge clk)
     if (reset)
       spy_ir[47:32] <= 16'b0;
     else
       if (lddbirh)
	 spy_ir[47:32] <= spy_in;

   always @(posedge clk)
     if (reset)
       spy_ir[31:16] <= 16'b0;
     else
       if (lddbirm)
	 spy_ir[31:16] <= spy_in;

   always @(posedge clk)
     if (reset)
       spy_ir[15:0] <= 16'b0;
     else
       if (lddbirl)
	 spy_ir[15:0] <= spy_in;

   -- put latched value on I bus when idebug asserted
   assign i =
	     idebug ? {1'b0, spy_ir} :
	     promenable ? iprom :
	     iram;

end architecture;
