-- SMCTL
--
-- TK	CONS	SHIFT/MASK CONTROL

entity SMCTL is
  port (
    ir     : in  std_logic_vector(48 downto 0);
    irbyte : in  std_logic;
    sh3    : in  std_logic;
    sh4    : in  std_logic;
    mskl   : out std_logic_vector(4 downto 0);
    mskr   : out std_logic_vector(4 downto 0);
    s0     : out std_logic;
    s1     : out std_logic;
    s2     : out std_logic;
    s3     : out std_logic;
    s4     : out std_logic;
    );
end entity;

architecture behavioral of SMCTL is
   signal mr:std_logic;
   signal sr:std_logic;
begin

   assign mr = ~irbyte | ir[13];
   assign sr = ~irbyte | ir[12];

   assign mskr[4] = mr & sh4;
   assign mskr[3] = mr & sh3;
   assign mskr[2] = mr & ir[2];
   assign mskr[1] = mr & ir[1];
   assign mskr[0] = mr & ir[0];

   assign s4 = sr & sh4;
   assign s3 = sr & sh3;
   assign s2 = sr & ir[2];
   assign s1 = sr & ir[1];
   assign s0 = sr & ir[0];

   assign mskl = mskr + ir[9:5];

end architecture;
