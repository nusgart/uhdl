// part_32x32dpram.v --- 32x32 dual port synchronous SRAM
//
// Used by MMEM.

module part_32x32dpram(reset,
                       clk_a, address_a, q_a, data_a, wren_a, rden_a,
                       clk_b, address_b, q_b, data_b, wren_b, rden_b);

   input reset;

   input clk_a;
   input [4:0] address_a;
   input [31:0] data_a;
   input wren_a, rden_a;

   input clk_b;
   input [4:0] address_b;
   input [31:0] data_b;
   input wren_b, rden_b;

   output [31:0] q_a;
   output [31:0] q_b;

   ////////////////////////////////////////////////////////////////////////////////

   parameter RAM_SIZE = 32;

`ifdef SIMULATION
   reg [31:0] ram [0:RAM_SIZE-1];
   reg [31:0] out_a;
   reg [31:0] out_b;

   assign q_a = out_a;
   assign q_b = out_b;

 `ifdef debug
   integer i, debug;

   initial
     begin
        debug = 0;
        for (i = 0; i < RAM_SIZE; i=i+1)
          ram[i] = 32'b0;
     end
 `endif

   always @(posedge clk_a)
     if (wren_a)
       begin
          ram[address_a] <= data_a;
 `ifdef debug
          if (debug > 0 && address_a != 0)
            $display("mmem: W %o <- %o", address_a, data_a);
 `endif
       end
     else if (wren_b)
       begin
          ram[address_b] <= data_b;
 `ifdef debug
          if (debug > 0 && address_b != 0)
            $display("mmem: W %o <- %o", address_b, data_b);
 `endif
       end

   always @(posedge clk_a)
     if (reset)
       out_a <= 0;
     else if (rden_a)
       begin
          out_a <= ram[address_a];
 `ifdef debug
          if (debug > 0 && address_a != 0)
            $display("mmem: R %o -> %o", address_a, ram[address_a]);
 `endif
       end

   always @(posedge clk_b)
     if (reset)
       out_b <= 0;
     else if (rden_b)
       begin
          out_b <= ram[address_b];
 `ifdef debug
          if (debug > 0 && address_b != 0)
            $display("mmem : R %o -> %o", address_b, ram[address_b]);
 `endif
       end

`endif

`ifdef ISE
   wire ena_a = rden_a | wren_a;
   wire ena_b = rden_b | wren_b;

   ise_32x32_dpram inst
     (
      .clka(clk_a),
      .ena(ena_a),
      .wea(wren_a),
      .addra(address_a),
      .dina(data_a),
      .douta(q_a),
      .clkb(clk_b),
      .enb(ena_b),
      .web(wren_b),
      .addrb(address_b),
      .dinb(data_b),
      .doutb(q_b)
      );
`endif

endmodule
