// top_lx45.v --- ---!!!

`timescale 1ns/1ps
//`default_nettype none

`define enable_mmc
`define enable_vga
`define enable_ps2
`define enable_spy_port

module top_lx45(/*AUTOARG*/
   // Outputs
   rs232_txd, led, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, mmc_cs,
   mmc_do, mmc_sclk, mcb3_dram_a, mcb3_dram_ba, mcb3_dram_cke,
   mcb3_dram_ras_n, mcb3_dram_cas_n, mcb3_dram_we_n, mcb3_dram_dm,
   mcb3_dram_udm, mcb3_dram_ck, mcb3_dram_ck_n,
   // Inouts
   ms_ps2_clk, ms_ps2_data, mcb3_dram_dq, mcb3_dram_udqs, mcb3_rzq,
   mcb3_dram_dqs,
   // Inputs
   rs232_rxd, sysclk, kb_ps2_clk, kb_ps2_data, mmc_di, switch
   );
   
   input rs232_rxd;
   output rs232_txd;
   output [3:0] led;
   input sysclk;
   input kb_ps2_clk;
   input kb_ps2_data;
   inout ms_ps2_clk;
   inout ms_ps2_data;
   output vga_hsync;
   output vga_vsync;
   output vga_r;
   output vga_g;
   output vga_b;
   output mmc_cs;
   output mmc_do;
   output mmc_sclk;
   input mmc_di;
   input switch;
   inout [15:0] mcb3_dram_dq;
   output [12:0] mcb3_dram_a;
   output [1:0] mcb3_dram_ba;
   output mcb3_dram_cke;
   output mcb3_dram_ras_n;
   output mcb3_dram_cas_n;
   output mcb3_dram_we_n;
   output mcb3_dram_dm;
   inout mcb3_dram_udqs;
   inout mcb3_rzq;
   output mcb3_dram_udm;
   inout mcb3_dram_dqs;
   output mcb3_dram_ck;
   output mcb3_dram_ck_n;
   
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
   wire			mcr_done;		// From rc of ram_controller_lx45.v
   wire			mcr_ready;		// From rc of ram_controller_lx45.v
   wire			mcr_write;		// From lm3 of lm3.v
   wire			prefetch;		// From lm3 of lm3.v
   wire			reset;			// From support of support_lx45.v
   wire [21:0]		sdram_addr;		// From lm3 of lm3.v
   wire [31:0]		sdram_data_cpu2rc;	// From lm3 of lm3.v
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
   wire			vram_vga_ready;		// From rc of ram_controller_lx45.v
   wire			vram_vga_req;		// From lm3 of lm3.v
   // End of automatics
   
   ////////////////////////////////////////////////////////////////////////////////
  
   BUFG clk50_bufg(.I(sysclk), .O(clk50));
   
   clk_wiz clocking_inst(.CLK_50(clk50), .CLK_VGA(vga_clk), .RESET(dcm_reset), .LOCKED(vga_clk_locked));
   
   initial clkcnt = 0;
   always @(posedge clk50)
     clkcnt <= clkcnt + 4'd1;
   BUFG cpuclk_bufg(.I(clkcnt[0]), .O(cpu_clk));
   
   support_lx45 support
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
   
   ram_controller_lx45 rc
     (
      .lpddr_clk_out(),
      .clk(clk50),
      .mcr_data_out(mcr_data_in),
      .mcr_data_in(mcr_data_out),
      .sdram_data_in(sdram_data_cpu2rc),
      .sdram_data_out(sdram_data_rc2cpu),
      .vram_cpu_data_in(vram_cpu_data_out),
      .vram_cpu_data_out(vram_cpu_data_in),
      /*AUTOINST*/
      // Outputs
      .mcb3_dram_a			(mcb3_dram_a[12:0]),
      .mcb3_dram_ba			(mcb3_dram_ba[1:0]),
      .vram_vga_data_out		(vram_vga_data_out[31:0]),
      .lpddr_calib_done			(lpddr_calib_done),
      .mcb3_dram_cas_n			(mcb3_dram_cas_n),
      .mcb3_dram_ck			(mcb3_dram_ck),
      .mcb3_dram_ck_n			(mcb3_dram_ck_n),
      .mcb3_dram_cke			(mcb3_dram_cke),
      .mcb3_dram_dm			(mcb3_dram_dm),
      .mcb3_dram_ras_n			(mcb3_dram_ras_n),
      .mcb3_dram_udm			(mcb3_dram_udm),
      .mcb3_dram_we_n			(mcb3_dram_we_n),
      .mcr_done				(mcr_done),
      .mcr_ready			(mcr_ready),
      .sdram_done			(sdram_done),
      .sdram_ready			(sdram_ready),
      .vram_cpu_done			(vram_cpu_done),
      .vram_cpu_ready			(vram_cpu_ready),
      .vram_vga_ready			(vram_vga_ready),
      // Inouts
      .mcb3_dram_dq			(mcb3_dram_dq[15:0]),
      .mcb3_dram_dqs			(mcb3_dram_dqs),
      .mcb3_dram_udqs			(mcb3_dram_udqs),
      .mcb3_rzq				(mcb3_rzq),
      // Inputs
      .mcr_addr				(mcr_addr[13:0]),
      .vram_cpu_addr			(vram_cpu_addr[14:0]),
      .vram_vga_addr			(vram_vga_addr[14:0]),
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
      .vga_clk				(vga_clk),
      .vram_cpu_req			(vram_cpu_req),
      .vram_cpu_write			(vram_cpu_write),
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
