/* dmask prom */

module part_32x8prom ( clk, addr, q );

   input clk;
   input [4:0] addr;
   output [7:0] q;
   reg [7:0] 	q;

  always @(posedge clk)
    case (addr)
     5'h00: q = 8'h00;
     5'h01: q = 8'h01;
     5'h02: q = 8'h03;
     5'h03: q = 8'h07;
     5'h04: q = 8'h0f;
     5'h05: q = 8'h1f;
     5'h06: q = 8'h3f;
     5'h07: q = 8'h7f;
     default: q = 8'h00;
    endcase
endmodule
