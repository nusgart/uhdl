-- SHIFT0, SHIFT1
--
-- TK	CADR	SHIFTER RIGHT
-- TK	CADR	SHIFTER LEFT

entity SHIFT01 is
  port (
    m  : in  std_logic_vector (31 downto 0);
    s0 : in  std_logic;
    s1 : in  std_logic;
    s2 : in  std_logic;
    s3 : in  std_logic;
    s4 : in  std_logic;
    r  : out std_logic_vector (31 downto 0);
    );
end entity;

architecture behavioral of SHIFT01 is
  signal sa : std_logic_vector (31 downto 0);
begin

   assign sa =
	      {s1,s0} == 2'b00 ? m :
	      {s1,s0} == 2'b01 ? { m[30:0], m[31] } :
	      {s1,s0} == 2'b10 ? { m[29:0], m[31], m[30] } :
	      { m[28:0], m[31], m[30], m[29] };

   assign {r[12],r[8],r[4],r[0]} =
				  {s4,s3,s2} == 3'b000 ? { sa[12],sa[8], sa[4], sa[0] } :
				  {s4,s3,s2} == 3'b001 ? { sa[8], sa[4], sa[0], sa[28] } :
				  {s4,s3,s2} == 3'b010 ? { sa[4], sa[0], sa[28],sa[24] } :
				  {s4,s3,s2} == 3'b011 ? { sa[0], sa[28],sa[24],sa[20] } :
				  {s4,s3,s2} == 3'b100 ? { sa[28],sa[24],sa[20],sa[16] } :
				  {s4,s3,s2} == 3'b101 ? { sa[24],sa[20],sa[16],sa[12] } :
				  {s4,s3,s2} == 3'b110 ? { sa[20],sa[16],sa[12],sa[8] } :
				  { sa[16],sa[12],sa[8], sa[4] };

   assign {r[13],r[9],r[5],r[1]} =
				  {s4,s3,s2} == 3'b000 ? { sa[13],sa[9], sa[5], sa[1] } :
				  {s4,s3,s2} == 3'b001 ? { sa[9], sa[5], sa[1], sa[29] } :
				  {s4,s3,s2} == 3'b010 ? { sa[5], sa[1], sa[29],sa[25] } :
				  {s4,s3,s2} == 3'b011 ? { sa[1], sa[29],sa[25],sa[21] } :
				  {s4,s3,s2} == 3'b100 ? { sa[29],sa[25],sa[21],sa[17] } :
				  {s4,s3,s2} == 3'b101 ? { sa[25],sa[21],sa[17],sa[13] } :
				  {s4,s3,s2} == 3'b110 ? { sa[21],sa[17],sa[13],sa[9] } :
				  { sa[17],sa[13],sa[9], sa[5] };

   assign {r[14],r[10],r[6],r[2]} =
				   {s4,s3,s2} == 3'b000 ? { sa[14],sa[10],sa[6], sa[2] } :
				   {s4,s3,s2} == 3'b001 ? { sa[10],sa[6], sa[2], sa[30] } :
				   {s4,s3,s2} == 3'b010 ? { sa[6], sa[2], sa[30],sa[26] } :
				   {s4,s3,s2} == 3'b011 ? { sa[2], sa[30],sa[26],sa[22] } :
				   {s4,s3,s2} == 3'b100 ? { sa[30],sa[26],sa[22],sa[18] } :
				   {s4,s3,s2} == 3'b101 ? { sa[26],sa[22],sa[18],sa[14] } :
				   {s4,s3,s2} == 3'b110 ? { sa[22],sa[18],sa[14],sa[10] } :
				   { sa[18],sa[14],sa[10], sa[6] };

   assign {r[15],r[11],r[7],r[3]} =
				   {s4,s3,s2} == 3'b000 ? { sa[15],sa[11],sa[7], sa[3] } :
				   {s4,s3,s2} == 3'b001 ? { sa[11],sa[7], sa[3], sa[31] } :
				   {s4,s3,s2} == 3'b010 ? { sa[7], sa[3], sa[31],sa[27] } :
				   {s4,s3,s2} == 3'b011 ? { sa[3], sa[31],sa[27],sa[23] } :
				   {s4,s3,s2} == 3'b100 ? { sa[31],sa[27],sa[23],sa[19] } :
				   {s4,s3,s2} == 3'b101 ? { sa[27],sa[23],sa[19],sa[15] } :
				   {s4,s3,s2} == 3'b110 ? { sa[23],sa[19],sa[15],sa[11] } :
				   { sa[19],sa[15],sa[11], sa[7] };

   --

   assign {r[28],r[24],r[20],r[16]} =
				     {s4,s3,s2} == 3'b000 ? { sa[28],sa[24],sa[20],sa[16] } :
				     {s4,s3,s2} == 3'b001 ? { sa[24],sa[20],sa[16],sa[12] } :
				     {s4,s3,s2} == 3'b010 ? { sa[20],sa[16],sa[12],sa[8] } :
				     {s4,s3,s2} == 3'b011 ? { sa[16],sa[12],sa[8], sa[4] } :
				     {s4,s3,s2} == 3'b100 ? { sa[12],sa[8],sa[4], sa[0] } :
				     {s4,s3,s2} == 3'b101 ? { sa[8], sa[4],sa[0], sa[28] } :
				     {s4,s3,s2} == 3'b110 ? { sa[4], sa[0],sa[28],sa[24] } :
				     { sa[0],sa[28],sa[24],sa[20] };

   assign {r[29],r[25],r[21],r[17]} =
				     {s4,s3,s2} == 3'b000 ? { sa[29],sa[25],sa[21],sa[17] } :
				     {s4,s3,s2} == 3'b001 ? { sa[25],sa[21],sa[17],sa[13] } :
				     {s4,s3,s2} == 3'b010 ? { sa[21],sa[17],sa[13],sa[9] } :
				     {s4,s3,s2} == 3'b011 ? { sa[17],sa[13],sa[9], sa[5] } :
				     {s4,s3,s2} == 3'b100 ? { sa[13],sa[9],sa[5], sa[1] } :
				     {s4,s3,s2} == 3'b101 ? { sa[9], sa[5],sa[1], sa[29] } :
				     {s4,s3,s2} == 3'b110 ? { sa[5], sa[1],sa[29],sa[25] } :
				     { sa[1],sa[29],sa[25],sa[21] };

   assign {r[30],r[26],r[22],r[18]} =
				     {s4,s3,s2} == 3'b000 ? { sa[30],sa[26],sa[22],sa[18] } :
				     {s4,s3,s2} == 3'b001 ? { sa[26],sa[22],sa[18],sa[14] } :
				     {s4,s3,s2} == 3'b010 ? { sa[22],sa[18],sa[14],sa[10] } :
				     {s4,s3,s2} == 3'b011 ? { sa[18],sa[14],sa[10], sa[6] } :
				     {s4,s3,s2} == 3'b100 ? { sa[14],sa[10],sa[6], sa[2] } :
				     {s4,s3,s2} == 3'b101 ? { sa[10],sa[6], sa[2], sa[30] } :
				     {s4,s3,s2} == 3'b110 ? { sa[6], sa[2], sa[30],sa[26] } :
				     { sa[2], sa[30],sa[26],sa[22] };

   assign {r[31],r[27],r[23],r[19]} =
				     {s4,s3,s2} == 3'b000 ? { sa[31],sa[27],sa[23],sa[19] } :
				     {s4,s3,s2} == 3'b001 ? { sa[27],sa[23],sa[19],sa[15] } :
				     {s4,s3,s2} == 3'b010 ? { sa[23],sa[19],sa[15],sa[11] } :
				     {s4,s3,s2} == 3'b011 ? { sa[19],sa[15],sa[11],sa[7] } :
				     {s4,s3,s2} == 3'b100 ? { sa[15],sa[11],sa[7], sa[3] } :
				     {s4,s3,s2} == 3'b101 ? { sa[11],sa[7], sa[3], sa[31] } :
				     {s4,s3,s2} == 3'b110 ? { sa[7], sa[3], sa[31],sa[27] } :
				     { sa[3], sa[31],sa[27],sa[23] };

end architecture;
