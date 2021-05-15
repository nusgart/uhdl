// xbus_io.v --- I/O devices (keyboard, mouse, clock, ...)

`timescale 1ns/1ps
`default_nettype none

`include "build_id.vh"

module xbus_io
  (input wire [21:0] addr,
   input wire [31:0] datain,
   input wire 	     req,
   input wire 	     write,
   output reg [31:0] dataout,
   output wire 	     ack,
   output wire 	     decode,
   output wire 	     interrupt,

   input wire 	     ms_ready,
   input wire [11:0] ms_x,
   input wire [11:0] ms_y,
   input wire [2:0]  ms_button,

   input wire 	     kb_ready,
   input wire [15:0] kb_data,

   output wire [7:0] vector,

   input wire 	     clk,
   input wire 	     reset);

   reg [3:0] 	     iob_csr;
   reg [3:0] 	     iob_rdy;

   reg [31:0] 	     iob_key_scan;

   reg [1:0] 	     mouse_rawx;
   reg [11:0] 	     mouse_x;
   reg [11:0] 	     mouse_y;
   reg [1:0] 	     mouse_rawy;
   reg 		     mouse_tail;
   reg 		     mouse_middle;
   reg 		     mouse_head;

   reg 		     hz60_enabled;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		hz60_clk;		// From hz60 of hz60.v
   wire			hz60_clk_fired;		// From hz60 of hz60.v
   wire [31:0]		us_clk;			// From us of us.v
   // End of automatics
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   hz60 hz60(/*AUTOINST*/
	     // Outputs
	     .hz60_clk_fired		(hz60_clk_fired),
	     .hz60_clk			(hz60_clk[31:0]),
	     // Inputs
	     .hz60_enabled		(hz60_enabled),
	     .clk			(clk),
	     .reset			(reset));

   us us(/*AUTOINST*/
	 // Outputs
	 .us_clk			(us_clk[31:0]),
	 // Inputs
	 .clk				(clk),
	 .reset				(reset));

   ////////////////////////////////////////////////////////////////////////////////

   task bus_write;
      input [21:0] addr;
      begin
	 case (addr)
	   22'o17772045: begin
	      iob_csr <= datain[3:0];
	   end
	 endcase
      end
   endtask

   task bus_read;
      input [21:0] addr;
      begin
	 case (addr)
	   22'o17772037: begin
	      dataout = { 16'b0, `BUILD_ID };
	   end
	   22'o17772040: begin
	      dataout = { 16'b0, iob_key_scan[15:0]};
	      iob_rdy[1] <= 0;
	   end
	   22'o17772041: begin
	      dataout = { 16'b0, iob_key_scan[31:16]};
	      iob_rdy[1] <= 0;
	   end
	   22'o17772042: begin
	      dataout = { 17'b0,
			  mouse_head, mouse_middle, mouse_tail,
			  mouse_y };
	      iob_rdy[0] <= 0;
	   end
	   22'o17772043: begin
	      dataout = { 16'b0,
			  mouse_rawy, mouse_rawx,
			  mouse_x };
	   end
	   22'o17772044: begin
	   end
	   22'o17772045:
	     dataout = { 24'b0, iob_rdy, iob_csr };
	   22'o17772050: begin
	      dataout = { 16'b0, us_clk[15:0] };
	   end
	   22'o17772051: begin
	      dataout = { 16'b0, us_clk[31:16] };
	   end
	   22'o17772052: begin
	      dataout = hz60_clk;
	      iob_rdy[2] <= 0;
	      hz60_enabled <= 1;
	   end
	 endcase
      end
   endtask

   wire set_ms_rdy = ms_ready;
   wire set_kb_rdy = kb_ready;
   wire set_clk_rdy = hz60_clk_fired;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dataout = 32'h0;
	iob_rdy <= 4'h0;
	// End of automatics
     end else begin
	dataout = 0;
	if (req & decode) begin
	   if (write) begin
	      bus_write(addr);
	   end else begin
	      bus_read(addr);
	   end
	end else begin
	   if (set_clk_rdy)
	     iob_rdy[2] <= 1;
	   if (set_kb_rdy)
	     iob_rdy[1] <= 1;
	   if (set_ms_rdy)
	     iob_rdy[0] <= 1;
	end
     end

   reg [1:0] ack_delayed;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	ack_delayed <= 2'h0;
	// End of automatics
     end else begin
	ack_delayed[0] <= decode;
	ack_delayed[1] <= ack_delayed[0];
     end
   assign ack = ack_delayed[1];


   wire in_iob;
   wire addr_match;

   assign in_iob = {addr[21:6], 6'b0} == 22'o17772000 ? 1'b1 : 1'b0;
   assign addr_match = in_iob;
   assign decode = req & addr_match;

   wire ms_int = iob_rdy[0] & iob_csr[1];
   wire kb_int = iob_rdy[1];
   wire clk_int = iob_rdy[2] & iob_csr[3];

   assign interrupt = kb_int | ms_int | clk_int;

   ////////////////////////////////////////////////////////////////////////////////
   // Keyboard

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	iob_key_scan <= 32'h0;
	// End of automatics
     end else if (kb_ready)
       iob_key_scan <= { 8'b0, 5'b11111, 3'b001, kb_data };

   ////////////////////////////////////////////////////////////////////////////////
   // Mouse

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	mouse_head <= 1'h0;
	mouse_middle <= 1'h0;
	mouse_tail <= 1'h0;
	mouse_x <= 12'h0;
	mouse_y <= 12'h0;
	// End of automatics
	mouse_head <= 0;
     end else if (ms_ready) begin
	mouse_x <= ms_x;
	mouse_y <= ms_y;
	mouse_head <= ms_button[2];
	mouse_middle <= ms_button[1];
	mouse_tail <= ms_button[0];
     end

   ////////////////////////////////////////////////////////////////////////////////

   assign vector =
		  (ms_int || kb_int) ? 8'o260 :
		  clk_int ? 8'o274 :
		  8'b0;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("." "cores")
// End:
