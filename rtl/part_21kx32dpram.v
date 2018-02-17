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
   parameter ADDR_WIDTH = 15;
   parameter DATA_WIDTH = 32;

`ifdef VIVADO
   
   
   wire ena_a = rden_a | wren_a;
   wire ena_b = rden_b | wren_b;

    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, Version 2017.4
    xpm_memory_tdpram # (
    
      // Common module parameters
      .MEMORY_SIZE             (RAM_SIZE * DATA_WIDTH),            //positive integer
      .MEMORY_PRIMITIVE        ("auto"),          //string; "auto", "distributed", "block" or "ultra";
      .CLOCKING_MODE           ("common_clock"),  //string; "common_clock", "independent_clock"
      .MEMORY_INIT_FILE        ("none"),          //string; "none" or "<filename>.mem"
      .MEMORY_INIT_PARAM       (""    ),          //string;
      .USE_MEM_INIT            (1),               //integer; 0,1
      .WAKEUP_TIME             ("disable_sleep"), //string; "disable_sleep" or "use_sleep_pin"
      .MESSAGE_CONTROL         (0),               //integer; 0,1
      .ECC_MODE                ("no_ecc"),        //string; "no_ecc", "encode_only", "decode_only" or "both_encode_and_decode"
      .AUTO_SLEEP_TIME         (0),               //Do not Change
      .USE_EMBEDDED_CONSTRAINT (0),               //integer: 0,1
      .MEMORY_OPTIMIZATION     ("true"),          //string; "true", "false"
    
      // Port A module parameters
      .WRITE_DATA_WIDTH_A      (DATA_WIDTH),              //positive integer
      .READ_DATA_WIDTH_A       (DATA_WIDTH),              //positive integer
      .BYTE_WRITE_WIDTH_A      (DATA_WIDTH),              //integer; 8, 9, or WRITE_DATA_WIDTH_A value
      .ADDR_WIDTH_A            (ADDR_WIDTH),               //positive integer
      .READ_RESET_VALUE_A      ("0"),             //string
      .READ_LATENCY_A          (2),               //non-negative integer
      .WRITE_MODE_A            ("no_change"),     //string; "write_first", "read_first", "no_change"
    
      // Port B module parameters
      .WRITE_DATA_WIDTH_B      (DATA_WIDTH),              //positive integer
      .READ_DATA_WIDTH_B       (DATA_WIDTH),              //positive integer
      .BYTE_WRITE_WIDTH_B      (DATA_WIDTH),              //integer; 8, 9, or WRITE_DATA_WIDTH_B value
      .ADDR_WIDTH_B            (ADDR_WIDTH),               //positive integer
      .READ_RESET_VALUE_B      ("0"),             //vector of READ_DATA_WIDTH_B bits
      .READ_LATENCY_B          (2),               //non-negative integer
      .WRITE_MODE_B            ("no_change")      //string; "write_first", "read_first", "no_change"
    
    ) xpm_memory_tdpram_inst (
    
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
      .dbiterra                (),
    
      // Port B module ports
      .clkb                    (clk_b),
      .rstb                    (1'b0),
      .enb                     (ena_b),
      .regceb                  (1'b1),
      .web                     (wren_b),
      .addrb                   (address_b),
      .dinb                    (data_b),
      .injectsbiterrb          (1'b0),
      .injectdbiterrb          (1'b0),
      .doutb                   (q_b),
      .sbiterrb                (),
      .dbiterrb                ()
    
    );
    
    // End of xpm_memory_tdpram instance declaration

`endif

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
