// part_21kx32dpram.v --- 21kx32 dual port synchronous SRAM
//
// Used by VRAM.

module part_21kx32dpram(reset,
                        clk_a, address_a, q_a, data_a, wren_a, rden_a,
                        clk_b, address_b, q_b, data_b, wren_b, rden_b);

   input reset;

   input clk_a;
   input [14:0] address_a;
   input [31:0] data_a;
   input wren_a, rden_a;

   input clk_b;
   input [14:0] address_b;
   input [31:0] data_b;
   input wren_b, rden_b;

   output [31:0] q_a;
   output [31:0] q_b;

   ////////////////////////////////////////////////////////////////////////////////

   parameter RAM_SIZE = 21504;

`ifdef SIMULATION
   reg [31:0] ram [0:RAM_SIZE-1];
   reg [31:0] q_a;
   reg [31:0] q_b;

 `ifdef debug
   integer i;

   initial
     begin
        for (i = 0; i < RAM_SIZE; i=i+1)
          ram[i] = 32'b0;
     end
 `endif

   always @(posedge clk_a)
     if (reset)
       q_a <= 0;
     else
       begin
 `ifdef debug
          $display("vram: read @ %x", address_a);
 `endif
          q_a <= ram[address_a];
          if (wren_a)
            begin
               q_a <= data_a;
               ram[address_a] <= data_a;
            end
       end

   always @(posedge clk_b)
     if (reset)
       q_b <= 0;
     else
       begin
 `ifdef debug_rw
          $display("vram: read @ %x", address_b);
 `endif
          q_b <= ram[address_b];
          if (wren_b)
            begin
               q_b <= data_b;
               ram[address_b] <= data_b;
            end
       end

`endif

`ifdef ISE
   wire ena_a = rden_a | wren_a;
   wire ena_b = rden_b | wren_b;

   ise_21kx32_dpram inst
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
