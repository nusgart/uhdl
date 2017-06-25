-- VMA
--
-- TK	CADR	VMA REGISTER

entity VMA is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_alu   : in std_logic;
    state_fetch : in std_logic;
    state_write : in std_logic;

    spy_in   : in  std_logic_vector (15 downto 0);
    vmas     : in  std_logic_vector (31 downto 0);
    ldvmah   : in  std_logic;
    ldvmal   : in  std_logic;
    srcvma   : in  std_logic;
    vmaenb   : in  std_logic;
    vma;     : out std_logic_vector (31 downto 0);
    vmadrive : out std_logic;
    );
end entity;

architecture behavioral of VMA is
  signal vma; : std_logic_vector (31 downto 0);

begin

   always @(posedge clk)
     if (reset)
       vma <= 0;
     else
       if (state_alu && vmaenb)
	 vma <= vmas;
       else
	 if (ldvmah)
	   vma[31:16] <= spy_in;
	 else
	   if (ldvmal)
	     vma[15:0] <= spy_in;

   assign vmadrive = srcvma &
		     (state_alu || state_write || state_fetch);

end architecture;
