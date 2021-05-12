`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2021 01:41:18 PM
// Design Name: 
// Module Name: memory_controller_A7_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`default_nettype none
`define DEBUG
`ifndef VCDFILE
 `define VCDFILE "rzc_mister.vcd"
`endif
// ISIM: wave add /

module memory_controller_A7_tb;
   // 200MHz reference clock
   reg clk200;
   reg clk100;
   reg clk50;
   reg clk25;
   reg clk1x;
   reg reset;

   reg [31:0] test_read32;
   reg [48:0] test_read49;
   reg 	      test_failed;

   wire       prefetch;
   wire       fetch;
   wire [4:0] disk_state;

   reg [13:0] mcr_addr;
   reg [48:0] mcr_data_out;
   wire [48:0] mcr_data_in;
   wire        mcr_ready;
   reg 	       mcr_write;
   wire        mcr_done;

   reg [21:0]  sdram_addr;
   reg [31:0]  sdram_data_out;
   wire [31:0] sdram_data_in;
   wire        sdram_ready;
   reg 	       sdram_req;
   reg 	       sdram_write;
   wire        sdram_done;

   reg [14:0]  vram_cpu_addr;
   reg [31:0]  vram_cpu_data_out;
   wire [31:0] vram_cpu_data_in;
   reg 	       vram_cpu_req;
   wire        vram_cpu_ready;
   reg 	       vram_cpu_write;
   wire        vram_cpu_done;

   reg [14:0]  vram_vga_addr;
   wire [31:0] vram_vga_data_out;
   reg 	       vram_vga_req;
   wire        vram_vga_ready;

   /*wire [17:0] 	 sram_a;
    wire 	 sram_oe_n, sram_we_n;
    wire [15:0] 	 sram1_in;
    wire [15:0] 	 sram1_out;
    wire [15:0] 	 sram2_in;
    wire [15:0] 	 sram2_out;
    wire 	 sram1_ce_n, sram1_ub_n, sram1_lb_n;
    wire 	 sram2_ce_n, sram2_ub_n, sram2_lb_n;*/
   
   
   logic       DDRAM_CLK;
   logic       DDRAM_BUSY;
   logic [7:0] DDRAM_BURSTCNT;
   logic [28:0] DDRAM_ADDR;
   logic [63:0] DDRAM_DOUT;
   logic 	DDRAM_DOUT_READY;
   logic 	DDRAM_RD;
   logic [63:0] DDRAM_DIN;
   logic [7:0] 	DDRAM_BE;
   logic 	DDRAM_WE;

   reg [4:0] 	cpu_state;
   
   
   always @(posedge clk1x)
     if (reset)
       cpu_state <= 0;
     else
       begin
	  case (cpu_state)
	    0: cpu_state <= 1;
	    1: cpu_state <= 2;
	    2: cpu_state <= 3;
	    3: cpu_state <= 5;
	    4: cpu_state <= 5;
	    5: cpu_state <= 1;
	  endcase 
       end

   assign prefetch = cpu_state == 3 || cpu_state == 4;
   assign fetch = cpu_state == 5;
   
   wire [15:0] ddr3_dq;
   wire [1:0]  ddr3_dqs_p;
   wire [1:0]  ddr3_dqs_n;
   wire [13:0] ddr3_addr;
   wire [1:0]  ddr3_dm;
   wire        ddr3_odt;
   
   // command interface
   wire [2:0]  ddr3_ba; 
   wire        ddr3_cs_n;
   wire        ddr3_cas_n;
   wire        ddr3_ras_n;
   wire        ddr3_we_n;
   wire        ddr3_reset_n;   
   // clock
   wire        ddr3_ck_p;
   wire        ddr3_ck_n;
   wire        ddr3_cke;
   
   wire sdram_calib_done;
   
   ddr3_model u_comp_ddr3 (
     .rst_n   (ddr3_reset_n),
     .ck      (ddr3_ck_p),
     .ck_n    (ddr3_ck_n),
     .cke     (ddr3_cke),
     .cs_n    (ddr3_cs_n),
     .ras_n   (ddr3_ras_n),
     .cas_n   (ddr3_cas_n),
     .we_n    (ddr3_we_n),
     .dm_tdqs (ddr3_dm),
     .ba      (ddr3_ba),
     .addr    (ddr3_addr),
     .dq      (ddr3_dq),
     .dqs     (ddr3_dqs_p),
     .dqs_n   (ddr3_dqs_n),
     .tdqs_n  (),
     .odt     (ddr3_odt)
   );   
   
   memory_controller_A7 DUT(
     .ref_clk(clk200),
     .sdram_clk(clk100),
     .vga_clk(clk50),
     .cpu_clk(clk1x),
     .reset(reset),
     .prefetch(prefetch),
     .machrun(1'b1),
     .fetch(fetch),
      
     .mcr_addr(mcr_addr),
     .mcr_data_out(mcr_data_in),
     .mcr_data_in(mcr_data_out),
     .mcr_ready(mcr_ready),
     .mcr_write(mcr_write),
     .mcr_done(mcr_done),
     
     .sdram_reset(reset),
     .sdram_addr(sdram_addr),
     .sdram_data_in(sdram_data_out),
     .sdram_data_out(sdram_data_in),
     .sdram_req(sdram_req),
     .sdram_calib_done(sdram_calib_done),
     .sdram_ready(sdram_ready),
     .sdram_write(sdram_write),
     .sdram_done(sdram_done),
     
     // DDR3
     .ddr3_addr            (ddr3_addr),  // output [13:0]		ddr3_addr
     .ddr3_ba              (ddr3_ba),  // output [2:0]		ddr3_ba
     .ddr3_cas_n           (ddr3_cas_n),  // output			ddr3_cas_n
     .ddr3_ck_n            (ddr3_ck_n),  // output [0:0]		ddr3_ck_n
     .ddr3_ck_p            (ddr3_ck_p),  // output [0:0]		ddr3_ck_p
     .ddr3_cke             (ddr3_cke),  // output [0:0]		ddr3_cke
     .ddr3_ras_n           (ddr3_ras_n),  // output			ddr3_ras_n
     .ddr3_reset_n         (ddr3_reset_n),  // output			ddr3_reset_n
     .ddr3_we_n            (ddr3_we_n),  // output			ddr3_we_n
     .ddr3_dq              (ddr3_dq),  // inout [15:0]		ddr3_dq
     .ddr3_dqs_n           (ddr3_dqs_n),  // inout [1:0]		ddr3_dqs_n
     .ddr3_dqs_p           (ddr3_dqs_p),
     .ddr3_cs_n            (ddr3_cs_n),
     .ddr3_dm              (ddr3_dm),
     .ddr3_odt             (ddr3_odt),
     
     .vram_cpu_addr(vram_cpu_addr),
     .vram_cpu_data_in(vram_cpu_data_out),
     .vram_cpu_data_out(vram_cpu_data_in),
     .vram_cpu_req(vram_cpu_req),
     .vram_cpu_ready(vram_cpu_ready),
     .vram_cpu_write(vram_cpu_write),
     .vram_cpu_done(vram_cpu_done),
     .vram_vga_addr(vram_vga_addr),
     .vram_vga_data_out(vram_vga_data_out),
     .vram_vga_req(vram_vga_req),
     .vram_vga_ready(vram_vga_ready)
  );
  
  initial clk200 = 0;
  
  always begin
    #2.5ns clk200=~clk200;
   end;
  
  initial clk100 = 0;
  
  always @(posedge clk200)
     clk100 = ~clk100;
  /*always begin
    #10 clk100 = 0;
    #10 clk100 = 1;
  end*/

   initial clk50 = 0;
   
   always @(posedge clk100)
     clk50 = ~clk50;

   initial clk25 = 0;
   
   always @(posedge clk50)
     clk25 = ~clk25;

   initial
     clk1x = 0;
   
   always @(posedge clk25)
     clk1x = ~clk1x;

   task t_vram_vga_read;
      input [14:0] addr;
      input [31:0] data;
      begin
	 $display("vram_vga_read @%x; %t", addr, $time);
	 vram_vga_addr = addr;
	 vram_vga_req = 1;
	 @(posedge clk50);
	 while (vram_vga_ready == 0)
	   begin
	      @(posedge clk50);
	   end
	 test_read32 = vram_vga_data_out;
	 vram_vga_req = 0;
	 $display("vram_vga_read @%x done; %t", addr, $time);
	 if (test_read32 !== data) begin
	    test_failed = 1;
	    //$display("vram_vga_read failed %o != %o", test_read32, data);
	    $display("vram_vga_read failed %x != %x", test_read32, data);
	 end
      end
   endtask

   task t_vram_cpu_write;
      input [14:0] addr;
      input [31:0] data;
      begin
	 $display("vram_cpu_write @%x; %t", addr, $time);
	 vram_cpu_addr = addr;
	 vram_cpu_data_out = data;
	 vram_cpu_write = 1;
	 @(posedge clk1x);
	 @(posedge clk1x);
	 while (vram_cpu_done == 0)
	   @(posedge clk1x);
	 vram_cpu_write = 0;
	 $display("vram_cpu_write @%x done; %t", addr, $time);
	 @(posedge clk1x);
	 @(posedge clk1x);
	 //while (vram_cpu_done != 0)
	 //  @(posedge clk100);
      end
   endtask

   task t_vram_cpu_read;
      input [14:0] addr;
      input [31:0] data;
      begin
         $display("test cpu read begin");
	 $display("vram_cpu_read @%x; %t", addr, $time);
	 vram_cpu_addr = addr;
	 vram_cpu_req = 1;
	 @(posedge clk100);
	 while (vram_cpu_ready == 0)
	   @(posedge clk100);
	 test_read32 = vram_cpu_data_in;
	 vram_cpu_req = 0;
	 $display("test cpu read 0");
	 $display("vram_cpu_read @%x done; %t", addr, $time);
	 $display("test cpu read 1");
	 /*
	 while (vram_cpu_ready != 0)
	   @(posedge clk100);
	 */
	 @(posedge clk1x);
	 @(posedge clk1x);
	 if (test_read32 !== data) begin
	    test_failed = 2;
	    //$display("vram_cpu_read failed %o != %o", test_read32, data);
	    $display("vram_cpu_read failed %x != %x", test_read32, data);
	 end
	 $display("test cpu read");
      end
   endtask

   task t_ram_mcr_write;
      input [13:0] addr;
      input [48:0] data;
      begin
	 $display("mcr_write @%x; %t", addr, $time);
	 mcr_addr = addr;
	 mcr_data_out = data;
	 mcr_write = 1;
	 @(posedge clk100);
	 while (mcr_done == 0)
	   begin
	      @(posedge clk100);
	   end
	 mcr_write = 0;
	 $display("mcr_write @%x done; %t", addr, $time);
      end
   endtask

   task t_ram_mcr_read;
      input [13:0] addr;
      input [48:0] data;
      begin
	 $display("mcr_read @%x; %t", addr, $time);
	 mcr_addr = addr;
	 @(posedge fetch)
	   @(posedge clk100);
	 while (mcr_ready == 0)
	   begin
	      @(posedge clk100);
	   end
	 test_read49 = mcr_data_in;
	 $display("mcr_read @%x done; %t", addr, $time);
	 if (test_read49 !== data) begin
	    test_failed = 3;
	    //$display("mcr_read failed %o != %o", test_read49, data);
	    $display("mcr_read failed %x != %x", test_read49, data);
	 end
      end
   endtask

   task t_ram_sdram_read;
      input [21:0] addr;
      input [31:0] data;
      begin
	 $display("ram_sdram_read @%x; %t", addr, $time);
	 sdram_addr = addr;
	 sdram_req = 1;
	 @(posedge clk100);
	 
	 while (sdram_ready == 0)
	   begin
	      @(posedge clk100);
	   end
	 test_read32 = sdram_data_in;
	 sdram_req = 0;
	 $display("ram_sdram_read @%x done; %t", addr, $time);
	 while (sdram_ready != 0)
	   @(posedge clk100);
	 if (test_read32 !== data) begin
	    test_failed = 4;
	    //$display("ram_sdram_read failed %o != %o", test_read32, data);
	    $display("ram_sdram_read failed %x != %x", test_read32, data);
	 end
      end
   endtask

   task t_ram_sdram_write;
      input [21:0] addr;
      input [31:0] data;
      begin
	 $display("ram_sdram_write @%x; %t", addr, $time);
	 sdram_addr = addr;
	 sdram_data_out = data;
	 sdram_write = 1;
	 @(posedge clk100);
	 while (sdram_done == 0)
	   begin
	      @(posedge clk100);
	   end
	 sdram_write = 0;
	 $display("ram_sdram_write @%x done; %t", addr, $time);
	 while (sdram_done != 0)
	   @(posedge clk100);
      end
   endtask

   initial
     begin
	reset = 0;
	
	#5 reset = 1;
	#100 reset = 0;
	

	$display("Starting VRAM cpu tests");
	t_vram_cpu_write(100, 32'o12345670);
	t_vram_cpu_write(102, 32'o22222222);
	t_vram_cpu_write(104, 32'o33333333);
	$display("finished vram cpu write");
	#200;
	t_vram_cpu_read(100, 32'o12345670);
	t_vram_cpu_read(102, 32'o22222222);
	t_vram_cpu_read(104, 32'o33333333);
	$display("finished vram cpu read");
	
	$display("Starting VRAM VGA read");
	#320 t_vram_vga_read(100, 32'o12345670);
	#320 t_vram_vga_read(102, 32'o22222222);
	#320 t_vram_vga_read(104, 32'o33333333);
	$display("Finished VRAM VGA read");
	//
`ifdef DONT_DEFINE_THIS
	#200;
	@(posedge fetch)
	  t_ram_mcr_write(0, 49'o111100001111);
	@(posedge fetch)
	  t_ram_mcr_write(1, 49'o222200002222);
	@(posedge fetch)
	  t_ram_mcr_write(2, 49'o333300003333);

	#200;
	t_ram_mcr_read(0, 49'o111100001111);
	t_ram_mcr_read(1, 49'o222200002222);
	t_ram_mcr_read(2, 49'o333300003333);
`endif
        $display("Waiting for SDRAM calibration to complete");
        while (~sdram_calib_done)
          @(posedge clk1x);
        
        $display("SDRAM calibration done");
	#200;
	t_ram_sdram_write(0, 32'o00000000);
	t_ram_sdram_write(1, 32'o10101111);
	t_ram_sdram_write(2, 32'o20202222);
	t_ram_sdram_write(4, 32'o30303333);
	
	#200;
	t_ram_sdram_read(0, 32'o00000000);
	t_ram_sdram_read(1, 32'o10101111);
	t_ram_sdram_read(2, 32'o20202222);
	t_ram_sdram_read(4, 32'o30303333);

	
	#5000;
	if (test_failed) $display("TEST FAILED *** %d", test_failed);
	else $display("TEST PASSED ***");
	
	$finish;
     end

   initial
     begin
        test_failed = 0;
	mcr_addr = 0;
	mcr_data_out = 0;
	mcr_write = 0;
	
	sdram_addr = 2;
	sdram_data_out = 0;
	sdram_req = 0;
	sdram_write = 0;

	vram_cpu_addr = 4;
	vram_cpu_data_out = 0;
	vram_cpu_req = 0;
	vram_cpu_write = 0;

	vram_vga_addr = 6;
	vram_vga_req = 0;
     end


   initial begin
      $timeformat(-9, 0, "ns", 7);
      $dumpfile(`VCDFILE);
      $dumpvars(0, DUT);
   end
endmodule
`default_nettype wire
