// TRAP --- PARITY ERROR TRAP

`include "defines.vh"

module TRAP(trap, boot_trap);

   input boot_trap;
   output trap;

   ////////////////////////////////////////////////////////////////////////////////

   assign trap = boot_trap;

endmodule
