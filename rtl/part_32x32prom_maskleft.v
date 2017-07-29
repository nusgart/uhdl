// part_32x32prom_maskleft.v --- 32x32 ROM

module part_32x32prom_maskleft(clk, addr, q);

   input clk;
   input [4:0] addr;
   output [31:0] q;
   reg [31:0] q;

   always @(posedge clk)
     case (addr)
       5'h00: q = 32'h00000001;
       5'h01: q = 32'h00000003;
       5'h02: q = 32'h00000007;
       5'h03: q = 32'h0000000f;
       5'h04: q = 32'h0000001f;
       5'h05: q = 32'h0000003f;
       5'h06: q = 32'h0000007f;
       5'h07: q = 32'h000000ff;
       5'h08: q = 32'h000001ff;
       5'h09: q = 32'h000003ff;
       5'h0a: q = 32'h000007ff;
       5'h0b: q = 32'h00000fff;
       5'h0c: q = 32'h00001fff;
       5'h0d: q = 32'h00003fff;
       5'h0e: q = 32'h00007fff;
       5'h0f: q = 32'h0000ffff;
       5'h10: q = 32'h0001ffff;
       5'h11: q = 32'h0003ffff;
       5'h12: q = 32'h0007ffff;
       5'h13: q = 32'h000fffff;
       5'h14: q = 32'h001fffff;
       5'h15: q = 32'h003fffff;
       5'h16: q = 32'h007fffff;
       5'h17: q = 32'h00ffffff;
       5'h18: q = 32'h01ffffff;
       5'h19: q = 32'h03ffffff;
       5'h1a: q = 32'h07ffffff;
       5'h1b: q = 32'h0fffffff;
       5'h1c: q = 32'h1fffffff;
       5'h1d: q = 32'h3fffffff;
       5'h1e: q = 32'h7fffffff;
       5'h1f: q = 32'hffffffff;
     endcase

endmodule
