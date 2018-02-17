// QCTL --- Q REGISTER CONTROL

`include "defines.vh"

module QCTL(state_alu, state_write, state_mmu, state_fetch, ir, iralu, srcq, qs0, qs1, qdrive);

   input state_alu;
   input state_write;
   input state_mmu;
   input state_fetch;

   input [48:0] ir;
   input iralu;
   input srcq;

   output qs0;
   output qs1;
   output qdrive;

   ////////////////////////////////////////////////////////////////////////////////

   assign qs1 = ir[1] & iralu;
   assign qs0 = ir[0] & iralu;

   assign qdrive = srcq & (state_alu || state_write || state_mmu || state_fetch);

endmodule
