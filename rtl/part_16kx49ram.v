// part_16kx49ram.v --- 16k49 SRAM
//
// Used by IRAM.

module part_16kx49ram(reset,
                      clk_a, address_a, q_a, data_a, wren_a, rden_a);

   input reset;

   input clk_a;
   input [13:0] address_a;
   input [48:0] data_a;
   input wren_a, rden_a;

   output [48:0] q_a;

   ////////////////////////////////////////////////////////////////////////////////

   parameter RAM_SIZE = 16384;

`ifdef SIMULATION
   reg [48:0] ram [0:RAM_SIZE-1];
   reg [48:0] out_a;

   assign q_a = out_a;

 `ifdef debug
   integer i, debug;

   initial
     begin
        debug = 0;
        for (i = 0; i < RAM_SIZE; i=i+1)
          ram[i] = 49'b0;
     end
 `endif

   always @(posedge clk_a)
     if (wren_a)
       begin
          ram[address_a] <= data_a;
 `ifdef debug
          if (debug != 0)
            $display("iram: W %o <- %o; %t", address_a, data_a, $time);
 `endif
       end

   always @(posedge clk_a)
     if (rden_a)
       begin
          // Patch out DISK-COPY (which takes hours to simulate).
 `ifdef debug_patch_disk_copy
          out_a <= address_a == 14'o24045 ? 49'h000000001000 : ram[address_a];
 `else
          out_a <= ram[address_a];
 `endif
 `ifdef debug
          if (debug > 1)
            $display("iram: R %o -> %o; %t",
                     address_a, ram[address_a], $time);
 `endif
       end
`endif

`ifdef ISE
   wire ena_a = rden_a | wren_a;

   ise_16kx49ram inst
     (
      .clka(clk_a),
      .ena(ena_a),
      .wea(wren_a),
      .addra(address_a),
      .dina(data_a),
      .douta(q_a)
      );
`endif

endmodule
