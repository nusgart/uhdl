-- IRAM
--
-- TK		CADR	RAM 0K-4K, 0-11
-- TK		CADR	RAM 4K-8K, 0-11
-- TK		CADR	RAM 8K-12K, 0-11
-- TK		CADR	RAM 12K-16K, 0-11
-- TK		CADR	RAM 0K-4K, 12-24
-- TK		CADR	RAM 4K-8K 12-23
-- TK		CADR	RAM 8K-12K, 12-23
-- TK		CADR	RAM 12K-16K, 12-23
-- TK		CADR	RAM 0K-4K, 24-35
-- TK		CADR	RAM 4K-8K, 24-35
-- TK		CADR	RAM 8K-12K, 24-35
-- TK		CADR	RAM 12K-16K, 24-35
-- TK		CADR	RAM 0K-4K, 36-48
-- TK		CADR	RAM 4K-8K, 36-48
-- TK		CADR	RAM 8K-12K, 36-48
-- TK		CADR	RAM 12K-16K, 36-48

entity IRAM is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    state_fetch    : in std_logic;
    state_mmu      : in std_logic;
    state_prefetch : in std_logic;
    state_write    : in std_logic;

    pc             : in  std_logic_vector(13 downto 0);
    iwr            : in  std_logic_vector(48 downto 0);
    mcr_data_in    : in  std_logic_vector(48 downto 0);
    state          : in  std_logic_vector(5 downto 0);
    iwe            : in  std_logic;
    machrun        : in  std_logic;
    need_mmu_state : in  std_logic;
    promdisabled   : in  std_logic;
    pc_out         : out std_logic_vector(13 downto 0);
    iram           : out std_logic_vector(48 downto 0);
    state_out      : out std_logic_vector(5 downto 0);
    fetch_out      : out std_logic;
    machrun_out    : out std_logic;
    prefetch_out   : out std_logic;
    );
end entity;

architecture behavioral of IRAM is
begin

`define use_ucode_ram
`ifdef use_ucode_ram
   part_16kx49ram i_IRAM(
			 .clk_a(clk),
			 .reset(reset),
			 .address_a(pc),
			 .q_a(iram),
			 .data_a(iwr),
			 .wren_a(iwe),
			 .rden_a(1'b1/*ice*/)
			 );

   assign fetch_out = 0;
   assign prefetch_out = 0;
`else
   -- use top level ram controller
   assign mcr_addr = pc;
   assign iram = mcr_data_in;
   assign mcr_data_out = iwr;
   assign mcr_write = iwe;

   -- for externals
   assign fetch_out = state_fetch && promdisabled;
   assign prefetch_out = ((need_mmu_state ? state_mmu : state_write) || state_prefetch) &&
			 promdisabled;
`endif

   assign pc_out = pc;
   assign state_out = state;
   assign machrun_out = machrun;

end architecture;
