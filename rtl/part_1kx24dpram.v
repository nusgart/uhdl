// part_1kx24dpram.v --- 1kx24 dual port synchronous SRAM
//
// Used by VMEM1.

module part_1kx24dpram(reset,
                       clk_a, address_a, q_a, data_a, wren_a, rden_a,
                       clk_b, address_b, q_b, data_b, wren_b, rden_b);

   input reset;

   input clk_a;
   input [9:0] address_a;
   input [23:0] data_a;
   input wren_a, rden_a;

   input clk_b;
   input [9:0] address_b;
   input [23:0] data_b;
   input wren_b, rden_b;

   output [23:0] q_a;
   output [23:0] q_b;

   ////////////////////////////////////////////////////////////////////////////////

   parameter RAM_SIZE = 1024;

`ifdef SIMULATION
   reg [23:0] ram [0:RAM_SIZE-1];
   reg [23:0] q_a;
   reg [23:0] q_b;

 `ifdef debug
   integer i, debug;

   initial
     begin
        debug = 0;
        for (i = 0; i < RAM_SIZE; i=i+1)
          ram[i] = 24'b0;
     end
 `endif

   always @(posedge clk_a)
     if (wren_a)
       begin
          ram[address_a] <= data_a;
 `ifdef debug
          if (debug > 0)
            $display("vmem1: W %o <- %o; %t", address_a, data_a, $time);
 `endif
       end
     else if (wren_b)
       begin
          ram[address_b] <= data_b;
 `ifdef debug
          if (debug > 0)
            $display("vmem1: W %o <- %o; %t", address_b, data_b, $time);
 `endif
       end

   always @(posedge clk_a)
     if (reset)
       q_a <= 0;
     else if (rden_a)
       begin
          q_a <= ram[address_a];
 `ifdef debug
          if (debug > 1)
            $display("vmem1: R %o -> %o; %t",
                     address_a, ram[address_a], $time);
 `endif
       end

   always @(posedge clk_b)
     if (reset)
       q_b <= 0;
     else if (rden_b)
       begin
          q_b <= ram[address_b];
 `ifdef debug
          if (debug > 1)
            $display("vmem1: R %o -> %o; %t",
                     address_b, ram[address_b], $time);
 `endif
       end
`endif

`ifdef ISE
   wire ena_a = rden_a | wren_a;
   wire ena_b = rden_b | wren_b;

   ise_1kx24_dpram inst
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
