-- MLATCH
--
-- TK		CADR	M MEMORY LATCH

entity MLATCH is
  port (
    spco     : in std_logic_vector(18 downto 0);
    mf       : in std_logic_vector(31 downto 0);
    mmem     : in std_logic_vector(31 downto 0);
    pdl      : in std_logic_vector(31 downto 0);
    spcptr   : in std_logic_vector(4 downto 0);
    mfdrive  : in std_logic;
    mpassm   : in std_logic;
    pdldrive : in std_logic;
    spcdrive : in std_logic;
    m        :out std_logic_vector(31 downto 0);

    );
end entity;

architecture behavioral of MLATCH is
begin

`ifdef debug_with_usim -- Does this belong here?
   -- tell disk controller when each fetch passes to force sync with usim
   always @(posedge clk)
     if (state_fetch)
       busint.disk.fetch = 1;
     else
       busint.disk.fetch = 0;
`endif

   -- mux M
   assign m =
	     /*same as srcm*/mpassm ? mmem :
	     pdldrive ? pdl :
	     spcdrive ? {3'b0, spcptr, 5'b0, spco} :
	     mfdrive ? mf :
	     32'b0;

end architecture;
