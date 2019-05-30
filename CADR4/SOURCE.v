// SOURCE --- SOURCE, DEST, OP DECODE
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-16 05:44:55 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module SOURCE(/*AUTOARG*/
   // Outputs
   funct, dest, div, imod, iralu, irbyte, irdisp, irjump, mul, destlc,
   destintctl, destpdltop, destpdl_p, destpdl_x, destpdlx, destpdlp,
   destspc, destimod0, destimod1, destvma, destmdr, destmem, destm,
   srcdc, srcspc, srcpdlptr, srcpdlidx, srcpdltop, srcopc, srcq,
   srcvma, srcmap, srcmd, srclc, srcspcpop, srcpdlpop,
   // Inputs
   ir, idebug, iwrited, nop
   );

   input [48:0] ir;
   input wire idebug;
   input wire iwrited;
   input wire nop;
   output [3:0] funct;
   output wire dest;


   output wire div;
   output wire imod;
   output wire iralu;
   output wire irbyte;
   output wire irdisp;
   output wire irjump;
   output wire mul;

   // Destination (see "(cadr) Destinations" for details):
   output wire destlc;               // Location Counter.
   output wire destintctl;           // Interrupt Control.
   output wire destpdltop;           // PDL (addressed by Pointer).
   output wire destpdl_p;            // PDL (addressed by Pointer), push.
   output wire destpdl_x;            // PDL (addressed by Index).
   output wire destpdlx;             // PDL Index.
   output wire destpdlp;             // PDL Pointer.
   output wire destspc;              // SPC data, push.
   output wire destimod0;            // "OA register", bits <25-0>.
   output wire destimod1;            // "OA register", bits <47-26>.
   output wire destvma;              // VMA register (memory address).
   output wire destmdr;              // MD register (memory data).
   output wire destmem; ///---!!! DESTMEM: What is this in the CADR document?
   output wire destm;   ///---!!! DESTM: What is this in the CADR documen?t

   // M "functional" source (see "(cadr) Destinations" for details):
   output wire srcdc;             // Dispatch constant.
   output wire srcspc;            // SPC pointer <28-24>, SPC data <18-0>.
   output wire srcpdlptr;         // PDL pointer <9-0>.
   output wire srcpdlidx;         // PDL index <9-0>.
   output wire srcpdltop;         // PDL Buffer (addressed by Index).
   output wire srcopc;            // OPC registers <13-0>.
   output wire srcq;              // Q register.
   output wire srcvma;            // VMA register (memory address).
   output wire srcmap;            // MAP[MD].
   output wire srcmd;             // MD register (memory data).
   output wire srclc;             // LC (location counter).
   output wire srcspcpop;         // SPC pointer and data, pop.
   output wire srcpdlpop;         // PDL buffer, addressed by Pointer, pop.

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

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
