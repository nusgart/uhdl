-- OLORD2
--
-- TK		CADR	OVERLORD

entity OLORD2 is
  port (
    clk       : in std_logic;
    ext_reset : in std_logic;

    spy_in    : in  std_logic_vector(15 downto 0);
    errstop   : in  std_logic;
    ext_boot  : in  std_logic;
    ext_halt  : in  std_logic;
    ldmode    : in  std_logic;
    srun      : in  std_logic;
    stat_ovf  : in  std_logic;
    boot      : out std_logic;
    boot_trap : out std_logic;
    err       : out std_logic;
    errhalt   : out std_logic;
    reset     : out std_logic;
    statstop  : out std_logic;
    );
end entity;

architecture behavioral of OLORD2 is
   reg		boot_trap;
   reg		halted;
   reg		statstop;
   signal bus_reset:std_logic;
   signal prog_boot:std_logic;
   signal prog_bus_reset:std_logic;
   signal prog_reset:std_logic;
begin

   always @(posedge clk)
     if (reset)
       begin
	  halted <= 0;
	  statstop <= 0;
       end
     else
       begin
	  halted <= ext_halt;
	  statstop <= stat_ovf;
       end

   assign prog_reset = ldmode & spy_in[6];

   assign reset = ext_reset | prog_reset;

   assign err = halted;

   assign errhalt = errstop & err;

   -- external
   assign prog_bus_reset = 0;

   assign bus_reset  = prog_bus_reset | ext_reset;

   -- external

   assign prog_boot = ldmode & spy_in[7];

   assign boot  = ext_boot | prog_boot;

   always @(posedge clk)
     if (reset)
       boot_trap <= 0;
     else
       if (boot)
	 boot_trap <= 1'b1;
       else
	 if (srun)
	   boot_trap <= 1'b0;

end architecture;
