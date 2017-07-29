// VMA
//
// TK CADR VMA REGISTER

module VMA(clk, reset, state_alu, state_write, state_fetch, vmaenb, vmas, spy_in, srcvma, ldvmal, ldvmah, vma, vmadrive);

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
   output [31:0] vma;;
   output vmadrive;

   ////////////////////////////////////////////////////////////////////////////////

   reg [31:0] vma;;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       vma <= 0;
     else
       if (state_alu && vmaenb)
         vma <= vmas;
       else
         if (ldvmah)
           vma[31:16] <= spy_in;
         else
           if (ldvmal)
             vma[15:0] <= spy_in;

   assign vmadrive = srcvma & (state_alu || state_write || state_fetch);

endmodule
