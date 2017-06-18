-- VCTL2
--
-- TK	CADR	VMA/MD CONTROL

entity VCTL2 is
  port (
    state_decode : in std_logic;
    state_mmu    : in std_logic;
    state_read   : in std_logic;
    state_write  : in std_logic;

    vma        : in  std_logic_vector(31 downto 0);
    ir         : in  std_logic_vector(48 downto 0);
    destmdr    : in  std_logic;
    destmem    : in  std_logic;
    destvma    : in  std_logic;
    dispwr     : in  std_logic;
    dmapbenb   : in  std_logic;
    ifetch     : in  std_logic;
    irdisp     : in  std_logic;
    loadmd     : in  std_logic;
    memprepare : in  std_logic;
    memstart   : in  std_logic;
    nopa       : in  std_logic;
    srcmap     : in  std_logic;
    srcmd      : in  std_logic;
    wrcyc      : in  std_logic;
    mdsel      : out std_logic;
    memdrive   : out std_logic;
    memrd      : out std_logic;
    memwr      : out std_logic;
    vm0rp      : out std_logic;
    vm0wp      : out std_logic;
    vm1rp      : out std_logic;
    vm1wp      : out std_logic;
    vmaenb     : out std_logic;
    vmasel     : out std_logic;
    wmap       : out std_logic;
    );
end entity;

architecture behavioral of VCTL2 is
   signal early_vm0_rd:std_logic;
   signal early_vm1_rd:std_logic;
   signal normal_vm0_rd:std_logic;
   signal normal_vm1_rd:std_logic;
   signal use_md:std_logic;
begin

   /*
    * for memory cycle, we run mmu state and map vma during state_write & state_mmu
    * for dispatch,     we don't run mmy state and map md early
    *                   so dispatch ram has a chance to read and register during write state
    *
    * dispatch ram output has to be valid during fetch cycle to get npc correct
    */

   assign mapwr0 = wmap & vma[26];
   assign mapwr1 = wmap & vma[25];

   -- for dispatch, no alu needed, so read early and skip mmu state
   -- for byte,     no alu needed, so read early
   -- for alu,      no alu needed, so read early
   assign early_vm0_rd  = (irdisp && dmapbenb) | srcmap;
   assign early_vm1_rd  = (irdisp && dmapbenb) | srcmap;

   assign normal_vm0_rd = wmap;
   assign normal_vm1_rd = 1'b0;

   assign vm0rp = (state_decode && early_vm0_rd) |
		  (state_write  && normal_vm0_rd) |
		  (state_write  && memprepare);

   assign vm1rp = (state_read && early_vm1_rd) |
		  (state_mmu  && normal_vm1_rd) |
		  (state_mmu  && memstart);

   assign vm0wp = mapwr0 & state_write;
   assign vm1wp = mapwr1 & state_mmu;

   assign vmaenb = destvma | ifetch;
   assign vmasel = ~ifetch;

   -- external?
   assign lm_drive_enb = 0;

   assign memdrive = wrcyc & lm_drive_enb;

   assign mdsel = destmdr & ~loadmd/*& ~state_write*/;

   assign use_md  = srcmd & ~nopa;

   assign {wmap,memwr,memrd} =
			      ~destmem ? 3'b000 :
			      (ir[20:19] == 2'b01) ? 3'b001 :
			      (ir[20:19] == 2'b10) ? 3'b010 :
			      (ir[20:19] == 2'b11) ? 3'b100 :
			      3'b000 ;

end architecture;
