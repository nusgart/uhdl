// uhdl.v --- ---!!!

`timescale 1ns/1ps
// `default_nettype none

`define enable_mmc
`define enable_vga
`define enable_ps2
`define enable_spy_port

/* verilator lint_off SELRANGE */
/* verilator lint_off IMPLICIT */
/* verilator lint_off PINMISSING */
/* verilator lint_off WIDTH */

module uhdl;

   reg boot;
   reg reset;
   wire [11:0] bd_state;
   wire [11:0] ms_x, ms_y;
   wire [15:0] bd_data_bd2cpu;
   wire [15:0] bd_data_cpu2bd;
   wire [15:0] kb_data;
   wire [15:0] spy_bd_data_bd2cpu;
   wire [15:0] spy_bd_data_cpu2bd;
   wire [15:0] spy_bd_state;
   wire [15:0] spy_in;
   wire [15:0] spy_out;
   wire [15:0] sram1_in;
   wire [15:0] sram2_in;
   wire [1:0] bd_cmd;
   wire [1:0] spy_bd_cmd;
   wire [21:0] busint_addr;
   wire [23:0] bd_addr;
   wire [23:0] spy_bd_addr;
   wire [2:0] ms_button;
   wire [31:0] busint_bus;
   wire [31:0] md;
   wire [31:0] sdram_data_in;
   wire [31:0] sdram_data_rc2cpu;
   wire [31:0] vram_cpu_data_in;
   wire [3:0] dots;
   wire [3:0] rc_state;
   wire [48:0] mcr_data_in;
   wire [4:0] eadr;
   wire bd_bsy;
   wire bd_err;
   wire bd_iordy;
   wire bd_rd;
   wire bd_rdy;
   wire bd_start;
   wire bd_wr;
   wire bus_int;
   wire clk50;
   wire cpu_clk;
   wire dbread, dbwrite;
   wire dcm_reset;
   wire halt;
   wire interrupt;
   wire kb_ps2_clk_in;
   wire kb_ps2_data_in;
   wire kb_ready;
   wire loadmd;
   wire lpddr_reset;
   wire memack;
   wire memrq;
   wire ms_ps2_clk_in;
   wire ms_ps2_clk_out;
   wire ms_ps2_data_in;
   wire ms_ps2_data_out;
   wire ms_ps2_dir;
   wire ms_ready;
   wire vga_clk;
   wire vga_clk_locked;
   wire spy_bd_bsy;
   wire spy_bd_err;
   wire spy_bd_iordy;
   wire spy_bd_rd;
   wire spy_bd_rdy;
   wire spy_bd_start;
   wire spy_bd_wr;
   wire sysclk_buf;
   wire vga_reset;
   wire wrcyc;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]		bus_state;		// From uhdl_common of uhdl_common.v
   wire [15:0]		busint_spyout;		// From uhdl_common of uhdl_common.v
   wire [4:0]		disk_state;		// From uhdl_common of uhdl_common.v
   wire			fetch;			// From uhdl_common of uhdl_common.v
   wire [13:0]		mcr_addr;		// From uhdl_common of uhdl_common.v
   wire [48:0]		mcr_data_out;		// From ram_controller of ram_controller.v, ...
   wire			mcr_done;		// From ram_controller of ram_controller.v
   wire			mcr_ready;		// From ram_controller of ram_controller.v
   wire			mcr_write;		// From uhdl_common of uhdl_common.v
   wire			mmc_cs;			// From uhdl_common of uhdl_common.v
   wire			mmc_do;			// From uhdl_common of uhdl_common.v
   wire			mmc_sclk;		// From uhdl_common of uhdl_common.v
   wire			ms_ps2_clk;		// To/From uhdl_common of uhdl_common.v
   wire			ms_ps2_data;		// To/From uhdl_common of uhdl_common.v
   wire			prefetch;		// From uhdl_common of uhdl_common.v
   wire			rs232_txd;		// From uhdl_common of uhdl_common.v
   wire [21:0]		sdram_addr;		// From uhdl_common of uhdl_common.v
   wire [31:0]		sdram_data_cpu2rc;	// From uhdl_common of uhdl_common.v
   wire [31:0]		sdram_data_out;		// From ram_controller of ram_controller.v
   wire			sdram_done;		// From ram_controller of ram_controller.v
   wire			sdram_ready;		// From ram_controller of ram_controller.v
   wire			sdram_req;		// From uhdl_common of uhdl_common.v
   wire			sdram_write;		// From uhdl_common of uhdl_common.v
   wire			spy_rd;			// From uhdl_common of uhdl_common.v
   wire [3:0]		spy_reg;		// From uhdl_common of uhdl_common.v
   wire			spy_wr;			// From uhdl_common of uhdl_common.v
   wire			sram1_ce_n;		// From ram_controller of ram_controller.v
   wire			sram1_lb_n;		// From ram_controller of ram_controller.v
   wire [15:0]		sram1_out;		// From ram_controller of ram_controller.v
   wire			sram1_ub_n;		// From ram_controller of ram_controller.v
   wire			sram2_ce_n;		// From ram_controller of ram_controller.v
   wire			sram2_lb_n;		// From ram_controller of ram_controller.v
   wire [15:0]		sram2_out;		// From ram_controller of ram_controller.v
   wire			sram2_ub_n;		// From ram_controller of ram_controller.v
   wire [17:0]		sram_a;			// From ram_controller of ram_controller.v
   wire			sram_oe_n;		// From ram_controller of ram_controller.v
   wire			sram_we_n;		// From ram_controller of ram_controller.v
   wire			vga_b;			// From uhdl_common of uhdl_common.v
   wire			vga_blank;		// From uhdl_common of uhdl_common.v
   wire			vga_g;			// From uhdl_common of uhdl_common.v
   wire			vga_hsync;		// From uhdl_common of uhdl_common.v
   wire			vga_r;			// From uhdl_common of uhdl_common.v
   wire			vga_vsync;		// From uhdl_common of uhdl_common.v
   wire [14:0]		vram_cpu_addr;		// From uhdl_common of uhdl_common.v
   wire [31:0]		vram_cpu_data_out;	// From ram_controller of ram_controller.v, ...
   wire			vram_cpu_done;		// From ram_controller of ram_controller.v
   wire			vram_cpu_ready;		// From ram_controller of ram_controller.v
   wire			vram_cpu_req;		// From uhdl_common of uhdl_common.v
   wire			vram_cpu_write;		// From uhdl_common of uhdl_common.v
   wire [14:0]		vram_vga_addr;		// From uhdl_common of uhdl_common.v
   wire [31:0]		vram_vga_data_out;	// From ram_controller of ram_controller.v
   wire			vram_vga_ready;		// From ram_controller of ram_controller.v
   wire			vram_vga_req;		// From uhdl_common of uhdl_common.v
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   integer cycles;   
   
   always @(posedge uhdl_common.cpu.clk) begin
      if (uhdl_common.cpu.state == 6'b100000 && ~uhdl_common.cpu.iwrited && ~uhdl_common.cpu.cadr_contrl.inop) begin
	 cycles = cycles + 1;
      end
   end

   assign halt = 0;
   assign eadr = 5'b0;
   assign dbread = 0;
   assign dbwrite = 0;
   assign spyin = 0;
   assign kb_ready = 0;
   assign kb_data = 16'b0;
   assign ms_ready = 0;
   assign ms_x = 12'b0;
   assign ms_y = 12'b0;
   assign ms_button = 3'b0;

   ram_controller ram_controller(/*AUTOINST*/
				 // Outputs
				 .sram1_out		(sram1_out[15:0]),
				 .sram2_out		(sram2_out[15:0]),
				 .sram_a		(sram_a[17:0]),
				 .sdram_data_out	(sdram_data_out[31:0]),
				 .vram_cpu_data_out	(vram_cpu_data_out[31:0]),
				 .vram_vga_data_out	(vram_vga_data_out[31:0]),
				 .mcr_data_out		(mcr_data_out[48:0]),
				 .mcr_done		(mcr_done),
				 .mcr_ready		(mcr_ready),
				 .sdram_done		(sdram_done),
				 .sdram_ready		(sdram_ready),
				 .sram1_ce_n		(sram1_ce_n),
				 .sram1_ub_n		(sram1_ub_n),
				 .sram1_lb_n		(sram1_lb_n),
				 .sram2_ce_n		(sram2_ce_n),
				 .sram2_ub_n		(sram2_ub_n),
				 .sram2_lb_n		(sram2_lb_n),
				 .sram_oe_n		(sram_oe_n),
				 .sram_we_n		(sram_we_n),
				 .vram_cpu_done		(vram_cpu_done),
				 .vram_cpu_ready	(vram_cpu_ready),
				 .vram_vga_ready	(vram_vga_ready),
				 // Inputs
				 .mcr_addr		(mcr_addr[13:0]),
				 .vram_cpu_addr		(vram_cpu_addr[14:0]),
				 .vram_vga_addr		(vram_vga_addr[14:0]),
				 .sram1_in		(sram1_in[15:0]),
				 .sram2_in		(sram2_in[15:0]),
				 .sdram_addr		(sdram_addr[21:0]),
				 .sdram_data_in		(sdram_data_in[31:0]),
				 .vram_cpu_data_in	(vram_cpu_data_in[31:0]),
				 .mcr_data_in		(mcr_data_in[48:0]),
				 .clk			(clk),
				 .cpu_clk		(cpu_clk),
				 .fetch			(fetch),
				 .mcr_write		(mcr_write),
				 .prefetch		(prefetch),
				 .reset			(reset),
				 .sdram_req		(sdram_req),
				 .sdram_write		(sdram_write),
				 .vga_clk		(vga_clk),
				 .vram_cpu_req		(vram_cpu_req),
				 .vram_cpu_write	(vram_cpu_write),
				 .vram_vga_req		(vram_vga_req));

   uhdl_common uhdl_common(/*AUTOINST*/
	   // Outputs
	   .sdram_addr			(sdram_addr[21:0]),
	   .sdram_data_cpu2rc		(sdram_data_cpu2rc[31:0]),
	   .sdram_req			(sdram_req),
	   .sdram_write			(sdram_write),
	   .vram_cpu_addr		(vram_cpu_addr[14:0]),
	   .vram_cpu_data_out		(vram_cpu_data_out[31:0]),
	   .vram_cpu_req		(vram_cpu_req),
	   .vram_cpu_write		(vram_cpu_write),
	   .spy_reg			(spy_reg[3:0]),
	   .busint_spyout		(busint_spyout[15:0]),
	   .spy_rd			(spy_rd),
	   .spy_wr			(spy_wr),
	   .disk_state			(disk_state[4:0]),
	   .bus_state			(bus_state[3:0]),
	   .fetch			(fetch),
	   .prefetch			(prefetch),
	   .mcr_addr			(mcr_addr[13:0]),
	   .mcr_data_out		(mcr_data_out[48:0]),
	   .mcr_write			(mcr_write),
	   .mmc_cs			(mmc_cs),
	   .mmc_do			(mmc_do),
	   .mmc_sclk			(mmc_sclk),
	   .vram_vga_addr		(vram_vga_addr[14:0]),
	   .vram_vga_req		(vram_vga_req),
	   .vga_blank			(vga_blank),
	   .vga_r			(vga_r),
	   .vga_g			(vga_g),
	   .vga_b			(vga_b),
	   .vga_hsync			(vga_hsync),
	   .vga_vsync			(vga_vsync),
	   .rs232_txd			(rs232_txd),
	   // Inouts
	   .ms_ps2_clk			(ms_ps2_clk),
	   .ms_ps2_data			(ms_ps2_data),
	   // Inputs
	   .clk50			(clk50),
	   .reset			(reset),
	   .sdram_data_rc2cpu		(sdram_data_rc2cpu[31:0]),
	   .sdram_done			(sdram_done),
	   .sdram_ready			(sdram_ready),
	   .vram_cpu_data_in		(vram_cpu_data_in[31:0]),
	   .vram_cpu_done		(vram_cpu_done),
	   .vram_cpu_ready		(vram_cpu_ready),
	   .cpu_clk			(cpu_clk),
	   .boot			(boot),
	   .halt			(halt),
	   .interrupt			(interrupt),
	   .mcr_data_in			(mcr_data_in[48:0]),
	   .mcr_ready			(mcr_ready),
	   .mcr_done			(mcr_done),
	   .mmc_di			(mmc_di),
	   .vram_vga_data_out		(vram_vga_data_out[31:0]),
	   .vram_vga_ready		(vram_vga_ready),
	   .vga_clk			(vga_clk),
	   .kb_ps2_clk			(kb_ps2_clk),
	   .kb_ps2_data			(kb_ps2_data),
	   .rs232_rxd			(rs232_rxd));

   vga_dpi vga_dpi
     (
      .vsync(vga_hsync),
      .hsync(vga_vsync),
      .r(vga_red),
      .g(vga_grn),
      .b(vga_blu),
      /*AUTOINST*/
      // Inputs
      .clk				(clk));
   
   mmc_dpi mmc_dpi
     (
      .clk(cpu_clk),
      .mmc_di(mmc_do),
      .mmc_do(mmc_di),
      /*AUTOINST*/
      // Inputs
      .mmc_sclk				(mmc_sclk),
      .mmc_cs				(mmc_cs));

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
