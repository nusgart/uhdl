// SOURCE --- SOURCE, DEST, OP DECODE

module SOURCE(ir, iralu, irbyte, destimod0, destimod1, iwrited, idebug, nop, irdisp, irjump, funct, div, mul, srcq, srcopc, srcpdltop, srcpdlpop, srcpdlidx, srcpdlptr, srcspc, srcdc, srcspcpop, srclc, srcmd, srcmap, srcvma, imod, destmem, destvma, destmdr, dest, destm, destintctl, destlc, destspc, destpdlp, destpdlx, destpdl_x, destpdl_p, destpdltop);

   input [48:0] ir;
   input idebug;
   input iwrited;
   input nop;
   output [3:0] funct;
   output dest;


   output div;
   output imod;
   output iralu;
   output irbyte;
   output irdisp;
   output irjump;
   output mul;

   // Destination (see "(cadr) Destinations" for details):
   output destlc;               // Location Counter.
   output destintctl;           // Interrupt Control.
   output destpdltop;           // PDL (addressed by Pointer).
   output destpdl_p;            // PDL (addressed by Pointer), push.
   output destpdl_x;            // PDL (addressed by Index).
   output destpdlx;             // PDL Index.
   output destpdlp;             // PDL Pointer.
   output destspc;              // SPC data, push.
   output destimod0;            // "OA register", bits <25-0>.
   output destimod1;            // "OA register", bits <47-26>.
   output destvma;              // VMA register (memory address).
   output destmdr;              // MD register (memory data).
   output destmem; ///---!!! DESTMEM: What is this in the CADR document?
   output destm;   ///---!!! DESTM: What is this in the CADR documen?t

   // M "functional" source (see "(cadr) Destinations" for details):
   output srcdc;             // Dispatch constant.
   output srcspc;            // SPC pointer <28-24>, SPC data <18-0>.
   output srcpdlptr;         // PDL pointer <9-0>.
   output srcpdlidx;         // PDL index <9-0>.
   output srcpdltop;         // PDL Buffer (addressed by Index).
   output srcopc;            // OPC registers <13-0>.
   output srcq;              // Q register.
   output srcvma;            // VMA register (memory address).
   output srcmap;            // MAP[MD].
   output srcmd;             // MD register (memory data).
   output srclc;             // LC (location counter).
   output srcspcpop;         // SPC pointer and data, pop.
   output srcpdlpop;         // PDL buffer, addressed by Pointer, pop.

   ////////////////////////////////////////////////////////////////////////////////

   wire specalu;

   ////////////////////////////////////////////////////////////////////////////////

   assign {irbyte, irdisp, irjump, iralu}
     = nop ? 4'b0000 :
       ({ir[44], ir[43]} == 2'b00) ? 4'b0001 :
       ({ir[44], ir[43]} == 2'b01) ? 4'b0010 :
       ({ir[44], ir[43]} == 2'b10) ? 4'b0100 :
       4'b1000 ;
   assign funct
     = nop ? 4'b0000 :
       ({ir[11], ir[10]} == 2'b00) ? 4'b0001 :
       ({ir[11], ir[10]} == 2'b01) ? 4'b0010 :
       ({ir[11], ir[10]} == 2'b10) ? 4'b0100 :
       4'b1000 ;
   assign specalu = ir[8] & iralu;
   assign {div, mul}
     = ~specalu ? 2'b00 :
       ({ir[4], ir[3]} == 2'b00) ? 2'b01 :
       2'b10;
   assign {srcq, srcopc, srcpdltop, srcpdlpop, srcpdlidx, srcpdlptr, srcspc, srcdc}
     = (~ir[31] | ir[29]) ? 8'b00000000 :
       ({ir[28], ir[27], ir[26]} == 3'b000) ? 8'b00000001 :
       ({ir[28], ir[27], ir[26]} == 3'b001) ? 8'b00000010 :
       ({ir[28], ir[27], ir[26]} == 3'b010) ? 8'b00000100 :
       ({ir[28], ir[27], ir[26]} == 3'b011) ? 8'b00001000 :
       ({ir[28], ir[27], ir[26]} == 3'b100) ? 8'b00010000 :
       ({ir[28], ir[27], ir[26]} == 3'b101) ? 8'b00100000 :
       ({ir[28], ir[27], ir[26]} == 3'b110) ? 8'b01000000 :
       8'b10000000;
   assign {srcspcpop, srclc, srcmd, srcmap, srcvma}
     = (~ir[31] | ~ir[29]) ? 5'b00000 :
       ({ir[28], ir[27], ir[26]} == 3'b000) ? 5'b00001 :
       ({ir[28], ir[27], ir[26]} == 3'b001) ? 5'b00010 :
       ({ir[28], ir[27], ir[26]} == 3'b010) ? 5'b00100 :
       ({ir[28], ir[27], ir[26]} == 3'b011) ? 5'b01000 :
       ({ir[28], ir[27], ir[26]} == 3'b100) ? 5'b10000 :
       5'b00000 ;
   assign imod = destimod0 | destimod1 | iwrited | idebug;
   assign destmem = destm & ir[23];
   assign destvma = destmem & ~ir[22];
   assign destmdr = destmem & ir[22];
   assign dest = iralu | irbyte;
   assign destm = dest & ~ir[25];
   assign {destintctl, destlc}
     = !(destm & ~ir[23] & ~ir[22]) ? 2'b00 :
       ({ir[21], ir[20], ir[19]} == 3'b001) ? 2'b01 :
       ({ir[21], ir[20], ir[19]} == 3'b010) ? 2'b10 :
       2'b00 ;
   assign {destimod1, destimod0, destspc, destpdlp, destpdlx, destpdl_x, destpdl_p, destpdltop}
     = !(destm & ~ir[23] & ir[22]) ? 8'b00000000 :
       ({ir[21], ir[20], ir[19]} == 3'b000) ? 8'b00000001 :
       ({ir[21], ir[20], ir[19]} == 3'b001) ? 8'b00000010 :
       ({ir[21], ir[20], ir[19]} == 3'b010) ? 8'b00000100 :
       ({ir[21], ir[20], ir[19]} == 3'b011) ? 8'b00001000 :
       ({ir[21], ir[20], ir[19]} == 3'b100) ? 8'b00010000 :
       ({ir[21], ir[20], ir[19]} == 3'b101) ? 8'b00100000 :
       ({ir[21], ir[20], ir[19]} == 3'b110) ? 8'b01000000 :
       ({ir[21], ir[20], ir[19]} == 3'b111) ? 8'b10000000 :
       8'b00000000;

endmodule
