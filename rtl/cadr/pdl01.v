// PDL0, PDL1
//
// TK CADR PDL BUFFER LEFT
// TK CADR PDL BUFFER RIGHT

module PDL01(clk, reset, prp, pdla, l, pwp, pdl);

   input clk;
   input reset;

   input [31:0] l;
   input [9:0] pdla;
   input prp;
   input pwp;
   output [31:0] pdl;

   ////////////////////////////////////////////////////////////////////////////////

   part_1kx32dpram_p i_PDL(.reset(reset), .clk_a(clk), .address_a(pdla), .q_a(pdl), .data_a(32'b0), .rden_a(prp), .wren_a(1'b0), .clk_b(clk), .address_b(pdla), .q_b(), .data_b(l), .rden_b(1'b0), .wren_b(pwp));

endmodule
