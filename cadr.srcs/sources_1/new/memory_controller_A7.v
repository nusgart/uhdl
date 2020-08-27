`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nicholas Nusgart
// 
// Create Date: 07/21/2019 02:53:29 PM
// Design Name: LM-3 CADR implementation
// Module Name: memory_controller_A7
// Project Name: LM-3
// Target Devices: Artix 7 XC7A35t
// Tool Versions: Vivado 2018.3, MIG v4.2
// Description: 
//   Controls memory interfaces for the Artix-7.  In particular, this acts as
// the CPU-DDR3 SDRAM interface and as the VRAM interface.
//
// Dependencies: 
// dram_memif, ise_VRAM
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module memory_controller_A7(
  /// DDR3 interface
  // data interface
  inout wire [15:0] ddr3_dq,
  inout wire [1:0] ddr3_dqs_p,
  inout wire [1:0] ddr3_dqs_n,
  inout wire [13:0] ddr3_addr,
  output wire [1:0] ddr3_dm,
  output wire ddr3_odt,
  
  // command interface
  output wire [2:0] ddr3_ba, 
  output wire ddr3_cs_n,
  output wire ddr3_cas_n,
  output wire ddr3_ras_n,
  output wire ddr3_we_n,
  output wire ddr3_reset_n,
   
  // clock
  output wire ddr3_ck_p,
  output wire ddr3_ck_n,
  output wire ddr3_cke,
   
  /// CPU Interface
  input wire sdram_clk,
  input wire ref_clk,
  input wire vga_clk,
  input wire cpu_clk,
  input wire fetch,
  
  input wire machrun,
  input wire prefetch,
  input wire reset,
  // SDRAM
  input wire [21:0] sdram_addr,
  input wire [31:0] sdram_data_in,
  output reg [31:0] sdram_data_out,
  output wire sdram_done,
  output wire sdram_ready,
  input wire sdram_req,
  input wire sdram_write,
  input wire sdram_reset,
  output wire sdram_calib_done,
  output wire sdram_clk_out,
  
  // VGA
  input wire [14:0] vram_cpu_addr,
  input wire [14:0] vram_vga_addr,
  output wire [31:0] vram_cpu_data_out,
  output wire [31:0] vram_vga_data_out,
  input wire [31:0] vram_cpu_data_in,
  input wire vram_cpu_req,
  input wire vram_cpu_write,
  input wire vram_vga_req,
  output wire vram_cpu_done,
  output wire vram_cpu_ready,
  output wire vram_vga_ready,
  
  // microcode
  // microcode interface
  input wire [13:0] mcr_addr,
  input wire [48:0] mcr_data_in,
  output wire [48:0] mcr_data_out,
  input wire mcr_write,
  output wire mcr_done,
  output wire mcr_ready
  );
  /*
  input wire sdram_req;
   input wire sdram_write;
   input wire dram_clk;
   input wire ref_clk;*/
   
  /// VRAM
  assign vram_cpu_ready = 1'b1;
  assign vram_vga_ready = 1'b1;
  assign vram_cpu_done  = 1'b1; 
  wire ena_a = vram_cpu_req | vram_cpu_write;
  wire ena_b = vram_vga_req | 1'b0;
  ise_vram inst (
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
    .doutb(vram_vga_data_out)
  );
 /// microcode not implemented
 assign mcr_data_out = 0;
 assign mcr_ready = 0;
 assign mcr_done = 0;
 
 /// sdram: the main portion
 // ddr interface
 wire ui_clk;
 wire ui_clk_sync_rst;
 // reset logic
 reg rs0;
 reg [15:0] reset_ctr;
 always @(posedge sdram_clk) begin
    if (sdram_reset) begin
      rs0 <= 1'b1;
    end else if (rs0) begin
      rs0 <= 1'b0;
      reset_ctr <= 16'd65535;
    end else if (reset_ctr != 16'b0) begin
      reset_ctr <= reset_ctr - 1;
    end
  end
 
 wire sys_rst = (reset_ctr == 0);
 
 
 // wires
 wire init_calib_complete;
 assign sdram_calib_done = init_calib_complete;
 
 reg [27:0] app_addr;
 reg [2:0] app_cmd;
 reg app_en;
 wire app_rdy;
 wire app_wdf_rdy;
 
 reg [127:0] app_wdf_data;
 reg app_wdf_wren;
 wire app_wdf_end = 1;
 wire [127:0] app_rd_data;
 wire app_rd_data_end;
 wire app_rd_data_valid;
 
 
 wire app_sr_req = 0;
 wire app_sr_active;
 wire app_zq_req = 0;
 wire app_zq_ack;
 wire app_ref_req = 0;
 wire app_ref_ack;
 
 // SDRAM controller states
 localparam INIT = 3'd0;
 localparam IDLE = 3'd1;
 localparam WRITE = 3'd2;
 localparam WRITE_SEND = 3'd3;
 localparam WRITE_DONE = 3'd4;
 localparam READ = 3'd5;
 localparam READ_DONE = 3'd6;
 localparam WAIT = 3'd7;
 // Interface Commmands
 localparam CMD_WRITE = 3'b000;
 localparam CMD_READ = 3'b001;
 
 reg [2:0] state;
 
 // cpu interface
 reg [31:0] cpu_data_in;
 reg [31:0] cpu_data_out;
 reg [21:0] cpu_addr;
 
 reg [27:0] local_addr;
 reg [31:0] local_data_in;
 reg [31:0] local_data_out;
 reg local_req;
 reg local_write;
 reg local_done;
 
 reg dram_write_done;
 reg dram_read_done;
 
 //assign sdram_ready = (state == IDLE);
 assign sdram_clk_out = ui_clk;
 
 reg cpu_req;
 reg cpu_write;
 reg cpu_done;
 
 assign sdram_done = cpu_done;
 assign sdram_ready = dram_read_done;
 
 `ifdef SEP_CLOCKS
 // metastability avoidance
 // Needs work
 always @ (posedge ui_clk) begin
   cpu_req <= sdram_req;
   local_req <= cpu_req;
   //
   cpu_write <= sdram_write;
   local_write <= cpu_write;
   // addr
   cpu_addr <= sdram_addr;
   local_addr <= {5'b0, cpu_addr, 1'b0};
   // data in
   cpu_data_in <= sdram_data_in;
   local_data_in <= cpu_data_in;
   // data out
   cpu_data_out <= local_data_out;
   sdram_data_out <= cpu_data_out;
   // dram done
   local_done <= dram_done;
   cpu_done <= local_done;
 end
 `else
 always @(*) begin
   local_req = sdram_req;
   local_write = sdram_write;
   local_addr = {2'b0, sdram_addr, 3'b0};
   local_data_in = sdram_data_in;
   sdram_data_out = local_data_out;
   cpu_done = dram_write_done;
 end
 `endif
 
 always @ (posedge ui_clk) begin
   if (ui_clk_sync_rst) begin
     state <= INIT;
     app_en <= 0;
     app_wdf_wren <= 0;
     dram_write_done <= 0;
     dram_read_done <= 0;
   end else begin
     case (state)
       INIT: begin
         if (init_calib_complete) begin
           state <= IDLE;
         end
       end
       IDLE: begin
         // todo controller logic
         dram_write_done <= 0;
         dram_read_done <= 0;
         if (local_req) begin
           state <= READ;
         end else if (local_write) begin
           state <= WRITE;
         end
       end
       WRITE: begin
         /*app_wdf_wren <= 1;
         app_addr <= local_addr;
         app_cmd <= CMD_WRITE;
         app_wdf_data[31:0] <= local_data_in[31:0];
         
         if (app_wdf_rdy) begin
           state <= WRITE_SEND;
         end*/
         if (app_rdy & app_wdf_rdy) begin
           app_en <= 1;
           app_wdf_wren <= 1;
           app_addr <= local_addr;
           app_cmd <= CMD_WRITE;
           app_wdf_data[31:0] <= local_data_in[31:0];
           state <= WRITE_DONE;
         end
       end
       WRITE_DONE: begin
        if (app_rdy & app_en) begin
          app_en <= 0;
        end

        if (app_wdf_rdy & app_wdf_wren) begin
          app_wdf_wren <= 0;
        end

        if (~app_en & ~app_wdf_wren) begin
          state <= WAIT;
          dram_write_done <= 1;
        end
       end
       READ: begin
       if (app_rdy) begin
          app_en <= 1;
          app_addr <= local_addr;
          app_cmd <= CMD_READ;
          state <= READ_DONE;
        end
       end
       READ_DONE: begin
         // prevent double-reading RAM side
         if (app_rdy & app_en) begin
           app_en <= 0;
         end
         // read out data
         if (app_rd_data_valid) begin
           local_data_out <= app_rd_data[31:0];
           state <= WAIT;
           dram_read_done <= 1;
        end
       end
       WAIT: begin
         // prevent double-opearation CPU side
         if (~local_req && ~local_write) begin
           state <= IDLE;
         end
       end
       // invalid state --> go to idle state
       default: state <= IDLE;
     endcase
   end
 end
 
 dram_memif u_dram_memif (

    // Memory interface ports
    .ddr3_addr                      (ddr3_addr),  // output [13:0]		ddr3_addr
    .ddr3_ba                        (ddr3_ba),  // output [2:0]		ddr3_ba
    .ddr3_cas_n                     (ddr3_cas_n),  // output			ddr3_cas_n
    .ddr3_ck_n                      (ddr3_ck_n),  // output [0:0]		ddr3_ck_n
    .ddr3_ck_p                      (ddr3_ck_p),  // output [0:0]		ddr3_ck_p
    .ddr3_cke                       (ddr3_cke),  // output [0:0]		ddr3_cke
    .ddr3_ras_n                     (ddr3_ras_n),  // output			ddr3_ras_n
    .ddr3_reset_n                   (ddr3_reset_n),  // output			ddr3_reset_n
    .ddr3_we_n                      (ddr3_we_n),  // output			ddr3_we_n
    .ddr3_dq                        (ddr3_dq),  // inout [15:0]		ddr3_dq
    .ddr3_dqs_n                     (ddr3_dqs_n),  // inout [1:0]		ddr3_dqs_n
    .ddr3_dqs_p                     (ddr3_dqs_p),  // inout [1:0]		ddr3_dqs_p
    .init_calib_complete            (init_calib_complete),  // output			init_calib_complete
      
    .ddr3_cs_n                      (ddr3_cs_n),  // output [0:0]		ddr3_cs_n
    .ddr3_dm                        (ddr3_dm),  // output [1:0]		ddr3_dm
    .ddr3_odt                       (ddr3_odt),  // output [0:0]		ddr3_odt
    // Application interface ports
    .app_addr                       (app_addr),  // input [27:0]		app_addr
    .app_cmd                        (app_cmd),  // input [2:0]		app_cmd
    .app_en                         (app_en),  // input				app_en
    .app_wdf_data                   (app_wdf_data),  // input [127:0]		app_wdf_data
    .app_wdf_end                    (app_wdf_end),  // input				app_wdf_end
    .app_wdf_wren                   (app_wdf_wren),  // input				app_wdf_wren
    .app_rd_data                    (app_rd_data),  // output [127:0]		app_rd_data
    .app_rd_data_end                (app_rd_data_end),  // output			app_rd_data_end
    .app_rd_data_valid              (app_rd_data_valid),  // output			app_rd_data_valid
    .app_rdy                        (app_rdy),  // output			app_rdy
    .app_wdf_rdy                    (app_wdf_rdy),  // output			app_wdf_rdy
    .app_sr_req                     (app_sr_req),  // input			app_sr_req
    .app_ref_req                    (app_ref_req),  // input			app_ref_req
    .app_zq_req                     (app_zq_req),  // input			app_zq_req
    .app_sr_active                  (app_sr_active),  // output			app_sr_active
    .app_ref_ack                    (app_ref_ack),  // output			app_ref_ack
    .app_zq_ack                     (app_zq_ack),  // output			app_zq_ack
    .ui_clk                         (ui_clk),  // output			ui_clk
    .ui_clk_sync_rst                (ui_clk_sync_rst),  // output			ui_clk_sync_rst
    //.app_wdf_mask                   (15'b0000000000001111),  // input [15:0]		app_wdf_mask
    .app_wdf_mask                     (16'b1111111111110000),  // input [15:0]		app_wdf_mask
    // System Clock Ports
    .sys_clk_i                       (sdram_clk),
    // Reference Clock Ports
    .clk_ref_i                      (ref_clk),
    .sys_rst                        (sys_rst) // input sys_rst
    );
endmodule
`default_nettype wire