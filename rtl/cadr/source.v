// SOURCE
//
// TK	CADR	SOURCE, DEST, OP DECODE

module SOURCE(ir, iralu, irbyte, destimod0, destimod1, iwrited, idebug, nop, irdisp, irjump, funct, div, mul, srcq, srcopc, srcpdltop, srcpdlpop, srcpdlidx, srcpdlptr, srcspc, srcdc, srcspcpop, srclc, srcmd, srcmap, srcvma, imod, destmem, destvma, destmdr, dest, destm, destintctl, destlc, destspc, destpdlp, destpdlx, destpdl_x, destpdl_p, destpdltop);

   input [48:0] ir;
   input	idebug;
   input	iwrited;
   input	nop;
   output [3:0] funct;
   output	dest;
   output	destimod0;    // ir<25-14> dest oa register <25-0>
   output	destimod1;    // ir<25-14> dest oa register <47-26>
   output	destintctl;   // ir<25-14> dest interrupt control
   output	destlc;	      // ir<25-14> dest lc
   output	destm;
   output	destmdr;	// ir<25-14> dest MD register
   output	destmem;	// ir<25-14> dest VMA or MD
   output	destpdl_p; // ir<25-14> dest pdl (addressed by ptr), push
   output	destpdl_x; // ir<25-14> dest pdl (addressed by index)
   output	destpdlp;  // ir<25-14> dest pdl ptr
   output	destpdltop;   // ir<25-14> dest pdl (addressed by ptr)
   output	destpdlx;     // ir<25-14> dest pdl index
   output	destspc;      // ir<25-14> dest spc data, push
   output	destvma;      // ir<25-14> dest VMA register
   output	div;
   output	imod;		// fuctional destination
   output	iralu;
   output	irbyte;
   output	irdisp;
   output	irjump;
   output	mul;
   output	srcdc;		// ir<30-26> m src = dispatch constant
   output	srclc;		// ir<30-26> m src = lc
   output	srcmap;		// ir<30-26> m src = vm map[md]
   output	srcmd;		// ir<30-26> m src = md
   output	srcopc;		// ir<30-26> m src = vma
   output	srcpdlidx;	// ir<30-26> m src = pdl index
   output	srcpdlpop;   // ir<30-26> m src = PDL buffer, ptr, pop
   output	srcpdlptr;   // ir<30-26> m src = pdl ptr
   output	srcpdltop;   // ir<30-26> m src = PDL buffer, ptr
   output	srcq;
   output	srcspc;		// ir<30-26> m src = spc ptr
   output	srcspcpop;	// ir<30-26> m src = SPC , pop
   output	srcvma;

   ////////////////////////////////////////////////////////////////////////////////

   wire		specalu;

   ////////////////////////////////////////////////////////////////////////////////

   assign {irbyte,irdisp,irjump,iralu} =
					nop ? 4'b0000 :
					({ir[44],ir[43]} == 2'b00) ? 4'b0001 :
					({ir[44],ir[43]} == 2'b01) ? 4'b0010 :
					({ir[44],ir[43]} == 2'b10) ? 4'b0100 :
					4'b1000 ;

   assign funct =
		 nop ? 4'b0000 :
		 ({ir[11],ir[10]} == 2'b00) ? 4'b0001 :
		 ({ir[11],ir[10]} == 2'b01) ? 4'b0010 :
		 ({ir[11],ir[10]} == 2'b10) ? 4'b0100 :
		 4'b1000 ;

   assign specalu  = ir[8] & iralu;

   assign {div,mul} =
		     ~specalu ? 2'b00 :
		     ({ir[4],ir[3]} == 2'b00) ? 2'b01 : 2'b10;

   assign {srcq,srcopc,srcpdltop,srcpdlpop,
	   srcpdlidx,srcpdlptr,srcspc,srcdc} =
					      (~ir[31] | ir[29]) ? 8'b00000000 :
					      ({ir[28],ir[27],ir[26]} == 3'b000) ? 8'b00000001 :
					      ({ir[28],ir[27],ir[26]} == 3'b001) ? 8'b00000010 :
					      ({ir[28],ir[27],ir[26]} == 3'b010) ? 8'b00000100 :
					      ({ir[28],ir[27],ir[26]} == 3'b011) ? 8'b00001000 :
					      ({ir[28],ir[27],ir[26]} == 3'b100) ? 8'b00010000 :
					      ({ir[28],ir[27],ir[26]} == 3'b101) ? 8'b00100000 :
					      ({ir[28],ir[27],ir[26]} == 3'b110) ? 8'b01000000 :
					      8'b10000000;

   assign {srcspcpop,srclc,srcmd,srcmap,srcvma} =
						 (~ir[31] | ~ir[29]) ? 5'b00000 :
						 ({ir[28],ir[27],ir[26]} == 3'b000) ? 5'b00001 :
						 ({ir[28],ir[27],ir[26]} == 3'b001) ? 5'b00010 :
						 ({ir[28],ir[27],ir[26]} == 3'b010) ? 5'b00100 :
						 ({ir[28],ir[27],ir[26]} == 3'b011) ? 5'b01000 :
						 ({ir[28],ir[27],ir[26]} == 3'b100) ? 5'b10000 :
						 5'b00000 ;

   assign imod = destimod0 | destimod1 | iwrited | idebug;

   assign destmem = destm & ir[23];
   assign destvma = destmem & ~ir[22];
   assign destmdr = destmem & ir[22];

   assign dest = iralu | irbyte;  // destination field is valid
   assign destm = dest & ~ir[25]; // functional destination

   assign {destintctl,destlc} =
			       !(destm & ~ir[23] & ~ir[22]) ? 2'b00 :
			       ({ir[21],ir[20],ir[19]} == 3'b001) ? 2'b01 :
			       ({ir[21],ir[20],ir[19]} == 3'b010) ? 2'b10 :
			       2'b00 ;

   assign {destimod1,destimod0,destspc,destpdlp,
	   destpdlx,destpdl_x,destpdl_p,destpdltop} =
						     !(destm & ~ir[23] & ir[22]) ? 8'b00000000 :
						     ({ir[21],ir[20],ir[19]} == 3'b000) ? 8'b00000001 :
						     ({ir[21],ir[20],ir[19]} == 3'b001) ? 8'b00000010 :
						     ({ir[21],ir[20],ir[19]} == 3'b010) ? 8'b00000100 :
						     ({ir[21],ir[20],ir[19]} == 3'b011) ? 8'b00001000 :
						     ({ir[21],ir[20],ir[19]} == 3'b100) ? 8'b00010000 :
						     ({ir[21],ir[20],ir[19]} == 3'b101) ? 8'b00100000 :
						     ({ir[21],ir[20],ir[19]} == 3'b110) ? 8'b01000000 :
						     ({ir[21],ir[20],ir[19]} == 3'b111) ? 8'b10000000 :
						     8'b00000000;

endmodule
