-- SPCW
--
-- TK	CADR	SPC WRITE DATA SEL

entity SPCW is
  port (
    ipc     : in  std_logic_vector (13 downto 0);
    wpc     : in  std_logic_vector (13 downto 0);
    l       : in  std_logic_vector (31 downto 0);
    destspc : in  std_logic;
    n       : in  std_logic;
    spcw    : out std_logic_vector (18 downto 0);
    );
end entity;

architecture behavioral of SPCW is
  signal reta : std_logic_vector (13 downto 0);
begin

   assign spcw = destspc ? l[18:0] : { 5'b0, reta };

   --   always @(posedge clk)
   --     if (reset)
   --       reta <= 0;
   --     else
   --       /* n is not valid until after decode */
   --       if (state_alu)
   --	 reta <= n ? wpc : ipc;

   assign reta = n ? wpc : ipc;

end architecture;
