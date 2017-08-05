// DRAM0, DRAM1, DRAM2 --- DISPATCH RAM

module DRAM02(clk, reset, state_prefetch, state_write, vmo, a, r, ir, dmask, dispwr, dpc, dn, dp, dr);

   input clk;
   input reset;

   input state_prefetch;
   input state_write;

   input [23:0] vmo;
   input [31:0] a;;
   input [31:0] r;
   input [48:0] ir;
   input [6:0] dmask;
   input dispwr;
   output [13:0] dpc;
   output dn;
   output dp;
   output dr;

   ////////////////////////////////////////////////////////////////////////////////

   wire [10:0] dadr;
   wire daddr0;
   wire dwe;

   ////////////////////////////////////////////////////////////////////////////////

   assign daddr0 = (ir[8] & vmo[18]) | (ir[9] & vmo[19]) | (dmask[0] & r[0]) | (ir[12]);
   assign dadr = {ir[22:13], daddr0} | ({4'b0000, dmask[6:1], 1'b0} & {4'b0000, r[6:1], 1'b0});
   assign dwe = dispwr & state_write;
   part_2kx17dpram i_DRAM(.reset(reset), .clk_a(clk), .address_a(dadr), .q_a({dr, dp, dn, dpc}), .data_a(17'b0), .wren_a(1'b0), .rden_a(~state_prefetch && ~dwe), .clk_b(clk), .address_b(dadr), .q_b(), .data_b(a[16:0]), .wren_b(dwe), .rden_b(1'b0));

endmodule
