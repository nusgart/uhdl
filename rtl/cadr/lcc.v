// LCC
//
// TK CADR LC CONTROL

module LCC(clk, reset, state_fetch, lc0b, needfetch, ifetch, spc1a, sh4, sh3, sintr, lc, lc_byte_mode, spop, srcspcpopreal, spc, lcinc, destlc, irdisp, ir, ext_int, bus_int);

   input clk;
   input reset;

   input state_fetch;

   input [18:0] spc;
   input [25:0] lc;
   input [48:0] ir;
   input bus_int;
   input destlc;
   input ext_int;
   input irdisp;
   input lc_byte_mode;
   input spop;
   input srcspcpopreal;
   output ifetch;
   output lc0b;
   output lcinc;
   output needfetch;
   output sh3;
   output sh4;
   output sintr;
   output spc1a;

   ////////////////////////////////////////////////////////////////////////////////

   reg newlc;
   reg next_instrd;
   reg sintr;
   wire have_wrong_word;
   wire inst_in_2nd_or_4th_quarter;
   wire inst_in_left_half;
   wire last_byte_in_word;
   wire lc_modifies_mrot;
   wire newlc_in;
   wire next_instr;
   wire spcmung;

   ////////////////////////////////////////////////////////////////////////////////

   assign lc0b = lc[0] & lc_byte_mode;
   assign next_instr = spop & (~srcspcpopreal & spc[14]);
   assign newlc_in = have_wrong_word & ~lcinc;
   assign have_wrong_word = newlc | destlc;
   assign last_byte_in_word = ~lc[1] & ~lc0b;
   assign needfetch = have_wrong_word | last_byte_in_word;
   assign ifetch = needfetch & lcinc;
   assign spcmung = spc[14] & ~needfetch;
   assign spc1a = spcmung | spc[1];
   assign lcinc = next_instrd | (irdisp & ir[24]);

   always @(posedge clk)
     if (reset)
       begin
          newlc <= 0;
          sintr <= 0;
          next_instrd <= 0;
       end
     else
       if (state_fetch)
         begin
            newlc <= newlc_in;
            sintr <= (ext_int | bus_int);
            next_instrd <= next_instr;
         end

   assign lc_modifies_mrot = ir[10] & ir[11];
   assign inst_in_left_half = !((lc[1] ^ lc0b) | ~lc_modifies_mrot);
   assign sh4 = ~(inst_in_left_half ^ ~ir[4]);
   assign inst_in_2nd_or_4th_quarter = !(lc[0] | ~lc_modifies_mrot) & lc_byte_mode;
   assign sh3 = ~(~ir[3] ^ inst_in_2nd_or_4th_quarter);

endmodule
