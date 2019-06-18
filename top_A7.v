// top_lx45.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

`define enable_mmc
`define enable_vga
`define enable_ps2
`define enable_spy_port

module top_A7(/*AUTOARG*/
   // Outputs
   rs232_txd, led, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, mmc_cs,
   mmc_do, mmc_sclk, 
   // Inouts
   ms_ps2_clk, ms_ps2_data,
   // Inputs
   rs232_rxd, sysclk, kb_ps2_clk, kb_ps2_data, mmc_di, switch,
   // RAM interface
   ddr3_dq, ddr3_dm, ddr3_dqs_p, ddr3_dqs_n, ddr3_addr, ddr3_ba, ddr3_ck_p, 
   ddr3_ck_n, ddr3_cs_n, ddr3_cas_n, ddr3_ras_n, ddr3_cke, ddr3_odt,
   ddr3_reset_n, ddr3_we_n
   );
   
   
   /// DDR3 interface
   // data interface
   inout [15:0] ddr3_dq;
   inout [1:0] ddr3_dqs_p;
   inout [1:0] ddr3_dqs_n;
   inout [13:0] ddr3_addr;
   output [1:0] ddr3_dm;
   output wire ddr3_odt;
   
   // command interface
   output [2:0] ddr3_ba; 
   output wire ddr3_cs_n;
   output wire ddr3_cas_n;
   output wire ddr3_ras_n;
   output wire ddr3_we_n;
   
   output wire ddr3_reset_n;
   
   // clock
   output wire ddr3_ck_p;
   output wire ddr3_ck_n;
   output wire ddr3_cke;
   
   input wire rs232_rxd;
   output wire rs232_txd;
   output [3:0] led;
   input wire sysclk;
   input wire kb_ps2_clk;
   input wire kb_ps2_data;
   inout wire ms_ps2_clk;
   inout wire ms_ps2_data;
   output wire vga_hsync;
   output wire vga_vsync;
   output wire vga_r;
   output wire vga_g;
   output wire vga_b;
   output wire mmc_cs;
   output wire mmc_do;
   output wire mmc_sclk;
   input wire mmc_di;
   input wire switch;
   
   ////////////////////////////////////////////////////////////////////////////////
	  
   reg [3:0] clkcnt;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			boot;			// From support of support_lx45.v
   wire [15:0]		busint_spyout;		// From lm3 of lm3.v
   wire			dcm_reset;		// From support of support_lx45.v
   wire [4:0]		disk_state;		// From lm3 of lm3.v
   wire			fetch;			// From lm3 of lm3.v
   wire			halt;			// From support of support_lx45.v
   wire			interrupt;		// From support of support_lx45.v
   wire			lpddr_calib_done;	// From rc of ram_controller_lx45.v
   wire			lpddr_reset;		// From support of support_lx45.v
   wire [13:0]		mcr_addr;		// From lm3 of lm3.v
   wire [48:0]		mcr_data_out;		// From lm3 of lm3.v
	wire [48:0]    mcr_data_in;   // From lm3 of lm3.v
   wire			mcr_done;		// From rc of ram_controller_lx45.v
   wire			mcr_ready;		// From rc of ram_controller_lx45.v
   wire			mcr_write;		// From lm3 of lm3.v
   wire			prefetch;		// From lm3 of lm3.v
   wire			reset;			// From support of support_lx45.v
   wire [21:0]		sdram_addr;		// From lm3 of lm3.v
   wire [31:0]		sdram_data_cpu2rc;	// From lm3 of lm3.v
	wire [31:0]    sdram_data_rc2cpu; // From lm3 of lm3.v
   wire			sdram_done;		// From rc of ram_controller_lx45.v
   wire			sdram_ready;		// From rc of ram_controller_lx45.v
   wire			sdram_req;		// From lm3 of lm3.v
   wire			sdram_write;		// From lm3 of lm3.v
   wire			spy_rd;			// From lm3 of lm3.v
   wire [3:0]		spy_reg;		// From lm3 of lm3.v
   wire			spy_wr;			// From lm3 of lm3.v
   wire			vga_blank;		// From lm3 of lm3.v
   wire [14:0]		vram_cpu_addr;		// From lm3 of lm3.v
   wire [31:0]		vram_cpu_data_out;	// From lm3 of lm3.v
   wire			vram_cpu_done;		// From rc of ram_controller_lx45.v
   wire			vram_cpu_ready;		// From rc of ram_controller_lx45.v
   wire			vram_cpu_req;		// From lm3 of lm3.v
   wire			vram_cpu_write;		// From lm3 of lm3.v
   wire [14:0]		vram_vga_addr;		// From lm3 of lm3.v
   wire [31:0]		vram_vga_data_out;	// From rc of ram_controller_lx45.v
	wire [31:0]    vram_cpu_data_in; // From rc of ram_controller_lx45.v
   wire			vram_vga_ready;		// From rc of ram_controller_lx45.v
   wire			vram_vga_req;		// From lm3 of lm3.v
   
   wire clk_dram;
   // End of automatics
   
   ////////////////////////////////////////////////////////////////////////////////
   wire clk50;
   wire clk_dram_in;
   wire vga_clk;
   wire vga_clk_locked;
   wire cpu_clk;
   wire machrun;
   BUFG clk50_bufg(.I(sysclk), .O(clk50));
   BUFG clkdram_bg(.I(sysclk), .O(clk_dram_in));
   clk_wiz clocking_inst(.CLK_50(clk50), .CLK_VGA(vga_clk), /*.clk_dram(clk_dram),*/ .RESET(dcm_reset), .LOCKED(vga_clk_locked));
   
   clk_wiz_dram clk_inst(.clk_in(clk_dram_in), .clk_dram(clk_dram), .reset(reset));
   
   initial clkcnt = 0;
   always @(posedge clk50)
     clkcnt <= clkcnt + 4'd1;
   BUFG cpuclk_bufg(.I(clkcnt[0]), .O(cpu_clk));
   
   support_A7 support
     (
      .sysclk(clk50),
      .button_r(switch),
      .button_b(1'b0),
      .button_h(1'b0),
      .button_c(1'b0),
      /*AUTOINST*/
      // Outputs
      .boot				(boot),
      .dcm_reset			(dcm_reset),
      .halt				(halt),
      .interrupt			(interrupt),
      .lpddr_reset			(lpddr_reset),
      .reset				(reset),
      // Inputs
      .cpu_clk				(cpu_clk),
      .lpddr_calib_done			(lpddr_calib_done));
   
   ram_controller_A7 rc
     (
      .lpddr_clk_out(),
      .clk                  (clk50),
      .mcr_data_out         (mcr_data_in),
      .mcr_data_in          (mcr_data_out),
      .sdram_data_in        (sdram_data_cpu2rc),
      .sdram_data_out       (sdram_data_rc2cpu),
      .vram_cpu_data_in     (vram_cpu_data_out),
      .vram_cpu_data_out    (vram_cpu_data_in),
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
      // outputs
      .vram_vga_data_out	(vram_vga_data_out[31:0]),
      .lpddr_calib_done		(lpddr_calib_done),
      .mcr_done				(mcr_done),
      .mcr_ready			(mcr_ready),
      .sdram_done			(sdram_done),
      .sdram_ready			(sdram_ready),
      .vram_cpu_done		(vram_cpu_done),
      .vram_cpu_ready		(vram_cpu_ready),
      .vram_vga_ready		(vram_vga_ready),
      // Inputs
      .mcr_addr				(mcr_addr[13:0]),
      .vram_cpu_addr		(vram_cpu_addr[14:0]),
      .vram_vga_addr		(vram_vga_addr[14:0]),
      .sdram_addr			(sdram_addr[21:0]),
      .cpu_clk				(cpu_clk),
      .fetch				(fetch),
      .lpddr_reset			(lpddr_reset),
      .machrun				(machrun),
      .mcr_write			(mcr_write),
      .prefetch				(prefetch),
      .reset				(reset),
      .sdram_req			(sdram_req),
      .sdram_write			(sdram_write),
      .sysclk				(sysclk),
      .dram_clk             (clk_dram),
      .vga_clk				(vga_clk),
      .vram_cpu_req			(vram_cpu_req),
      .vram_cpu_write		(vram_cpu_write),
      .vram_vga_req			(vram_vga_req));
   
   lm3 lm3(/*AUTOINST*/
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
   
   assign led[3] = 1'b0;
   assign led[2] = disk_state[1];
   assign led[1] = disk_state[2];
   assign led[0] = reset;
   
endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
