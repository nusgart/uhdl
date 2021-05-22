// xbus_unibus.v --- diagnostics interface

`timescale 1ns/1ps
`default_nettype none

module xbus_unibus (
  input wire [21:0] addr,
   input wire [31:0] datain,
   input wire	     req,
   input wire	     write,
   output reg [31:0] dataout,
   output wire	     ack,
   output wire	     decode,
   output wire	     interrupt,

   input wire	     timedout,
   output reg	     promdisable,

   input wire	     clk,
   input wire	     reset);

   ////////////////////////////////////////////////////////////////////////////////
   // Unibus & XBUS NXM

   reg		     unibus_nxm = 1'b0;
   reg		     xbus_nxm = 1'b0;

   reg		     clear_bus_status = 1'b0;

   always @(posedge clk)
     if (timedout) begin
	if (addr > 22'o17400000)
	  unibus_nxm <= 1'b1;
	else if (addr > 22'o17000000)
	  xbus_nxm <= 1'b1;
     end else if (clear_bus_status) begin
	unibus_nxm <= 1'b0;
	xbus_nxm <= 1'b0;
     end

   ////////////////////////////////////////////////////////////////////////////////
   // Bus interrupts

   reg       unibus_int = 1'b0;
   reg [7:0] unibus_vector = 8'b0;
   reg	     xbus_int = 1'b0;		// ---!!! Not used?

   reg	     unibus_int_en = 1'b0;
   reg	     clear_unibus_int_en = 1'b0;
   reg	     set_unibus_int_en = 1'b0;

   reg	     clear_bus_ints = 1'b0;

   always @(posedge clk) begin
      if (clear_bus_ints) begin
	 unibus_int <= 1'b0;
	 unibus_vector <= 8'b0;
      end

      if (set_unibus_int_en)
	unibus_int_en <= 1'b1;

      if (clear_unibus_int_en)
	unibus_int_en <= 1'b1;
   end

   ////////////////////////////////////////////////////////////////////////////////

   task bus_write;
      input [21:0] addr;
      begin
	 case (addr)
	   22'o17773005: begin
	      if (datain[5] && datain[2] && ~datain[0])
		promdisable = 1;
	   end
	   22'o17773020: begin
	      if (datain[10])
		set_unibus_int_en = 1;
	      else
		clear_unibus_int_en = 1;
	      clear_bus_ints = 1;
	   end
	   22'o17773022:
	     clear_bus_status = 1;
	 endcase
      end
   endtask

   task bus_read;
      input [21:0] addr;
      begin
	 case (addr)
	   22'o17773020:
	     dataout = { 14'b0,
			 2'b0, unibus_int,
			 xbus_int, 2'b0,
			 1'b0, unibus_int_en, unibus_vector, 2'b0 };
	   22'o17773022:
	     dataout = { 28'b0, unibus_nxm, 2'b0, xbus_nxm };
	 endcase
      end
   endtask

   wire in_unibus, decode_unibus;
   wire in_other, decode_other;

   assign in_unibus = ({addr[21:6], 6'b0} == 22'o17773000);
   assign decode_unibus = req & in_unibus;

   // ---!!! Not used?
   assign in_other = ({addr[21:6], 6'b0} == 22'o17777700) |
		     ({addr[21:12], 12'b0} == 22'o17740000);
   assign decode_other = req & in_other;

   always @(posedge clk) begin
      promdisable = 0;
      clear_bus_status = 0;
      clear_bus_ints = 0;
      set_unibus_int_en = 0;
      clear_unibus_int_en = 0;
      dataout = 0;

      if (decode_unibus) begin
	 if (write) begin
	    bus_write(addr);
	 end else begin
	    bus_read(addr);
	 end
      end

      // ---!!! Not used?
      if (decode_other)
	if (write) begin
	   // Nothing.
	end else begin
	   dataout = 0;
	end
   end

   reg [1:0] ack_delayed = 0;

   always @(posedge clk) begin
      ack_delayed[0] <= decode;
      ack_delayed[1] <= ack_delayed[0];
   end

   assign ack = ack_delayed[1];
   assign decode = decode_unibus || decode_other;
   assign interrupt = 0;	// ---!!! Not used?

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
