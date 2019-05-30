// lm3.v --- common top level module for the LM-3
//
// ---!!! Idea is to only have generic code here (PS/2, VGA, ...), for
// ---!!!   the actual top-level module (say for LX45); one would need to
// ---!!!   implement:
// ---!!!
// ---!!!	top_lx45.v
// ---!!!	support_lx45.v
// ---!!!	ram_controller_lx45.v
// ---!!!
// ---!!! Intent would be to skip wiring up busint, ps2_support, etc.  Mainly
// ---!!! this module would take input from support_xx.v and
// ---!!! ram_controller_xx.v.  It would be nice to also be able to
// ---!!! controller what kind of hardware we use here, i.e. VGA vs. HDMI.
// ---!!!
// ---!!! Idea for flags to controll design:
// ---!!!
// ---!!! 	enable_vga / enable_hdmi (???)
// ---!!! 	enable_spy_port
// ---!!! 	enable_mmc
// ---!!! 	enable_ps2 / enable_usb (???)
// ---!!! 	enable_ethernet (???)
`define enable_vga
`define enable_mmc
`define enable_ps2


`timescale 1ns/1ps
`default_nettype none


module lm3(/*AUTOARG*/
   // Outputs
   sdram_addr, sdram_data_cpu2rc, sdram_req, sdram_write,
   vram_cpu_addr, vram_cpu_data_out, vram_cpu_req, vram_cpu_write,
   spy_reg, busint_spyout, spy_rd, spy_wr, disk_state, fetch,
   prefetch, mcr_addr, mcr_data_out, mcr_write, mmc_cs, mmc_do,
   mmc_sclk, vram_vga_addr, vram_vga_req, vga_blank, vga_r, vga_g,
   vga_b, vga_hsync, vga_vsync, rs232_txd,
   // Inouts
   ms_ps2_clk, ms_ps2_data,
   // Inputs
   clk50, reset, sdram_data_rc2cpu, sdram_done, sdram_ready,
   vram_cpu_data_in, vram_cpu_done, vram_cpu_ready, cpu_clk, boot,
   halt, interrupt, mcr_data_in, mcr_ready, mcr_done, mmc_di,
   vram_vga_data_out, vram_vga_ready, vga_clk, kb_ps2_clk,
   kb_ps2_data, rs232_rxd
   );

   ////////////////////////////////////////////////////////////////////////////////

   input clk50;			/// SUPPORT / RC
   input reset;			/// SUPPORT / RC

   // BUSINT ////////////////////////////////////////////////////////////////////////////////

   // input [11:0] ms_x;
   // input [11:0] ms_y;
   // input [15:0] bd_data_bd2cpu;
   // input [15:0] kb_data;
   // input [15:0] spy_in;
   // input [21:0] busint_addr;
   // input [2:0] ms_button;
   // input [31:0] md;
   // input bd_bsy;
   // input bd_err;
   // input bd_iordy;
   // input bd_rd;
   // input bd_rdy;
   // input kb_ready;
   // input memrq;
   // input ms_ready;
   // input wrcyc;
   // output [15:0] bd_data_cpu2bd;
   // output [1:0] bd_cmd;
   // output [23:0] bd_addr;
   // output [31:0] busint_bus;
   // output bd_start;
   // output bd_wr;
   // output bus_int;
   // output loadmd;
   // output memack;
   // output set_promdisable;

   output [21:0] sdram_addr;	    /// SUPPORT / RC
   output [31:0] sdram_data_cpu2rc; /// SUPPORT / RC
   input [31:0] sdram_data_rc2cpu;  /// SUPPORT / RC
   input sdram_done;		    /// SUPPORT / RC
   input sdram_ready;		    /// SUPPORT / RC
   output sdram_req;		    /// SUPPORT / RC
   output sdram_write;		    /// SUPPORT / RC

   output [14:0] vram_cpu_addr;	    /// SUPPORT / RC
   output [31:0] vram_cpu_data_out; /// SUPPORT / RC
   input [31:0] vram_cpu_data_in;   /// SUPPORT / RC
   input vram_cpu_done;		    /// SUPPORT / RC
   input vram_cpu_ready;	    /// SUPPORT / RC
   output vram_cpu_req;		    /// SUPPORT / RC
   output vram_cpu_write;	    /// SUPPORT / RC

   output [3:0] spy_reg;
   output [15:0] busint_spyout;
   output spy_rd;
   output spy_wr;

   output [4:0] disk_state;

   // CADR ////////////////////////////////////////////////////////////////////////////////

   // input [11:0] bd_state;
   // input [15:0] spy_in;
   // input [31:0] busint_bus;
   // input [4:0] eadr;
   // input bus_int;
   // input dbread;
   // input dbwrite;
   // input loadmd;
   // input memack;
   // input set_promdisable;
   // output [15:0] spy_out;
   // output [21:8] pma;
   // output [31:0] md;
   // output [31:0] vma;
   // output memrq;
   // output wrcyc;

   input cpu_clk;		/// SUPPORT / RC

   // ---!!! BOOT it is an output from support_lx45 without load.
   // ---!!! HALT and INTERRUPT are hard set to low in support_lx45.
   // ---!!! FETCH, PREFETCH is only used by ram_controller.v.
   // ---!!! DISK_STATE_IN is a dangling input?
   // ---!!! PC is a dangling output?
   
   input boot;			/// SUPPORT / RC
   input halt;			/// SUPPORT / RC
   input interrupt;		/// SUPPORT / RC
   output fetch;
   output prefetch;		/// SUPPORT / RC

   output [13:0] mcr_addr;	/// SUPPORT / RC
   output [48:0] mcr_data_out;	/// SUPPORT / RC
   input [48:0] mcr_data_in;	/// SUPPORT / RC
   input mcr_ready;		/// SUPPORT / RC
   input mcr_done;		/// SUPPORT / RC
   output mcr_write;		/// SUPPORT / RC

   // BLOCK DEV ////////////////////////////////////////////////////////////////////////////////

   // input [15:0] bd_data_cpu2bd;
   // input [1:0] bd_cmd;
   // input [23:0] bd_addr;
   // input bd_rd;<
   // input bd_start;
   // input bd_wr;
   // output [11:0] bd_state;
   // output [15:0] bd_data_bd2cpu;
   // output bd_bsy;
   // output bd_err;
   // output bd_iordy;
   // output bd_rdy;

   input wire mmc_di;
   output wire mmc_cs;
   output wire mmc_do;
   output wire mmc_sclk;

   // VGA ////////////////////////////////////////////////////////////////////////////////

   output [14:0] vram_vga_addr;	   /// SUPPORT / RC
   input [31:0] vram_vga_data_out; /// SUPPORT / RC
   input vram_vga_ready;	   /// SUPPORT / RC
   output vram_vga_req;		   /// SUPPORT / RC

   input vga_clk;		/// SUPPORT / RC
   output vga_blank;

   output vga_r;
   output vga_g;
   output vga_b;
   output wire vga_hsync;
   output wire vga_vsync;

   // PS/2 ////////////////////////////////////////////////////////////////////////////////

   // output [11:0] ms_x;
   // output [11:0] ms_x;
   // output [15:0] kb_data;
   // output [2:0] ms_button;
   // output kb_ready;
   // output ms_ready;

   input wire kb_ps2_clk;
   input wire kb_ps2_data;

   inout wire ms_ps2_clk;
   inout wire ms_ps2_data;

   // SPY ////////////////////////////////////////////////////////////////////////////////

   // input [15:0] spy_out;
   // output [15:0] spy_in;
   // output [4:0] eadr;
   // output dbread;
   // output dbwrite;

   input rs232_rxd;
   output rs232_txd;

   ////////////////////////////////////////////////////////////////////////////////

   wire [11:0] bd_state;
   wire [11:0] ms_x, ms_y;
   wire [13:0] mcr_addr;
   wire [13:0] pc;
   wire [14:0] vram_cpu_addr;
   wire [14:0] vram_vga_addr;
   wire [15:0] bd_data_bd2cpu;
   wire [15:0] bd_data_cpu2bd;
   wire [15:0] busint_spyout;
   wire [15:0] kb_data;
   wire [15:0] spy_bd_data_bd2cpu;
   wire [15:0] spy_bd_data_cpu2bd;
   wire [15:0] spy_bd_state;
   wire [15:0] spy_in;
   wire [15:0] spy_out;
   wire [15:0] sram1_in;
   wire [15:0] sram1_out;
   wire [15:0] sram2_in;
   wire [15:0] sram2_out;
   wire [1:0] bd_cmd;
   wire [1:0] spy_bd_cmd;
   wire [21:0] busint_addr;
   wire [21:0] sdram_addr;
   wire [21:8] pma;
   wire [23:0] bd_addr;
   wire [23:0] spy_bd_addr;
   wire [2:0] ms_button;
   wire [31:0] busint_bus;
   wire [31:0] md;
   wire [31:0] sdram_data_cpu2rc;
   wire [31:0] sdram_data_rc2cpu;
   wire [31:0] vma;
   wire [31:0] vram_cpu_data_in;
   wire [31:0] vram_cpu_data_out;
   wire [31:0] vram_vga_data_out;
   wire [3:0] dots;
   wire [3:0] rc_state;
   wire [3:0] spy_reg;
   wire [48:0] mcr_data_in;
   wire [48:0] mcr_data_out;
   wire [4:0] disk_state;
   wire [4:0] disk_state_in;
   wire [4:0] eadr;
   wire [5:0] cpu_state;
   wire bd_bsy;
   wire bd_err;
   wire bd_iordy;
   wire bd_rd;
   wire bd_rdy;
   wire bd_start;
   wire bd_wr;
   wire boot;
   wire bus_int;
   wire clk50;
   wire cpu_clk;
   wire dbread, dbwrite;
   wire dcm_reset;
   wire fetch;
   wire halt;
   wire interrupt;
   wire kb_ps2_clk_in;
   wire kb_ps2_data_in;
   wire kb_ready;
   wire loadmd;
   wire lpddr_reset;
   wire mcr_done;
   wire mcr_ready;
   wire mcr_write;
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
   wire prefetch;
   wire reset;
   wire rs232_rxd, rs232_txd;
   wire sdram_done;
   wire sdram_ready;
   wire sdram_req;
   wire sdram_write;
   wire spy_bd_bsy;
   wire spy_bd_err;
   wire spy_bd_iordy;
   wire spy_bd_rd;
   wire spy_bd_rdy;
   wire spy_bd_start;
   wire spy_bd_wr;
   wire spy_rd;
   wire spy_wr;
   wire sysclk_buf;
   wire vga_r, vga_b, vga_g, vga_blank;
   wire vga_reset;
   wire vram_cpu_done;
   wire vram_cpu_ready;
   wire vram_cpu_req;
   wire vram_cpu_write;
   wire vram_vga_ready;
   wire vram_vga_req;
   wire wrcyc;
   wire set_promdisable;
   
   ////////////////////////////////////////////////////////////////////////////////

   assign busint_addr = {pma, vma[7:0]};

   busint busint
     (
      .clk(cpu_clk),		//    input clk;
      .addr(busint_addr),	//    input [21:0] addr;
      .datain(md),		//    input [31:0] datain;
      .dataout(busint_bus),	//    output [31:0] dataout;
      .spyin(spy_in),		//    input [15:0] spyin;
      .spyout(busint_spyout),	//    output [15:0] spyout;
      .spyreg(spy_reg),		//    output [3:0] spyreg;
      .spyrd(spy_rd),		//    output spyrd;
      .spywr(spy_wr),		//    output spywr;
      .req(memrq),		//    input req;
      .ack(memack),		//    output ack;
      .write(wrcyc),		//    input write;
      .load(loadmd),		//    output load;
      .interrupt(bus_int),	//    output interrupt;
      .sdram_data_in(sdram_data_rc2cpu), //    input [31:0] sdram_data_in;
      .sdram_data_out(sdram_data_cpu2rc), //    output [31:0] sdram_data_out;
      .vram_addr(vram_cpu_addr),	  //    output [14:0] vram_addr;
      .vram_data_in(vram_cpu_data_in),	  //    input [31:0] vram_data_in;
      .vram_data_out(vram_cpu_data_out),  //    output [31:0] vram_data_out;
      .vram_req(vram_cpu_req),		  //    output vram_req;
      .vram_ready(vram_cpu_ready),	  //    input vram_ready;
      .vram_write(vram_cpu_write),	  //    output vram_write;
      .vram_done(vram_cpu_done),	  //    input vram_done;
      .bd_data_in(bd_data_bd2cpu),	  //    input [15:0] bd_data_in;
      .bd_data_out(bd_data_cpu2bd),	  //    output [15:0] bd_data_out;
      .bd_state(bd_state),		  //    input [11:0] bd_state_in;
      .promdisable(set_promdisable),	  //    output promdisable;
      /*AUTOINST*/
      // Outputs
      .sdram_addr			(sdram_addr[21:0]),
      .sdram_req			(sdram_req),
      .sdram_write			(sdram_write),
      .bd_cmd				(bd_cmd[1:0]),
      .bd_addr				(bd_addr[23:0]),
      .bd_rd				(bd_rd),
      .bd_start				(bd_start),
      .bd_wr				(bd_wr),
      .disk_state			(disk_state[4:0]),
      // Inputs
      .reset				(reset),
      .sdram_done			(sdram_done),
      .sdram_ready			(sdram_ready),
      .bd_bsy				(bd_bsy),
      .bd_err				(bd_err),
      .bd_iordy				(bd_iordy),
      .bd_rdy				(bd_rdy),
      .kb_data				(kb_data[15:0]),
      .kb_ready				(kb_ready),
      .ms_x				(ms_x[11:0]),
      .ms_y				(ms_y[11:0]),
      .ms_button			(ms_button[2:0]),
      .ms_ready				(ms_ready));	  //    input ms_ready;

   assign disk_state_in = disk_state;

   cadr cpu
     (
      .clk(cpu_clk),		//    input clk;
      .ext_int(interrupt),	//    input ext_int;
      .ext_reset(reset),	//    input ext_reset;
      .ext_boot(boot),		//    input ext_boot;
      .ext_halt(halt),		//    input ext_halt;
      .bd_state(bd_state),	//    input [11:0] bd_state_in;
      /*AUTOINST*/
      // Outputs
      .spy_out				(spy_out[15:0]),
      .mcr_addr				(mcr_addr[13:0]),
      .mcr_data_out			(mcr_data_out[48:0]),
      .mcr_write			(mcr_write),
      .md				(md[31:0]),
      .memrq				(memrq),
      .wrcyc				(wrcyc),
      .vma				(vma[31:0]),
      .pma				(pma[21:8]),
      // Inputs
      .spy_in				(spy_in[15:0]),
      .dbread				(dbread),
      .dbwrite				(dbwrite),
      .eadr				(eadr[4:0]),
      .mcr_data_in			(mcr_data_in[48:0]),
      .mcr_ready			(mcr_ready),
      .mcr_done				(mcr_done),
      .disk_state_in			(disk_state_in[4:0]),
      .loadmd				(loadmd),
      .busint_bus			(busint_bus[31:0]),
      .bus_int				(bus_int),
      .memack				(memack),
      .set_promdisable			(set_promdisable)); //    input set_promdisable;

`define enable_mmc
`ifdef enable_mmc

   block_dev_mmc mmc_bd
     (
      .clk(cpu_clk),		//    input clk;
      .mmcclk(clk50),		//    input mmcclk;
      .bd_data_in(bd_data_cpu2bd), //    input [15:0] bd_data_in;
      .bd_data_out(bd_data_bd2cpu), //    output [15:0] bd_data_out;
      /*AUTOINST*/
      // Outputs
      .bd_state				(bd_state[11:0]),
      .bd_bsy				(bd_bsy),
      .bd_err				(bd_err),
      .bd_iordy				(bd_iordy),
      .bd_rdy				(bd_rdy),
      .mmc_cs				(mmc_cs),
      .mmc_do				(mmc_do),
      .mmc_sclk				(mmc_sclk),
      // Inputs
      .bd_cmd				(bd_cmd[1:0]),
      .bd_addr				(bd_addr[23:0]),
      .bd_rd				(bd_rd),
      .bd_start				(bd_start),
      .bd_wr				(bd_wr),
      .mmc_di				(mmc_di),
      .reset				(reset));		//    input reset;
`endif

