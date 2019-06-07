// ram_controller_lx45.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module ram_controller_A7(/*AUTOARG*/
   // ram
   ddr3_dq, ddr3_dm, ddr3_dqs_p, ddr3_dqs_n, ddr3_addr, ddr3_ba, ddr3_ck_p, 
   ddr3_ck_n, ddr3_cs_n, ddr3_cas_n, ddr3_ras_n, ddr3_cke, ddr3_odt,
   ddr3_reset_n, ddr3_we_n,
   // Outputs
   sdram_data_out, vram_cpu_data_out,
   vram_vga_data_out, mcr_data_out, lpddr_calib_done, lpddr_clk_out,
   mcr_done, mcr_ready, sdram_done, sdram_ready, vram_cpu_done,
   vram_cpu_ready, vram_vga_ready,
   // Inouts
   // Inputs
   mcr_addr, vram_cpu_addr, vram_vga_addr, sdram_addr, sdram_data_in,
   vram_cpu_data_in, mcr_data_in, clk, cpu_clk, fetch, lpddr_reset,
   machrun, mcr_write, prefetch, reset, sdram_req, sdram_write, dram_clk,
   sysclk, vga_clk, vram_cpu_req, vram_cpu_write, vram_vga_req
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
   output wire lpddr_calib_done;
   output wire lpddr_clk_out;
   
   // clock
   output wire ddr3_ck_p;
   output wire ddr3_ck_n;
   output wire ddr3_cke;
   
   /// ram-controller interface
   input [21:0] sdram_addr;
   input [31:0] sdram_data_in;
   output [31:0] sdram_data_out;
   output sdram_done;
   output sdram_ready;
   input wire sdram_req;
   input wire sdram_write;
   input wire dram_clk;

   
   // video ram interface
   input [14:0] vram_cpu_addr;
   input [14:0] vram_vga_addr;
   output [31:0] vram_cpu_data_out;
   output [31:0] vram_vga_data_out;
   input [31:0] vram_cpu_data_in;
   input wire vga_clk;
   input wire vram_cpu_req;
   input wire vram_cpu_write;
   input wire vram_vga_req;
   output wire vram_cpu_done;
   output wire vram_cpu_ready;
   output wire vram_vga_ready;
   
   // microcode interface
   input [13:0] mcr_addr;
   input [48:0] mcr_data_in;
   output [48:0] mcr_data_out;
   input wire mcr_write;
   output wire mcr_done;
   output wire mcr_ready;
   
   // other wires
   input wire clk;
   input wire cpu_clk;
   input wire fetch;
   input wire lpddr_reset;
   input wire machrun;
   input wire prefetch;
   input reset;
   input wire sysclk;
   


   ////////////////////////////////////////////////////////////////////////////////

   parameter [2:0]
     NSD_IDLE = 0,
     NSD_READ = 1,
     NSD_READBSY = 2,
     NSD_READW = 3,
     NSD_WRITE = 4,
     NSD_WRITEBSY = 5,
     NSD_WRITEW = 6;
   parameter [6:0]
     SD_IDLE = 7'b0000001,
     SD_READ = 7'b0000010,
     SD_READBSY = 7'b0000100,
     SD_READW = 7'b0001000,
     SD_WRITE = 7'b0010000,
     SD_WRITEBSY = 7'b0100000,
     SD_WRITEW = 7'b1000000;

   reg [31:0] sdram_out;
   reg [31:0] vram_vga_data;
   reg [3:0] vram_cpu_ready_dly;
   reg [3:0] vram_vga_ready_dly;
   reg [6:0] sdram_state;
   reg int_sdram_done;
   wire int_sdram_ready;
   reg sdram_done;
   reg sdram_ready;

   wire [29:0] lpddr_addr;
   wire [2:0] lpddr_cmd;
   wire [31:0] sdram_resp_in;
   wire [31:0] vram_vga_ram_out;
   wire [6:0] sdram_state_next;
   wire c3_calib_done;
   wire clock;
   wire i_sdram_req;
   wire i_sdram_write;
   wire lpddr_clk;
   wire lpddr_cmd_en;
   wire lpddr_cmd_full;
   wire lpddr_rd_done;
   wire lpddr_rd_empty;
   wire lpddr_rd_rdy;
   wire lpddr_wr_done;
   wire lpddr_wr_full;
   wire lpddr_wr_rdy;
   wire reset;
   wire sys_clk;
   wire sys_rst;
   wire lpddr_wr_en;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset) begin
	sdram_state <= SD_IDLE;
     end else
       sdram_state <= sdram_state_next;

   assign sdram_state_next =
			    (sdram_state[NSD_IDLE] && sdram_req) ? SD_READ :
			    (sdram_state[NSD_IDLE] && sdram_write) ? SD_WRITE :
			    (sdram_state[NSD_READ] && lpddr_rd_rdy) ? SD_READBSY :
			    (sdram_state[NSD_READBSY] && lpddr_rd_done) ? SD_READW :
			    (sdram_state[NSD_READW] && ~sdram_req) ? SD_IDLE :
			    (sdram_state[NSD_WRITE] && lpddr_wr_rdy) ? SD_WRITEBSY :
			    (sdram_state[NSD_WRITEBSY] && lpddr_wr_done) ? SD_WRITEW :
			    (sdram_state[NSD_WRITEW] && ~sdram_write) ? SD_IDLE :
			    sdram_state;
   assign i_sdram_req = sdram_state[NSD_READ];
   assign i_sdram_write = sdram_state[NSD_WRITE];

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	sdram_out <= 32'h0;
	// End of automatics
     end else begin
	if (sdram_state[NSD_READBSY]) begin
	   sdram_out <= sdram_addr[21:17] == 0 ? sdram_resp_in : 32'hffffffff;
	end
     end

   //always @(posedge clk)
     /*if (reset) begin
	/// *AUTORESET* /
	// Beginning of autoreset for uninitialized flops
	int_sdram_ready <= 1'h0;
	// End of automatics
     end else if (sdram_state[NSD_READ])
       int_sdram_ready <= 1'b0;
     else if (sdram_state[NSD_READW])
       int_sdram_ready <= 1'b1;*/

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	int_sdram_done <= 1'h0;
	// End of automatics
     end else if (sdram_state[NSD_WRITE])
       int_sdram_done <= 1'b0;
     else if (sdram_state[NSD_WRITEW])
       int_sdram_done <= 1'b1;

   assign sdram_data_out = sdram_out;

   always @(posedge cpu_clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	sdram_ready <= 1'h0;
	// End of automatics
     end else
       sdram_ready <= int_sdram_ready && sdram_req;

   always @(posedge cpu_clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	sdram_done <= 1'h0;
	// End of automatics
     end else
       sdram_done <= int_sdram_done && sdram_write;

   assign lpddr_cmd = sdram_write ? 3'b000 : 3'b001;
   assign lpddr_addr = { 6'b0, sdram_addr, 2'b0 };
   assign lpddr_cmd_en = (sdram_state[NSD_READ] && sdram_state_next == SD_READBSY) ||
			 (sdram_state[NSD_WRITE] && sdram_state_next == SD_WRITEBSY);
   assign lpddr_rd_rdy = ~lpddr_cmd_full;
   assign lpddr_rd_done = ~lpddr_rd_empty;
   //assign lpddr_wr_rdy = ~lpddr_cmd_full && ~lpddr_wr_full;
   assign lpddr_wr_done = 1'b1;
   assign lpddr_wr_en = sdram_state[NSD_WRITEBSY];
   assign lpddr_clk_out = lpddr_clk;
   assign lpddr_calib_done = c3_calib_done;
  
  wire mm_sysclk;
  
  //BUFG sss(.I(dram_clk), .O(mm_sysclk));

  dram_memif u_ddr_memif
      (
       
       
// Memory interface ports
       .ddr3_addr                      (ddr3_addr),
       .ddr3_ba                        (ddr3_ba),
       .ddr3_cas_n                     (ddr3_cas_n),
       .ddr3_ck_n                      (ddr3_ck_n),
       .ddr3_ck_p                      (ddr3_ck_p),
       .ddr3_cke                       (ddr3_cke),
       .ddr3_ras_n                     (ddr3_ras_n),
       .ddr3_we_n                      (ddr3_we_n),
       .ddr3_dq                        (ddr3_dq),
       .ddr3_dqs_n                     (ddr3_dqs_n),
       .ddr3_dqs_p                     (ddr3_dqs_p),
       .ddr3_reset_n                   (ddr3_reset_n),
       .init_calib_complete            (c3_calib_done),
      
       .ddr3_cs_n                      (ddr3_cs_n),
       .ddr3_dm                        (ddr3_dm),
       .ddr3_odt                       (ddr3_odt),
// Application interface ports
       .app_addr                       (lpddr_addr),
       .app_cmd                        (lpddr_cmd),
       .app_en                         (lpddr_cmd_en),
       .app_wdf_data                   (sdram_data_in),
       .app_wdf_end                    (1'b0),
       .app_wdf_wren                   (lpddr_wr_en),
       .app_rd_data                    (sdram_resp_in),
       .app_rd_data_end                (lpddr_rd_empty),
       //.app_rd_data_valid              (1'b0),
       .app_rdy                        (int_sdram_ready),
       .app_wdf_rdy                    (lpddr_wr_rdy),
       .app_sr_req                     (1'b0),
       .app_ref_req                    (1'b0),
       .app_zq_req                     (1'b0),
       //.app_sr_active                  (1'b0),
       //.app_ref_ack                    (1'b0),
       //.app_zq_ack                     (1'b0),
       //.ui_clk                         (clk),
       //.ui_clk_sync_rst                (lpddr_reset),
       .app_wdf_mask                   (4'b0000),
// System Clock Ports
       .sys_clk_i                      (dram_clk),
       .clk_ref_i                      (dram_clk),
       .sys_rst                        (lpddr_reset)
       );

//   mig_32bit lpddr_intf
//     (
//      .c3_sys_clk(sysclk),
//      .c3_sys_rst_i(lpddr_reset),
//      .c3_clk0(lpddr_clk),
//      .c3_rst0(),
//      .mcb3_dram_dq(mcb3_dram_dq),
//      .mcb3_dram_a(mcb3_dram_a),
//      .mcb3_dram_ba(mcb3_dram_ba),
//      .mcb3_dram_cke(mcb3_dram_cke),
//      .mcb3_dram_ras_n(mcb3_dram_ras_n),
//      .mcb3_dram_cas_n(mcb3_dram_cas_n),
//      .mcb3_dram_we_n(mcb3_dram_we_n),
//      .mcb3_dram_dm(mcb3_dram_dm),
//      .mcb3_dram_udqs(mcb3_dram_udqs),
//      .mcb3_rzq(mcb3_rzq),
//      .mcb3_dram_udm(mcb3_dram_udm),
//      .mcb3_dram_dqs(mcb3_dram_dqs),
//      .mcb3_dram_ck(mcb3_dram_ck),
//      .mcb3_dram_ck_n(mcb3_dram_ck_n),
//      .c3_calib_done(c3_calib_done),
//      .c3_p0_cmd_clk(clk),
//      .c3_p0_cmd_en(lpddr_cmd_en),
//      .c3_p0_cmd_instr(lpddr_cmd),
//      .c3_p0_cmd_bl(6'd0),
//      .c3_p0_cmd_byte_addr(lpddr_addr),
//      .c3_p0_cmd_empty(),
//      .c3_p0_cmd_full(lpddr_cmd_full),
//      .c3_p0_wr_clk(clk),
//      .c3_p0_wr_en(lpddr_wr_en),
//      .c3_p0_wr_mask(4'b0000),
//      .c3_p0_wr_data(sdram_data_in),
//      .c3_p0_wr_full(lpddr_wr_full),
//      .c3_p0_wr_empty(),
//      .c3_p0_wr_count(),
//      .c3_p0_wr_underrun(),
//      .c3_p0_wr_error(),
//      .c3_p0_rd_clk(clk),
//      .c3_p0_rd_en(1'b1),
//      .c3_p0_rd_data(sdram_resp_in),
//      .c3_p0_rd_full(),
//      .c3_p0_rd_empty(lpddr_rd_empty)
//      /*AUTOINST*/);

   wire ena_a = vram_cpu_req | vram_cpu_write;
   wire ena_b = vram_vga_req | 1'b0;

   ise_vram inst
     (
      .clka(cpu_clk),
      .ena(ena_a),
      .wea(vram_cpu_write),
      .addra(vram_cpu_addr),
      .dina(vram_cpu_data_in),
      .douta(vram_cpu_data_out),
      .clkb(vga_clk),
      .enb(ena_b),
      .web(1'b0),
      .addrb(vram_vga_addr),
      .dinb(32'b0),
      .doutb(vram_vga_ram_out)
      /*AUTOINST*/);

   assign vram_vga_data_out = vram_vga_ready ? vram_vga_ram_out : vram_vga_data;

   always @(posedge vga_clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	vram_vga_data <= 32'h0;
	// End of automatics
     end else
       if (vram_vga_ready)
	 vram_vga_data <= vram_vga_ram_out;

   always @(posedge vga_clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	vram_vga_ready_dly <= 4'h0;
	// End of automatics
     end else
       vram_vga_ready_dly <= { vram_vga_ready_dly[2:0], vram_vga_req };

   assign vram_vga_ready = vram_vga_ready_dly[0];
   assign vram_cpu_done = 1'b1;

   always @(posedge cpu_clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	vram_cpu_ready_dly <= 4'h0;
	// End of automatics
     end else
       vram_cpu_ready_dly <= { vram_cpu_ready_dly[2:0], vram_cpu_req };

   assign vram_cpu_ready = vram_cpu_ready_dly[3];
   assign mcr_data_out = 0;
   assign mcr_ready = 0;
   assign mcr_done = 0;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("." "cores/xilinx" "cores/xilinx/mig_32bit/user_design/rtl")
// End:
