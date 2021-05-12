`timescale 1ns/1ps
`default_nettype none

// ISIM: wave add /

module ram_controller_tb;

   reg clk100;
   reg clk50;
   reg clk25;
   reg clk1x;
   reg reset;

   reg [31:0] 	 test_read32;
   reg [48:0] 	 test_read49;
   reg 		 test_failed;

   wire prefetch;
   wire fetch;
   wire [4:0] 	 disk_state;

   reg [13:0] 	 mcr_addr;
   reg [48:0] 	 mcr_data_out;
   wire [48:0] 	 mcr_data_in;
   wire 	 mcr_ready;
   reg 		 mcr_write;
   wire 	 mcr_done;

   reg [21:0] 	 sdram_addr;
   reg [31:0] 	 sdram_data_out;
   wire [31:0] 	 sdram_data_in;
   wire 	 sdram_ready;
   reg 		 sdram_req;
   reg 		 sdram_write;
   wire 	 sdram_done;

   reg [14:0] 	 vram_cpu_addr;
   reg [31:0] 	 vram_cpu_data_out;
   wire [31:0] 	 vram_cpu_data_in;
   reg 		 vram_cpu_req;
   wire 	 vram_cpu_ready;
   reg 		 vram_cpu_write;
   wire 	 vram_cpu_done;

   reg [14:0] 	 vram_vga_addr;
   wire [31:0] 	 vram_vga_data_out;
   reg 		 vram_vga_req;
   wire 	 vram_vga_ready;

   wire [17:0] 	 sram_a;
   wire 	 sram_oe_n, sram_we_n;
   wire [15:0] 	 sram1_in;
   wire [15:0] 	 sram1_out;
   wire [15:0] 	 sram2_in;
   wire [15:0] 	 sram2_out;
   wire 	 sram1_ce_n, sram1_ub_n, sram1_lb_n;
   wire 	 sram2_ce_n, sram2_ub_n, sram2_lb_n;

   reg [4:0] 	 cpu_state;
   
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
   
   ram_controller DUT(
		      .clk(clk100),
		      .vga_clk(clk50),
		      .cpu_clk(clk1x),
		      .reset(reset),
		      .prefetch(prefetch),
		      .fetch(fetch),
      
		      .mcr_addr(mcr_addr),
		      .mcr_data_out(mcr_data_in),
		      .mcr_data_in(mcr_data_out),
		      .mcr_ready(mcr_ready),
		      .mcr_write(mcr_write),
		      .mcr_done(mcr_done),

		      .sdram_addr(sdram_addr),
		      .sdram_data_in(sdram_data_out),
		      .sdram_data_out(sdram_data_in),
		      .sdram_req(sdram_req),
		      .sdram_ready(sdram_ready),
		      .sdram_write(sdram_write),
		      .sdram_done(sdram_done),
      
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
		      .vram_vga_ready(vram_vga_ready),
      
		      .sram_a(sram_a),
		      .sram_oe_n(sram_oe_n),
		      .sram_we_n(sram_we_n),
		      .sram1_in(sram1_in),
		      .sram1_out(sram1_out),
		      .sram1_ce_n(sram1_ce_n),
		      .sram1_ub_n(sram1_ub_n),
		      .sram1_lb_n(sram1_lb_n),
		      .sram2_in(sram2_in),
		      .sram2_out(sram2_out),
		      .sram2_ce_n(sram2_ce_n),
		      .sram2_ub_n(sram2_ub_n),
		      .sram2_lb_n(sram2_lb_n)
		      );

   always
     begin
	#10 clk100 = 0;
	#10 clk100 = 1;
     end

   initial
     clk50 = 0;
   
   always @(posedge clk100)
     clk50 = ~clk50;

   initial
     clk25 = 0;
   
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
	 @(posedge clk100);
	 while (vram_vga_ready == 0)
	   begin
	      @(posedge clk100);
	   end
	 test_read32 = vram_vga_data_out;
	 vram_vga_req = 0;
	 $display("vram_vga_read @%x done; %t", addr, $time);
	 if (test_read32 !== data) begin
	    test_failed = 1;
	    $display("vram_vga_read failed %o != %o", test_read32, data);
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
	 @(posedge clk100);
	 while (vram_cpu_done == 0)
	   @(posedge clk100);
	 vram_cpu_write = 0;
	 $display("vram_cpu_write @%x done; %t", addr, $time);
	 while (vram_cpu_done != 0)
	   @(posedge clk100);
      end
   endtask

   task t_vram_cpu_read;
      input [14:0] addr;
      input [31:0] data;
      begin
	 $display("vram_cpu_read @%x; %t", addr, $time);
	 vram_cpu_addr = addr;
	 vram_cpu_req = 1;
	 @(posedge clk100);
	 while (vram_cpu_ready == 0)
	   @(posedge clk100);
	 test_read32 = vram_cpu_data_in;
	 vram_cpu_req = 0;
	 $display("vram_cpu_read @%x done; %t", addr, $time);
	 while (vram_cpu_ready != 0)
	   @(posedge clk100);
	 if (test_read32 !== data) begin
	    test_failed = 1;
	    $display("vram_cpu_read failed %o != %o", test_read32, data);
	 end
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
	    test_failed = 1;
	    $display("mcr_read failed %o != %o", test_read49, data);
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
	    test_failed = 1;
	    $display("ram_sdram_read failed %o != %o", test_read32, data);
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

	t_vram_cpu_write(100, 32'o12345670);
	t_vram_cpu_write(102, 32'o22222222);
	t_vram_cpu_write(104, 32'o33333333);

	#200;
	t_vram_cpu_read(100, 32'o12345670);
	t_vram_cpu_read(102, 32'o22222222);
	t_vram_cpu_read(104, 32'o33333333);
	
	#320 t_vram_vga_read(100, 32'o12345670);
	#320 t_vram_vga_read(102, 32'o22222222);
	#320 t_vram_vga_read(104, 32'o33333333);


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
	if (test_failed) $display("TEST FAILED ***");
	else $display("TEST PASSED ***");
	
	$finish;
     end

   initial
     begin
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

// Local Variables:
// verilog-library-directories: (".")
// End:
