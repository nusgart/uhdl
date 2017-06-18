-- SPY0
--
-- TK	CADR	PDP11 EXAMINE CONTROL

entity SPY0 is
  port (
    eadr        : in  std_logic_vector(4 downto 0);
    dbread      : in  std_logic;
    dbwrite     : in  std_logic;
    ldclk       : out std_logic;
    lddbirh     : out std_logic;
    lddbirl     : out std_logic;
    lddbirm     : out std_logic;
    ldmdh       : out std_logic;
    ldmdl       : out std_logic;
    ldmode      : out std_logic;
    ldopc       : out std_logic;
    ldscratch1  : out std_logic;
    ldscratch2  : out std_logic;
    ldvmah      : out std_logic;
    ldvmal      : out std_logic;
    spy_ah      : out std_logic;
    spy_al      : out std_logic;
    spy_bd      : out std_logic;
    spy_disk    : out std_logic;
    spy_flag1   : out std_logic;
    spy_flag2   : out std_logic;
    spy_irh     : out std_logic;
    spy_irl     : out std_logic;
    spy_irm     : out std_logic;
    spy_mdh     : out std_logic;
    spy_mdl     : out std_logic;
    spy_mh      : out std_logic;
    spy_ml      : out std_logic;
    spy_obh     : out std_logic;
    spy_obh_    : out std_logic;
    spy_obl     : out std_logic;
    spy_obl_    : out std_logic;
    spy_opc     : out std_logic;
    spy_pc      : out std_logic;
    spy_scratch : out std_logic;
    spy_sth     : out std_logic;
    spy_stl     : out std_logic;
    spy_vmah    : out std_logic;
    spy_vmal    : out std_logic;
    );
end entity;

architecture behavioral of SPY0 is
begin

