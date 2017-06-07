module VMEM0( clk, reset, vmem0_adr, mapi, vmap, vm0rp, vma, use_map, srcmap, memstart, vm0wp);
   
   input clk,reset;
   input vm0wp;
   output [10:0] 	vmem0_adr;
   input [23:8] 	mapi;   
   output [4:0] 	vmap;
   input 	vm0rp;
   input [31:0] 	vma;   
   output 	use_map;
   input 	srcmap,memstart;
   
   assign vmem0_adr = mapi[23:13];

   part_2kx5dpram i_VMEM0(
			  .reset(reset),

			  .clk_a(clk),
			  .address_a(vmem0_adr),
			  .q_a(vmap),
			  .data_a(5'b0),
			  .wren_a(1'b0),
			  .rden_a(vm0rp && ~vm0wp),

			  .clk_b(clk),
			  .address_b(vmem0_adr),
			  .q_b(),
			  .data_b(vma[31:27]),
			  .wren_b(vm0wp),
			  .rden_b(1'b0)
			  );

   assign use_map = srcmap | memstart;

endmodule
