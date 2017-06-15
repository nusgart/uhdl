// TRAP
//
// TK	CADR	PARITY ERROR TRAP

module TRAP(trap, boot_trap);

   input boot_trap;
   output trap;

   ////////////////////////////////////////////////////////////////////////////////

   assign trap = boot_trap;

endmodule
