// ram_controller.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module ram_controller(/*AUTOARG*/
   // Outputs
   sram1_out, sram2_out, sram_a, sdram_data_out, vram_cpu_data_out,
   vram_vga_data_out, mcr_data_out, mcr_done, mcr_ready, sdram_done,
   sdram_ready, sram1_ce_n, sram1_ub_n, sram1_lb_n, sram2_ce_n,
   sram2_ub_n, sram2_lb_n, sram_oe_n, sram_we_n, vram_cpu_done,
   vram_cpu_ready, vram_vga_ready,
   // Inputs
   mcr_addr, vram_cpu_addr, vram_vga_addr, sram1_in, sram2_in,
   sdram_addr, sdram_data_in, vram_cpu_data_in, mcr_data_in, clk,
   cpu_clk, fetch, mcr_write, prefetch, reset, sdram_req, sdram_write,
   vga_clk, vram_cpu_req, vram_cpu_write, vram_vga_req
   );

   input [13:0] mcr_addr;
   input [14:0] vram_cpu_addr;
   input [14:0] vram_vga_addr;
   input [15:0] sram1_in;
   input [15:0] sram2_in;
   input [21:0] sdram_addr;
   input [31:0] sdram_data_in;
   input [31:0] vram_cpu_data_in;
   input [48:0] mcr_data_in;
   input clk;
   input cpu_clk;
   input fetch;
   input mcr_write;
   input prefetch;
   input reset;
   input sdram_req;
   input sdram_write;
   input vga_clk;
   input vram_cpu_req;
   input vram_cpu_write;
   input vram_vga_req;
   output [15:0] sram1_out;
   output [15:0] sram2_out;
   output [17:0] sram_a;
   output [31:0] sdram_data_out;
   output [31:0] vram_cpu_data_out;
   output [31:0] vram_vga_data_out;
   output [48:0] mcr_data_out;
   output mcr_done;
   output mcr_ready;
   output sdram_done;
   output sdram_ready;
   output sram1_ce_n;
   output sram1_ub_n;
   output sram1_lb_n;
   output sram2_ce_n;
   output sram2_ub_n;
   output sram2_lb_n;
   output sram_oe_n;
   output sram_we_n;
   output vram_cpu_done;
   output vram_cpu_ready;
   output vram_vga_ready;

   ////////////////////////////////////////////////////////////////////////////////

   parameter DRAM_BITS = 17;
   parameter DRAM_SIZE = 131072;
   parameter MCR_RAM_SIZE = 16384;

   reg [10:0] ack_delayed;
   reg [14:0] pending_vram_addr;
   reg [2:0] vram_ack_delayed;
   reg [31:0] dram[DRAM_SIZE-1:0];
   reg [31:0] pending_vram_data;
   reg [31:0] vram[0:21503];
   reg [3:0] mcr_dly;
   reg [48:0] mcr_out;
   reg [48:0] mcr_ram [0:MCR_RAM_SIZE-1];
   reg mcr_ready;
   reg mcr_state;
   reg pending_vram_read;
   reg pending_vram_write;
   reg sdram_was_read;
   reg sdram_was_write;
   reg vram_cpu_done;

   wire [DRAM_BITS-1:0] sdram_addr20;
   wire sdram_start;
   wire sdram_start_read;
   wire sdram_start_write;

   /*AUTOWIRE*/
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   assign mcr_data_out = mcr_out;

   always @(posedge cpu_clk)
     if(reset)
       mcr_state <= 0;
     else
       mcr_state <= mcr_write;

   assign mcr_done = mcr_state;

   always @(posedge cpu_clk)
     if (mcr_write) begin
	mcr_ram[ mcr_addr ] = mcr_data_in;
     end

   always @(posedge cpu_clk)
     if (reset)
       mcr_dly <= 0;
     else
       mcr_dly <= { mcr_dly[2:0], prefetch };

   always @(posedge cpu_clk)
     if (reset) begin
	mcr_out <= 0;
	mcr_ready <= 0;
     end else if (mcr_dly[3]) begin
	mcr_out <= mcr_ram[ mcr_addr ];
	mcr_ready <= 1;
     end else
       mcr_ready <= 0;

   assign sdram_addr20 = sdram_addr[DRAM_BITS-1:0];
   assign sdram_data_out = sdram_addr < DRAM_SIZE ?
			   dram[sdram_addr20] : 32'hffffffff;

   assign sdram_start = ack_delayed == 0;
   assign sdram_start_write = sdram_start && sdram_write;
   assign sdram_start_read = sdram_start && sdram_req;
   assign sdram_done = ack_delayed[1] && sdram_was_write;
   assign sdram_ready = ack_delayed[1] && sdram_was_read;

   always @(posedge cpu_clk)
     if (reset)
       ack_delayed <= 0;
     else begin
	ack_delayed[0] <= sdram_start_read || sdram_start_write;
	ack_delayed[1] <= ack_delayed[0];
	ack_delayed[2] <= ack_delayed[1];
	ack_delayed[3] <= ack_delayed[2];
     end

   always @(posedge cpu_clk) begin
      if (sdram_start_write) begin
	 if (sdram_addr < DRAM_SIZE)
	   dram[sdram_addr20] = sdram_data_in;
	 sdram_was_write = 1;
	 sdram_was_read = 0;
      end

      if (sdram_start_read) begin
	 sdram_was_write = 0;
	 sdram_was_read = 1;
      end
   end

   assign vram_cpu_data_out = vram[vram_cpu_addr];
   assign vram_vga_data_out = vram[vram_vga_addr];
   assign vram_vga_ready = 1;

   always @(posedge cpu_clk)
     if (reset) begin
	pending_vram_addr <= 0;
	pending_vram_data <= 0;
	pending_vram_write <= 0;
	pending_vram_read <= 0;
     end else begin
	if (vram_cpu_write) begin
	   pending_vram_addr <= vram_cpu_addr;
	   pending_vram_data <= vram_cpu_data_in;
	   pending_vram_write <= 1;
	end else if (vram_cpu_done)
	  pending_vram_write <= 0;

	if (vram_cpu_req) begin
	   $display("vram: R addr %o -> %o; %t", vram_cpu_addr, vram[vram_cpu_addr], $time);
	   pending_vram_addr <= vram_cpu_addr;
	   pending_vram_read <= 1;
	end else
	  pending_vram_read <= 0;
     end

   always @(posedge cpu_clk)
     if (reset)
       vram_ack_delayed <= 0;
     else begin
	vram_ack_delayed[0] <= vram_cpu_req;
	vram_ack_delayed[1] <= vram_ack_delayed[0];
	vram_ack_delayed[2] <= vram_ack_delayed[1];
     end

   assign vram_cpu_ready = vram_ack_delayed[2];

   always @(posedge cpu_clk) begin
      vram_cpu_done = 0;
      if (~fetch && ~mcr_state) begin
	 if (pending_vram_write) begin
	    vram[pending_vram_addr] = pending_vram_data;
	    vram_cpu_done = 1;
	    $display("vram: W addr %o <- %o; %t", pending_vram_addr, pending_vram_data, $time);
	 end
      end
   end

   assign sram_a = 0;
   assign sram_oe_n = 1;
   assign sram_we_n = 1;
   assign sram1_out = 0;
   assign sram1_ce_n = 1;
   assign sram1_ub_n = 1;
   assign sram1_lb_n = 1;
   assign sram2_out = 0;
   assign sram2_ce_n = 1;
   assign sram2_ub_n = 1;
   assign sram2_lb_n = 1;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
