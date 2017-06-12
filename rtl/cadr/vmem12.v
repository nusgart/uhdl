// TK	CADR	VIRTUAL MEMORY MAP STAGE 1

module VMEM12(clk, reset, vmem1_adr, vmap, mapi, vm1rp, vma, vmo, vm1wp);

   input clk;
   input reset;

   input [23:8] mapi;
   input [31:0] vma;
   input [4:0]	vmap;
   input	vm1rp;
   input	vm1wp;
   output [23:0] vmo;
   output [9:0]  vmem1_adr;

   ////////////////////////////////////////////////////////////////////////////////

   assign vmem1_adr = {vmap[4:0], mapi[12:8]};

   part_1kx24dpram i_VMEM1(
			   .reset(reset),

			   .clk_a(clk),
			   .address_a(vmem1_adr),
			   .q_a(vmo),
			   .data_a(24'b0),
			   .wren_a(1'b0),
			   .rden_a(vm1rp && ~vm1wp),

			   .clk_b(clk),
			   .address_b(vmem1_adr),
			   .q_b(),
			   .data_b(vma[23:0]),
			   .wren_b(vm1wp),
			   .rden_b(1'b0)
			   );

endmodule
