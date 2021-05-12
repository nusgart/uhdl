// udhl_common.v --- common top level module for the LM-3
//
// ---!!! Idea is to only have generic code here (PS/2, VGA, ...), for
// ---!!!   the actual top-level module (say for pipistrello); one would need to
// ---!!!   implement:
// ---!!!
// ---!!!	uhdl_pipistrello.v
// ---!!!	support_pipistrello.v
// ---!!!	ram_controller_pipistrello.v
// ---!!!
// ---!!! Intent would be to skip wiring up busint, ps2_support, etc.  Mainly
// ---!!! this module would take input from support_xx.v and
// ---!!! ram_controller_xx.v.  It would be nice to also be able to
// ---!!! controller what kind of hardware we use here, i.e. VGA vs. HDMI.
// ---!!!
// ---!!! Idea for flags to controll design:
// ---!!!
// ---!!!	enable_vga / enable_hdmi (???)
// ---!!!	enable_spy_port
// ---!!!	enable_mmc
// ---!!!	enable_ps2 / enable_usb (???)
// ---!!!	enable_ethernet (???)

`timescale 1ns/1ps
`default_nettype none

module uhdl_common
  (// BUSINT ////////////////////////////////////////////////////////////////////////////////

   // input wire [11:0] ms_x,
   // input wire [11:0] ms_y,
   // input wire [15:0] bd_data_bd2cpu,
   // input wire [15:0] kb_data,
   // input wire [15:0] spy_in,
   // input wire [21:0] busint_addr,
   // input wire [2:0] ms_button,
   // input wire [31:0] md,
   // input wire bd_bsy,
   // input wire bd_err,
   // input wire bd_iordy,
   // input wire bd_rd,
   // input wire bd_rdy,
   // input wire kb_ready,
   // input wire memrq,
   // input wire ms_ready,
   // input wire wrcyc,
   // output wire [15:0] bd_data_cpu2bd,
   // output wire [1:0] bd_cmd,
   // output wire [23:0] bd_addr,
   // output wire [31:0] busint_bus,
   // output wire bd_start,
   // output wire bd_wr,
   // output wire bus_int,
   // output wire loadmd,
   // output wire memack,
   // output wire set_promdisable,

   output wire [21:0] sdram_addr, /// SUPPORT / RC
   output wire [31:0] sdram_data_cpu2rc, /// SUPPORT / RC
   input wire [31:0]  sdram_data_rc2cpu, /// SUPPORT / RC
   input wire	      sdram_done, /// SUPPORT / RC
   input wire	      sdram_ready, /// SUPPORT / RC
   output wire	      sdram_req, /// SUPPORT / RC
   output wire	      sdram_write, /// SUPPORT / RC

   output wire [14:0] vram_cpu_addr, /// SUPPORT / RC
   output wire [31:0] vram_cpu_data_out, /// SUPPORT / RC
   input wire [31:0]  vram_cpu_data_in, /// SUPPORT / RC
   input wire	      vram_cpu_done, /// SUPPORT / RC
   input wire	      vram_cpu_ready, /// SUPPORT / RC
   output wire	      vram_cpu_req, /// SUPPORT / RC
   output wire	      vram_cpu_write, /// SUPPORT / RC

   output wire [3:0]  spy_reg,
   output wire [15:0] busint_spyout,
   output wire	      spy_rd,
   output wire	      spy_wr,

   output wire [4:0]  disk_state,

   // CADR ////////////////////////////////////////////////////////////////////////////////

   // input wire [11:0] bd_state,
   // input wire [15:0] spy_in,
   // input wire [31:0] busint_bus,
   // input wire [4:0] eadr,
   // input wire bus_int,
   // input wire dbread,
   // input wire dbwrite,
   // input wire loadmd,
   // input wire memack,
   // input wire set_promdisable,
   // output wire [15:0] spy_out,
   // output wire [21:8] pma,
   // output wire [31:0] md,
   // output wire [31:0] vma,
   // output wire memrq,
   // output wire wrcyc,

   input wire	      cpu_clk, /// SUPPORT / RC

   // ---!!! BOOT it is an output from support_pipistrello without load.
   // ---!!! HALT and INTERRUPT are hard set to low in support_pipistrello.
   // ---!!! FETCH, PREFETCH is only used by ram_controller.v.
   // ---!!! DISK_STATE_IN is a dangling input?
   // ---!!! PC is a dangling output?

   input wire	      boot, /// SUPPORT / RC
   input wire	      halt, /// SUPPORT / RC
   input wire	      interrupt, /// SUPPORT / RC
   output wire	      fetch,
   output wire	      prefetch, /// SUPPORT / RC

   output wire [13:0] mcr_addr, /// SUPPORT / RC
   output wire [48:0] mcr_data_out, /// SUPPORT / RC
   input wire [48:0]  mcr_data_in, /// SUPPORT / RC
   input wire	      mcr_ready, /// SUPPORT / RC
   input wire	      mcr_done, /// SUPPORT / RC
   output wire	      mcr_write, /// SUPPORT / RC

   // BLOCK DEV ////////////////////////////////////////////////////////////////////////////////

   // input wire [15:0] bd_data_cpu2bd,
   // input wire [1:0] bd_cmd,
   // input wire [23:0] bd_addr,
   // input wire bd_rd,<
   // input wire bd_start,
   // input wire bd_wr,
   // output wire [11:0] bd_state,
   // output wire [15:0] bd_data_bd2cpu,
   // output wire bd_bsy,
   // output wire bd_err,
   // output wire bd_iordy,
   // output wire bd_rdy,

   input wire	      mmc_di,
   output wire	      mmc_cs,
   output wire	      mmc_do,
   output wire	      mmc_sclk,

   // VGA ////////////////////////////////////////////////////////////////////////////////

   output wire [14:0] vram_vga_addr, /// SUPPORT / RC
   input wire [31:0]  vram_vga_data_out, /// SUPPORT / RC
   input wire	      vram_vga_ready, /// SUPPORT / RC
   output wire	      vram_vga_req, /// SUPPORT / RC

   input wire	      vga_clk, /// SUPPORT / RC
   output wire	      vga_blank,

   output wire	      vga_r,
   output wire	      vga_g,
   output wire	      vga_b,
   output wire	      vga_hsync,
   output wire	      vga_vsync,

   // PS/2 ////////////////////////////////////////////////////////////////////////////////

   // output wire [11:0] ms_x,
   // output wire [11:0] ms_x,
   // output wire [15:0] kb_data,
   // output wire [2:0] ms_button,
   // output wire kb_ready,
   // output wire ms_ready,

   input wire	      kb_ps2_clk,
   input wire	      kb_ps2_data,

   inout wire	      ms_ps2_clk,
   inout wire	      ms_ps2_data,

   // SPY ////////////////////////////////////////////////////////////////////////////////

   // input wire [15:0] spy_out,
   // output wire [15:0] spy_in,
   // output wire [4:0] eadr,
   // output wire dbread,
   // output wire dbwrite,

   input wire	      rs232_rxd,
   output wire	      rs232_txd,

   ////////////////////////////////////////////////////////////////////////////////

   output wire [11:0] bdst,
   output wire [13:0] o_pc,
   output wire [25:0] o_lc,
   output wire [23:0] o_bd_addr,
   output wire [5:0] o_bda,
   output wire promdis,
      
   ////////////////////////////////////////////////////////////////////////////////

   input wire	      clk50, /// SUPPORT / RC
   input wire	      reset); /// SUPPORT / RC

   wire [11:0]	      bd_state;
   wire [11:0]	      ms_x, ms_y;
   wire [13:0]	      pc;
   wire [15:0]	      bd_data_bd2cpu;
   wire [15:0]	      bd_data_cpu2bd;
   wire [15:0]	      kb_data;
   wire [15:0]	      spy_bd_data_bd2cpu;
   wire [15:0]	      spy_bd_data_cpu2bd;
   wire [15:0]	      spy_bd_state;
   wire [15:0]	      spy_in;
   wire [15:0]	      spy_out;
   wire [15:0]	      sram1_in;
   wire [15:0]	      sram1_out;
   wire [15:0]	      sram2_in;
   wire [15:0]	      sram2_out;
   wire [1:0]	      bd_cmd;
   wire [1:0]	      spy_bd_cmd;
   wire [21:0]	      busint_addr;
   wire [21:8]	      pma;
   wire [23:0]	      bd_addr;
   wire [23:0]	      spy_bd_addr;
   wire [2:0]	      ms_button;
   wire [31:0]	      busint_bus;
   wire [31:0]	      md;
   wire [31:0]	      vma;
   wire [3:0]	      dots;
   wire [3:0]	      rc_state;
   wire [4:0]	      disk_state_in;
   wire [4:0]	      eadr;
   wire [5:0]	      cpu_state;
   wire		      bd_bsy;
   wire		      bd_err;
   wire		      bd_iordy;
   wire		      bd_rd;
   wire		      bd_rdy;
   wire		      bd_start;
   wire		      bd_wr;
   wire		      bus_int;
   wire		      dbread, dbwrite;
   wire		      kb_ps2_clk_in;
   wire		      kb_ps2_data_in;
   wire		      kb_ready;
   wire		      loadmd;
   wire		      lpddr_reset;
   wire		      memack;
   wire		      memrq;
   wire		      ms_ps2_clk_in;
   wire		      ms_ps2_clk_out;
   wire		      ms_ps2_data_in;
   wire		      ms_ps2_data_out;
   wire		      ms_ps2_dir;
   wire		      ms_ready;
   wire		      vga_clk_locked;
   wire		      spy_bd_bsy;
   wire		      spy_bd_err;
   wire		      spy_bd_iordy;
   wire		      spy_bd_rd;
   wire		      spy_bd_rdy;
   wire		      spy_bd_start;
   wire		      spy_bd_wr;
   wire		      sysclk_buf;
   wire		      vga_reset;
   wire		      wrcyc;
   wire		      set_promdisable;

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
      .ms_ready				(ms_ready),
      .reset				(reset));	  //    input ms_ready;

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
      .o_pc                             (o_pc),
      .o_lc                             (o_lc),
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

`define fenable_mmc
`ifdef fenable_mmc

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
`ifdef genable_mmc

   sd_block_dev mmc_bd
     (
      .clk(cpu_clk),		//    input clk;
      .mmc_clk(clk50),		//    input mmcclk;
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
      .ms_ps2_clk_in			(ms_ps2_clk_in),
      .ms_ps2_data_in			(ms_ps2_data_in),
      .reset				(reset)); //    input ms_ps2_data_in;
`endif

`ifdef enable_spy_port
   spy_port spy_port
     (
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