`ifdef old_spy
   /* read registers */
   assign {spy_obh, spy_obl, spy_pc, spy_opc,
	   spy_scratch, spy_irh, spy_irm, spy_irl} =
						    (eadr[3] | ~dbread) ? 8'b0000000 :
						    ({eadr[2],eadr[1],eadr[0]} == 3'b000) ? 8'b00000001 :
						    ({eadr[2],eadr[1],eadr[0]} == 3'b001) ? 8'b00000010 :
						    ({eadr[2],eadr[1],eadr[0]} == 3'b010) ? 8'b00000100 :
						    ({eadr[2],eadr[1],eadr[0]} == 3'b011) ? 8'b00001000 :
						    ({eadr[2],eadr[1],eadr[0]} == 3'b100) ? 8'b00010000 :
						    ({eadr[2],eadr[1],eadr[0]} == 3'b101) ? 8'b00100000 :
						    ({eadr[2],eadr[1],eadr[0]} == 3'b110) ? 8'b01000000 :
						    ({eadr[2],eadr[1],eadr[0]} == 3'b111) ? 8'b10000000 :
						    8'b00000000;

   /* read registers */
   assign {spy_sth, spy_stl, spy_ah, spy_al,
	   spy_mh, spy_ml, spy_flag2, spy_flag1} =
						  (~eadr[3] | ~dbread) ? 8'b00000000 :
						  ({eadr[2],eadr[1],eadr[0]} == 3'b000) ? 8'b00000001 :
						  ({eadr[2],eadr[1],eadr[0]} == 3'b001) ? 8'b00000010 :
						  ({eadr[2],eadr[1],eadr[0]} == 3'b010) ? 8'b00000100 :
						  ({eadr[2],eadr[1],eadr[0]} == 3'b011) ? 8'b00001000 :
						  ({eadr[2],eadr[1],eadr[0]} == 3'b100) ? 8'b00010000 :
						  ({eadr[2],eadr[1],eadr[0]} == 3'b101) ? 8'b00100000 :
						  ({eadr[2],eadr[1],eadr[0]} == 3'b110) ? 8'b01000000 :
						  ({eadr[2],eadr[1],eadr[0]} == 3'b111) ? 8'b10000000 :
						  8'b00000000;

   /* load registers */
   assign {ldscratch2, ldscratch1, ldmode, ldopc, ldclk, lddbirh, lddbirm, lddbirl} =
										     (~dbwrite) ? 8'b00000000 :
										     ({eadr[2],eadr[1],eadr[0]} == 3'b000) ? 8'b00000001 :
										     ({eadr[2],eadr[1],eadr[0]} == 3'b001) ? 8'b00000010 :
										     ({eadr[2],eadr[1],eadr[0]} == 3'b010) ? 8'b00000100 :
										     ({eadr[2],eadr[1],eadr[0]} == 3'b011) ? 8'b00001000 :
										     ({eadr[2],eadr[1],eadr[0]} == 3'b100) ? 8'b00010000 :
										     ({eadr[2],eadr[1],eadr[0]} == 3'b101) ? 8'b00100000 :
										     ({eadr[2],eadr[1],eadr[0]} == 3'b110) ? 8'b01000000 :
										     ({eadr[2],eadr[1],eadr[0]} == 3'b111) ? 8'b10000000 :
										     8'b00000000;
`else
   /* read registers */
   assign {spy_obh, spy_obl, spy_pc, spy_opc,
	   spy_scratch, spy_irh, spy_irm, spy_irl} =
						    ({dbread, eadr} == 6'b10_0000) ? 8'b00000001 :
						    ({dbread, eadr} == 6'b10_0001) ? 8'b00000010 :
						    ({dbread, eadr} == 6'b10_0010) ? 8'b00000100 :
						    ({dbread, eadr} == 6'b10_0011) ? 8'b00001000 :
						    ({dbread, eadr} == 6'b10_0100) ? 8'b00010000 :
						    ({dbread, eadr} == 6'b10_0101) ? 8'b00100000 :
						    ({dbread, eadr} == 6'b10_0110) ? 8'b01000000 :
						    ({dbread, eadr} == 6'b10_0111) ? 8'b10000000 :
						    8'b00000000;

   /* read registers */
   assign {spy_sth, spy_stl, spy_ah, spy_al,
	   spy_mh, spy_ml, spy_flag2, spy_flag1} =
						  ({dbread, eadr} == 6'b10_1000) ? 8'b00000001 :
						  ({dbread, eadr} == 6'b10_1001) ? 8'b00000010 :
						  ({dbread, eadr} == 6'b10_1010) ? 8'b00000100 :
						  ({dbread, eadr} == 6'b10_1011) ? 8'b00001000 :
						  ({dbread, eadr} == 6'b10_1100) ? 8'b00010000 :
						  ({dbread, eadr} == 6'b10_1101) ? 8'b00100000 :
						  ({dbread, eadr} == 6'b10_1110) ? 8'b01000000 :
						  ({dbread, eadr} == 6'b10_1111) ? 8'b10000000 :
						  8'b00000000;

   /* read registers */
   assign {spy_bd, spy_disk, spy_obh_, spy_obl_, spy_vmah, spy_vmal, spy_mdh, spy_mdl} =
											({dbread, eadr} == 6'b11_0000) ? 8'b00000001 :
											({dbread, eadr} == 6'b11_0001) ? 8'b00000010 :
											({dbread, eadr} == 6'b11_0010) ? 8'b00000100 :
											({dbread, eadr} == 6'b11_0011) ? 8'b00001000 :
											({dbread, eadr} == 6'b11_0100) ? 8'b00010000 :
											({dbread, eadr} == 6'b11_0101) ? 8'b00100000 :
											({dbread, eadr} == 6'b11_0110) ? 8'b01000000 :
											({dbread, eadr} == 6'b11_0111) ? 8'b10000000 :
											8'b00000000;

   /* load registers */
   assign {ldscratch2, ldscratch1, ldmode,
	   ldopc, ldclk, lddbirh, lddbirm, lddbirl} =
						     ({dbwrite, eadr} == 6'b10_0000) ? 8'b00000001 :
						     ({dbwrite, eadr} == 6'b10_0001) ? 8'b00000010 :
						     ({dbwrite, eadr} == 6'b10_0010) ? 8'b00000100 :
						     ({dbwrite, eadr} == 6'b10_0011) ? 8'b00001000 :
						     ({dbwrite, eadr} == 6'b10_0100) ? 8'b00010000 :
						     ({dbwrite, eadr} == 6'b10_0101) ? 8'b00100000 :
						     ({dbwrite, eadr} == 6'b10_0110) ? 8'b01000000 :
						     ({dbwrite, eadr} == 6'b10_0111) ? 8'b10000000 :
						     8'b00000000;

   assign {ldvmah, ldvmal, ldmdh, ldmdl} =
					  ({dbwrite, eadr} == 6'b10_1000) ? 4'b0001 :
					  ({dbwrite, eadr} == 6'b10_1001) ? 4'b0010 :
					  ({dbwrite, eadr} == 6'b10_1010) ? 4'b0100 :
					  ({dbwrite, eadr} == 6'b10_1011) ? 4'b1000 :
					  4'b0000;
`endif

end architecture;
