// xbus_tv.v --- VRAM interface 

`timescale 1ns/1ps
`default_nettype none

module xbus_tv(/*AUTOARG*/
   // Outputs
   dataout, ack, decode, interrupt, vram_addr, vram_data_out,
   vram_req, vram_write,
   // Inputs
   clk, reset, addr, datain, req, write, vram_data_in, vram_done,
   vram_ready
   );

   input clk;
   input reset;

   input [21:0] addr;
   input [31:0] datain;
   input req;
   input write;
   output [31:0] dataout;
   output ack;
   output decode;
   output interrupt;

   output [14:0] vram_addr;
   input [31:0] vram_data_in;
   output [31:0] vram_data_out;
   input vram_done;
   input vram_ready;
   output vram_req;
   output vram_write;

   ////////////////////////////////////////////////////////////////////////////////

   reg clear_tv_int;
   reg set_tv_int;
   reg tv_int;
   reg tv_int_en;

   wire fb_read_req;
   wire fb_write_req;

   wire in_color;
   wire in_fb;
   wire in_reg;
   wire start_fb_read;
   wire start_fb_write;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			hz60_clk_fired;		// From hz60 of hz60.v
   // End of automatics
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [31:0]		dataout;
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   hz60 hz60(
	     .hz60_clk(),
	     .hz60_enabled(1'b1),
	     /*AUTOINST*/
	     // Outputs
	     .hz60_clk_fired		(hz60_clk_fired),
	     // Inputs
	     .clk			(clk),
	     .reset			(reset));

   ////////////////////////////////////////////////////////////////////////////////
   // State machine to wait for memory controller

   parameter
     IDLE = 3'd0,
     WRITE = 3'd1,
     READ = 3'd2,
     DONE = 3'd3;

   wire [2:0] state_ns;
   reg [2:0] state;

   always @(posedge clk)
     if (reset)
       state <= IDLE;
     else
       state <= state_ns;

   assign state_ns =
		    (state == IDLE && start_fb_write) ? WRITE :
		    (state == IDLE && start_fb_read) ? READ :
		    (state == WRITE && vram_done) ? DONE :
		    (state == READ && vram_ready) ? DONE :
		    (state == DONE && ~req) ? IDLE :
		    state;

   ////////////////////////////////////////////////////////////////////////////////

   // While CPU is requesting ...
   assign fb_write_req = req && decode && write;
   assign fb_read_req  = req && decode && ~write;
   // ... read/write pulse to memory controller.
   assign start_fb_write = fb_write_req && in_fb;
   assign start_fb_read  = fb_read_req  && in_fb;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	set_tv_int = 1'h0;
	// End of automatics
     end else begin
	set_tv_int = 0;

	if (hz60_clk_fired)
	  set_tv_int = 1;
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	tv_int <= 1'h0;
	// End of automatics
     end else if (set_tv_int) begin
	tv_int <= 1'b1;
     end else if (clear_tv_int) begin
	tv_int <= 1'b0;
     end

   ////////////////////////////////////////////////////////////////////////////////

   assign in_fb    = {addr[21:15], 15'b0} == 22'o17000000;
   assign in_color = {addr[21:15], 15'b0} == 22'o17200000;
   assign in_reg   = {addr[21:3],   3'b0} == 22'o17377760;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	clear_tv_int = 1'h0;
	dataout <= 32'h0;
	tv_int_en <= 1'h0;
	// End of automatics
     end else begin
	clear_tv_int = 0;

	if (fb_write_req && in_reg) begin
	   // Bit 3 is interrupt enable, bit 4 is interrupt flag.
	   tv_int_en <= datain[3];
	   if (datain[4])
	     clear_tv_int = 1;
	end else if (fb_read_req && in_reg) begin
	   dataout <= { 27'b0, tv_int, tv_int_en, 3'b0 };
	end else if (in_color) begin
	   dataout <= 32'h0;
	end else if (vram_ready) begin
	   dataout <= vram_data_in;
	end
     end

   assign ack = state == DONE;

   // ---!!! Need to respond to "color probe" even if we're B&W.
   assign decode = in_reg || in_fb /* || in_color */;

   assign interrupt = tv_int_en & tv_int;

   ////////////////////////////////////////////////////////////////////////////////
   // Output to memory controller

   wire [14:0] offset;

   assign offset = addr[14:0];

   assign vram_addr     = offset;
   assign vram_data_out = datain;
   assign vram_req      = state == READ;
   assign vram_write    = state == WRITE;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:

