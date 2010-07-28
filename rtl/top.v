/*
 */

module top(rs232_txd, rs232_rxd,
	   button, led, sysclk,
	   sevenseg, sevenseg_an,
	   slideswitch,
	   sram_a, sram_oe_n, sram_we_n,
	   sram1_io, sram1_ce_n, sram1_ub_n, sram1_lb_n,
	   sram2_io, sram2_ce_n, sram2_ub_n, sram2_lb_n,
	   ide_data_bus, ide_dior, ide_diow, ide_cs, ide_da);

   input	rs232_rxd;
   output	rs232_txd;

   input [3:0] 	button;

   output [7:0] led;
   input 	sysclk;

   output [7:0] sevenseg;
   output [3:0] sevenseg_an;

   input [7:0] 	slideswitch;

   output [17:0] sram_a;
   output 	 sram_oe_n;
   output 	 sram_we_n;

   inout [15:0]	 sram1_io;
   output 	 sram1_ce_n;
   output 	 sram1_ub_n;
   output 	 sram1_lb_n;

   inout [15:0]	 sram2_io;
   output 	 sram2_ce_n;
   output 	 sram2_ub_n;
   output 	 sram2_lb_n;
   
   inout [15:0]  ide_data_bus;
   wire [15:0] 	 ide_data_in;
   wire [15:0] 	 ide_data_out;
   output 	 ide_dior;
   output 	 ide_diow;
   output [1:0]  ide_cs;
   output [2:0]  ide_da;

   // -----------------------------------------------------------------

   wire 	 clk;
   wire 	 clk100;
   wire 	 reset;
   wire 	 interrupt;
   wire		 boot;

   wire [15:0] 	 spy_in;
   wire [15:0] 	 spy_out;
   wire 	 dbread, dbwrite;
   wire [3:0] 	 eadr;
   wire 	 halt;
   
   wire [11:0] 	 mcr_addr;
   wire [51:0] 	 mcr_data_out;
   wire [51:0] 	 mcr_data_in;
   wire 	 mcr_ready;
   wire 	 mcr_write;
   wire 	 mcr_done;

   wire [17:0] 	 sdram_addr;
   wire [31:0] 	 sdram_data_out;
   wire [31:0] 	 sdram_data_in;
   wire 	 sdram_ready;
   wire 	 sdram_req;
   wire 	 sdram_write;
   wire 	 sdram_done;

   wire [14:0] 	 vram_addr;
   wire [31:0] 	 vram_data_out;
   wire [31:0] 	 vram_data_in;
   wire 	 vram_req;
   wire 	 vram_ready;
   wire 	 vram_write;
   wire 	 vram_done;

   support support(.sysclk(sysclk),
		   .clk(clk),
		   .reset(reset),
		   .button(button[3]),
		   .interrupt(interrupt),
		   .boot(boot),
		   .halt(halt));
   
   clk_dcm clk_dcm(.CLKIN_IN(sysclk), 
		   .RST_IN(reset), 
		   .CLKFX_OUT(clk100), 
		   .CLKIN_IBUFG_OUT(sysclk_buf), 
		   .CLK0_OUT(clk),
		   .CLK2X_OUT(), 
		   .LOCKED_OUT());
   
   caddr cpu (.clk(clk),
	      .ext_int(interrupt),
	      .ext_reset(reset),
	      .ext_boot(boot),
	      .ext_halt(halt),
	      .spy_in(spy_in),
	      .spy_out(spy_out),
	      .dbread(dbread),
	      .dbwrite(dbwrite),
	      .eadr(eadr),

	      .mcr_addr(mcr_addr),
	      .mcr_data_out(mcr_data_out),
	      .mcr_data_in(mcr_data_in),
	      .mcr_ready(mcr_ready),
	      .mcr_write(mcr_write),
	      .mcr_done(mcr_done),

	      .sdram_addr(sdram_addr),
	      .sdram_data_in(sdram_data_in),
	      .sdram_data_out(sdram_data_out),
	      .sdram_req(sdram_req),
	      .sdram_ready(sdram_ready),
	      .sdram_write(sdram_write),
	      .sdram_done(sdram_done),
      
	      .vram_addr(vram_addr),
	      .vram_data_in(vram_data_in),
	      .vram_data_out(vram_data_out),
	      .vram_req(vram_req),
	      .vram_ready(vram_ready),
	      .vram_write(vram_write),
	      .vram_done(vram_done),

	      .ide_data_in(ide_data_in),
	      .ide_data_out(ide_data_out),
	      .ide_dior(ide_dior),
	      .ide_diow(ide_diow),
	      .ide_cs(ide_cs),
	      .ide_da(ide_da));

   assign ide_data_bus = ide_diow ? ide_data_out : 16'bz;
   assign ide_data_in = ide_data_bus;
   
   assign      eadr = 4'b0;
   assign      dbread = 0;
   assign      dbwrite = 0;

   ram_controller rc (.clk(clk),
		      .reset(reset),

		      .mcr_addr(mcr_addr),
		      .mcr_data_out(mcr_data_out),
		      .mcr_data_in(mcr_data_in),
		      .mcr_ready(mcr_ready),
		      .mcr_write(mcr_write),
		      .mcr_done(mcr_done),

		      .sdram_addr(sdram_addr),
		      .sdram_data_in(sdram_data_in),
		      .sdram_data_out(sdram_data_out),
		      .sdram_req(sdram_req),
		      .sdram_ready(sdram_ready),
		      .sdram_write(sdram_write),
		      .sdram_done(sdram_done),
      
		      .vram_addr(vram_addr),
		      .vram_data_in(vram_data_in),
		      .vram_data_out(vram_data_out),
		      .vram_req(vram_req),
		      .vram_ready(vram_ready),
		      .vram_write(vram_write),
		      .vram_done(vram_done),
      
		      .sram_a(sram_a),
		      .sram_oe_n(sram_oe_n),
		      .sram_we_n(sram_we_n),
		      .sram1_io(sram1_io),
		      .sram1_ce_n(sram1_ce_n),
		      .sram1_ub_n(sram1_ub_n),
		      .sram1_lb_n(sram1_lb_n),
		      .sram2_io(sram2_io),
		      .sram2_ce_n(sram2_ce_n),
		      .sram2_ub_n(sram2_ub_n),
		      .sram2_lb_n(sram2_lb_n)
		      );

   vga_display vga (.clk(clk),
		    .pixclk(clk100),
		    .reset(reset),

		    .vram_addr(vram_addr),
		    .vram_data(vram_data_out),
		    .vram_req(vram_req),
		    .vram_ready(vram_ready),
      
		    .vga_red(vga_red),
		    .vga_blu(vga_blu),
		    .vga_grn(vga_grn),
		    .vga_hsync(vga_hsync),
		    .vga_vsync(vga_vsync)
		    );

   
endmodule
