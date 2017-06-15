// TK	CADR	PDP11 EXAMINE CONTROL

module SPY0(spy_obh, spy_obl, spy_pc, spy_opc, spy_scratch, spy_irh, spy_irm, spy_irl, spy_stl, spy_ah, spy_al, spy_mh, spy_ml, spy_flag2, spy_flag1, ldscratch2, ldscratch1, ldmode, ldopc, ldclk, lddbirh, lddbirm, lddbirl, eadr, dbread, dbwrite, spy_mdl, spy_vmal, spy_vmah, spy_sth, spy_mdh, spy_disk, spy_bd, ldmdh, ldmdl, ldvmah, ldvmal, spy_obl_, spy_obh_);

   input [4:0] eadr;
   input       dbread;
   input       dbwrite;
   output      ldclk;
   output      lddbirh;
   output      lddbirl;
   output      lddbirm;
   output      ldmdh;
   output      ldmdl;
   output      ldmode;
   output      ldopc;
   output      ldscratch1;
   output      ldscratch2;
   output      ldvmah;
   output      ldvmal;
   output      spy_ah;
   output      spy_al;
   output      spy_bd;
   output      spy_disk;
   output      spy_flag1;
   output      spy_flag2;
   output      spy_irh;
   output      spy_irl;
   output      spy_irm;
   output      spy_mdh;
   output      spy_mdl;
   output      spy_mh;
   output      spy_ml;
   output      spy_obh;
   output      spy_obh_;
   output      spy_obl;
   output      spy_obl_;
   output      spy_opc;
   output      spy_pc;
   output      spy_scratch;
   output      spy_sth;
   output      spy_stl;
   output      spy_vmah;
   output      spy_vmal;

   ////////////////////////////////////////////////////////////////////////////////

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

endmodule
