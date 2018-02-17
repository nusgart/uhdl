// AMEM0, AMEM1 --- A MEMORY (LEFT & RIGHT)
`include "defines.vh"


module AMEM01(clk, reset, l, aadr, arp, awp, amem);

   input clk;
   input reset;

   input [31:0] l;
   input [9:0] aadr;
   input arp;
   input awp;
   output [31:0] amem;

   ////////////////////////////////////////////////////////////////////////////////

   part_1kx32dpram_a i_AMEM(.reset(reset),
                            .clk_a(clk), .address_a(aadr), .data_a(32'b0), .q_a(amem), .wren_a(1'b0), .rden_a(arp),
                            .clk_b(clk), .address_b(aadr), .data_b(l), .q_b(), .wren_b(awp), .rden_b(1'b0));

endmodule
