module MMEM(
clk, reset, mrp, mwp, madr, l, b, mmem
    );

   input reset;
   input clk;
   input 	mrp;
   input [4:0] madr;
   input [31:0] l;
   input 	b;
   output [31:0] mmem;
input mwp;

   part_32x32dpram i_MMEM(
			  .reset(reset),

			  .clk_a(clk),
			  .address_a(madr),
			  .data_a(32'b0),
			  .q_a(mmem),
			  .wren_a(1'b0),
			  .rden_a(mrp),

			  .clk_b(clk),
			  .address_b(madr),
			  .data_b(l),
			  .q_b(),
			  .wren_b(mwp),
			  .rden_b(1'b0)
			);
endmodule