`ifdef enable_vga
   vga_display vga
     (
      .vram_addr(vram_vga_addr), //    output [14:0] vram_addr;
      .vram_data(vram_vga_data_out), //    input [31:0] vram_data;
      .vram_req(vram_vga_req),	     //    output vram_req;
      .vram_ready(vram_vga_ready),   //    input vram_ready;
      /*AUTOINST*/
      // Outputs
      .vga_r				(vga_r),
      .vga_b				(vga_b),
      .vga_g				(vga_g),
      .vga_hsync			(vga_hsync),
      .vga_vsync			(vga_vsync),
      .vga_blank			(vga_blank),
      // Inputs
      .vga_clk				(vga_clk),
      .reset				(reset));
`endif

`ifdef enable_ps2
   assign ms_ps2_clk_in = ms_ps2_clk;
   assign ms_ps2_data_in = ms_ps2_data;
   assign ms_ps2_clk = ms_ps2_dir ? ms_ps2_clk_out : 1'bz;
   assign ms_ps2_data = ms_ps2_dir ? ms_ps2_data_out : 1'bz;

   ps2_support ps2_support
     (
      .clk(cpu_clk),		//    input clk;
      .kb_ps2_clk_in(kb_ps2_clk), //    input kb_ps2_clk_in;
      .kb_ps2_data_in(kb_ps2_data), //    input kb_ps2_data_in;
      /*AUTOINST*/
      // Outputs
      .kb_ready				(kb_ready),
      .kb_data				(kb_data[15:0]),
      .ms_ready				(ms_ready),
      .ms_x				(ms_x[11:0]),
      .ms_y				(ms_y[11:0]),
      .ms_button			(ms_button[2:0]),
      .ms_ps2_clk_out			(ms_ps2_clk_out),
      .ms_ps2_data_out			(ms_ps2_data_out),
      .ms_ps2_dir			(ms_ps2_dir),
      // Inputs
      .reset				(reset),
      .ms_ps2_clk_in			(ms_ps2_clk_in),
      .ms_ps2_data_in			(ms_ps2_data_in)); //    input ms_ps2_data_in;
`endif

`ifdef enable_spy_port
   spy_port spy_port
     (
      .sysclk(clk50),		//    input sysclk;
      .clk(cpu_clk),		//    input clk;
      .spy_in(spy_out),		//    input [15:0] spy_in;
      .spy_out(spy_in),		//    output [15:0] spy_out;
      /*AUTOINST*/
      // Outputs
      .eadr				(eadr[4:0]),
      .dbread				(dbread),
      .dbwrite				(dbwrite),
      .rs232_txd			(rs232_txd),
      // Inputs
      .reset				(reset),
      .rs232_rxd			(rs232_rxd));	//    input rs232_rxd;
`else
//assign rs232_rxd = 1'b0;
assign rs232_txd = 1'b0;
`endif

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
