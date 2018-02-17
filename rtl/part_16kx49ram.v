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
   
   `ifdef VIVADO
   
       wire ena_a = rden_a | wren_a;
       // xpm_memory_spram: Single Port RAM
       // Xilinx Parameterized Macro, Version 2017.4
       
       
       xpm_memory_spram # (
      
         // Common module parameters
         .MEMORY_SIZE             (RAM_SIZE * 49),            //positive integer
         .MEMORY_PRIMITIVE        ("auto"),          //string; "auto", "distributed", "block" or "ultra";
         .MEMORY_INIT_FILE        ("none"),          //string; "none" or "<filename>.mem"
         .MEMORY_INIT_PARAM       (""    ),          //string;
         .USE_MEM_INIT            (1),               //integer; 0,1
         .WAKEUP_TIME             ("disable_sleep"), //string; "disable_sleep" or "use_sleep_pin"
         .MESSAGE_CONTROL         (0),               //integer; 0,1
         .MEMORY_OPTIMIZATION     ("false"),          //string; "true", "false"
       
         // Port A module parameters
         .WRITE_DATA_WIDTH_A      (49),              //positive integer
         .READ_DATA_WIDTH_A       (49),              //positive integer
         .BYTE_WRITE_WIDTH_A      (49),              //integer; 8, 9, or WRITE_DATA_WIDTH_A value
         .ADDR_WIDTH_A            (14),               //positive integer
         .READ_RESET_VALUE_A      ("0"),             //string
         .ECC_MODE                ("no_ecc"),        //string; "no_ecc", "encode_only", "decode_only" or "both_encode_and_decode"
         .AUTO_SLEEP_TIME         (0),               //Do not Change
         .READ_LATENCY_A          (2),               //non-negative integer
         .WRITE_MODE_A            ("read_first")     //string; "write_first", "read_first", "no_change"
       
       ) xpm_memory_spram_inst (
       
         // Common module ports
         .sleep                   (1'b0),
       
         // Port A module ports
         .clka                    (clk_a),
         .rsta                    (1'b0),
         .ena                     (ena_a),
         .regcea                  (1'b1),
         .wea                     (wren_a),
         .addra                   (address_a),
         .dina                    (data_a),
         .injectsbiterra          (1'b0),
         .injectdbiterra          (1'b0),
         .douta                   (q_a),
         .sbiterra                (),
         .dbiterra                ()
       
       );
       
       // End of xpm_memory_spram instance declaration
`endif

   
`ifdef SIMULATION
   reg [48:0] ram [0:RAM_SIZE-1];
   reg [48:0] q_a;

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
          q_a <= address_a == 14'o24045 ? 49'h000000001000 : ram[address_a];
 `else
          q_a <= ram[address_a];
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
