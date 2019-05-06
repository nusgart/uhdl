// VMA --- VMA REGISTER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-03 02:44:17 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module VMA(/*AUTOARG*/
   // Outputs
   vma, vmadrive,
   // Inputs
   clk, reset, state_alu, state_fetch, state_write, spy_in, vmas,
   ldvmah, ldvmal, srcvma, vmaenb
   );

   input clk;
   input reset;

   input state_alu;
   input state_fetch;
   input state_write;

   input [15:0] spy_in;
   input [31:0] vmas;
   input ldvmah;
   input ldvmal;
   input srcvma;
   input vmaenb;
   output [31:0] vma;
   output vmadrive;

   ////////////////////////////////////////////////////////////////////////////////

   reg [31:0] vma;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       vma <= 0;
     else if (state_alu && vmaenb)
       vma <= vmas;
     else if (ldvmah)
       vma[31:16] <= spy_in;
     else if (ldvmal)
       vma[15:0] <= spy_in;

   assign vmadrive = srcvma & (state_alu || state_write || state_fetch);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
