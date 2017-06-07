module VMA(clk, reset, state_alu, state_write, state_fetch, vmaenb, vmas, spy_in, srcvma, ldvmal, ldvmah, vma, vmadrive);

   input clk, reset, state_alu, state_write, state_fetch, vmaenb ;
   input [31:0] vmas;
   input [15:0] spy_in;
   input srcvma;
   input ldvmal, ldvmah;
   output reg [31:0] vma;;
   output vmadrive;
   
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

   assign vmadrive = srcvma &
		     (state_alu || state_write || state_fetch);

endmodule
