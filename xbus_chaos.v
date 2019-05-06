// xbus_chaos.v --- Chaosnet interface

// This section describes the Unibus version of the Chaosnet interface,
// which attaches to pdp11s and Lisp Machines.  The interface contains one
// buffer which holds a received packet and a second buffer which holds a
// packet to be transmitted.  Packets are moved between these buffers and
// the computer under program control.  Direct memory access (DMA) is not
// used; the small gain in performance was not thought to be worth the
// extra hardware complexity.  The usual performance penalty of programmed
// I/O is not incurred since the packet buffers can transfer data at the
// full speed of the computer and neither busy waiting nor multiple
// interrupts are required.
//
//    To transmit a packet, successive 16-bit words of the packet are
// written into the outgoing packet buffer.  First the eight 16-bit words
// of the header should be written, then exactly the number of 16-bit data
// words implied by the byte count in the header.  If the byte count is
// odd, the last 16-bit word will contain the last byte in its low half and
// a garbage padding byte in its high half.  After writing the data words,
// the last 16-bit word to be written is the cable address of the
// destination of the packet, or 0 to broadcast it.  The hardware is then
// told to initiate transmission.  It waits until the cable is not busy and
// this node's turn to transmit arrives, then shifts the packet out onto
// the cable.  At the completion of transmission transmit-done is set and
// the computer is interrupted.  If transmission is aborted by a collision,
// transmit-done and transmit-abort are set and the computer is
// interrupted.  As the packet is written into the outgoing packet buffer,
// a 16-bit cyclic redundancy checksum is computed by the hardware.  This
// checksum is transmitted with the packet and checked by the receiver.
//
//    To receive a packet, the clear-receiver bit is asserted by the
// program.  The next packet on the cable which is addressed to this node,
// or is broadcast, will be stored into the incoming packet buffer.  After
// the packet has been stored, the computer is interrupted.  The packet
// buffer will then not be changed until the next clear-receiver operation
// is performed, giving the computer a chance to read out the packet.  If a
// packet appears on the cable addressed to this node while the incoming
// packet buffer is busy, a collision is simulated so as to abort the
// transmission.  As a packet is stored into the incoming packet buffer,
// the 16-bit cyclic redundancy checksum is checked, and it is checked
// again as the packet is read out of the packet buffer.  This provides
// full checking for errors in the network and in the packet buffers.
//
//    The standard interrupt-vector address for the Chaosnet interface is
// 270.  The standard interrupt priority level is 5.  The standard Unibus
// address is 764140.  These are the device registers:
//
// 764140 Command/Status Register
//      This register contains a number of bits, in the usual pdp11 style.
//      All read/write bits are initialized to zero on power-up.
//      Identified by their masks, these are:
//      1
//           Timer Interrupt Enable (read/write).  Enables interrupts from
//           the interval timer present in some versions of the interface
//           (not described here).
//      2
//           Loop Back (read/write).  If this bit is 1, the cable and
//           transceiver are not used and the interface is looped back to
//           itself.  This is for maintenance.
//      4
//           Spy (read/write).  If this bit is 1, the interface will
//           receive all packets regardless of their destination.  This is
//           for maintenance and network monitoring.
//      10
//           Clear Receiver (write only).  Writing a 1 into this bit clears
//           Receive Done and enables the receiver to receive another
//           packet.
//      20
//           Receive Interrupt Enable (read/write).  If Receive Done and
//           Receive Interrupt Enable are both 1, the computer is
//           interrupted.
//      40
//           Transmit Interrupt Enable (read/write).  If Transmit Done and
//           Transmit Interrupt Enable are both 1, the computer is
//           interrupted.
//      100
//           Transmit Abort (read only).  This bit is 1 if the last
//           transmission was aborted, by a collision or because the
//           receiver was busy.
//      200
//           Transmit Done (read only).  This bit is set to 1 when a
//           transmission is completed or aborted, and cleared to 0 when a
//           word is written into the outgoing packet buffer.
//      400
//           Clear Transmitter (write only).  Writing a 1 into this bit
//           stops the transmitter and sets Transmit Done.  This is for
//           maintenance.
//      17000
//           Lost Count (read only).  These 4 bits contain a count of the
//           number of packets which would have been received if the
//           incoming packet buffer had not been busy.  Setting Clear
//           Receiver resets the lost count to 0.
//      20000
//           Reset (write only).  Writing a 1 into this bit completely
//           resets the interface, just as at power up and Unibus
//           Initialize.
//      40000
//           CRC Error (read only).  If this bit is 1 the receiver's cyclic
//           redundancy checksum indicates an error.  This bit is only
//           valid at two times: when the incoming packet buffer contains a
//           fresh packet, and when the packet has been completely read out
//           of the packet buffer.
//      100000
//           Receive Done (read only).  A 1 in this bit indicates that the
//           incoming packet buffer contains a packet.
//
// 764142 My Address (read)
//      Reading this location returns the network address of this interface
//      (which is contained in a set of DIP switches on the board).
// 764142 Write Buffer (write)
//      Writing this location writes a word into the outgoing packet
//      buffer.  The last word written is the destination address.
// 764144 Read Buffer (read only)
//      Reading this location reads a word from the incoming packet buffer.
//      The last three words read are the destination address, the source
//      address, and the checksum.
// 764146 Bit Count (read only)
//      This location contains the number of bits in the incoming packet
//      buffer, minus one.  After the whole packet has been read out, it
//      will contain 7777 (a 12-bit minus-one).
// 764152 Start Transmission (read only)
//      Reading this location initiates transmission of the packet in the
//      outgoing packet buffer.  The value read is the network address of
//      this interface.  This method for starting transmission may seem
//      strange, but it makes it easier for the hardware to get the source
//      address into the packet.

// CH11 original w ivre names
//
// ABORTDN
// ABORTSIG
// CRCERR
// LOOP.BACK
// LSTCNT[0:3]
// MATCH.ANY.DEST
// MY#[0:7]
// RBCT[11:0]
// RCSR
// RCVR
// RDONE
// RD[15:0]
// RIEN
// RMY#
// RRBTCT
// RRBUF
// TABORTED
// TDONE
// TIEN
// TIMER.IEN

`timescale 1ns/1ps
`default_nettype none

`include "chaos.vh"

module xbus_chaos(/*AUTOARG*/
   // Outputs
   dataout, ack, decode, interrupt,
   // Inputs
   clk, reset, addr, datain, req, write
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

   ////////////////////////////////////////////////////////////////////////////////

   reg csr_timer_interrupt_enable; // read/write
   reg csr_loop_back;		   // read/write
   reg csr_receive_all;		   // read/write
   reg csr_receiver_clear;	   // write only
   reg csr_receive_enable;	   // read/write
   reg csr_transmit_enable;	   // read/write
   reg csr_transmit_abort;	   // read only
   reg csr_transmit_done;	   // read only
   reg csr_transmitter_clear;	   // write only
   reg [3:0] csr_lost_count;	   // read only
   reg csr_reset;		   // write only
   reg csr_crc_error;		   // read only
   reg csr_receive_done;	   // read only

   wire [15:0] chaos_csr;

   reg [15:0] chaos_addr;
   reg [15:0] chaos_bit_count;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]		tdata;			// From tbuf of tbuf.v
   // End of automatics
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [31:0]		dataout;
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   reg trp; 
   reg twp;  		// transmit read/write pulse
   reg [12:0] tbct = 0;
   
   tbuf tbuf(/*AUTOINST*/
	     // Outputs
	     .tdata			(tdata[15:0]),
	     // Inputs
	     .clk			(clk),
	     .reset			(reset),
	     .datain			(datain[15:0]),
	     .tbct			(tbct[7:0]),
	     .trp			(trp),
	     .twp			(twp));

   ////////////////////////////////////////////////////////////////////////////////

   assign chaos_csr = {
		       csr_receive_done,
		       csr_crc_error,
		       csr_reset,
		       csr_lost_count,
		       csr_transmitter_clear,
		       csr_transmit_done,
		       csr_transmit_abort,
		       csr_transmit_enable,
		       csr_receive_enable,
		       csr_receiver_clear,
		       csr_receive_all,
		       csr_loop_back,
		       csr_timer_interrupt_enable
		       };

   task bus_write;
      input [21:0] addr;
      begin
	 csr_receiver_clear = 0;    // w
	 csr_transmitter_clear = 0; // w
	 csr_reset = 0;		    // w

	 /// Why do I need to reset these?
	 csr_transmit_enable = 0;
	 csr_receive_enable = 1;
	 
	 case (addr)
	   22'o17772060: begin // Command/Status Register
	      if (datain[15:0] & `CHAOS_CSR_TIMER_INTERRUPT_ENABLE) begin // read/write
		 $display("setting CHAOS_CSR_TIMER_INTERRUPT_ENABLE (%o)", `CHAOS_CSR_TIMER_INTERRUPT_ENABLE);
	      end

	      if (datain[15:0] & `CHAOS_CSR_LOOP_BACK) begin // read/write
		 $display("setting CHAOS_CSR_LOOP_BACK (%o)", `CHAOS_CSR_LOOP_BACK);
	      end

	      if (datain[15:0] & `CHAOS_CSR_RECEIVE_ALL) begin // read/write
		 $display("setting CHAOS_CSR_RECEIVE_ALL (%o)", `CHAOS_CSR_RECEIVE_ALL);
	      end

	      if (datain[15:0] & `CHAOS_CSR_RECEIVER_CLEAR) begin // write only
		 $display("setting CHAOS_CSR_RECEIVER_CLEAR (%o)", `CHAOS_CSR_RECEIVER_CLEAR);
	      end

	      if (datain[15:0] & `CHAOS_CSR_RECEIVE_ENABLE) begin // read/write
		 $display("setting CHAOS_CSR_RECEIVE_ENABLE (%o)", `CHAOS_CSR_RECEIVE_ENABLE);
		 csr_receive_enable = 1;
	      end

	      if (datain[15:0] & `CHAOS_CSR_TRANSMIT_ENABLE) begin // read/write
		 $display("setting CHAOS_CSR_TRANSMIT_ENABLE (%o)", `CHAOS_CSR_TRANSMIT_ENABLE);
		 csr_transmit_enable = 1;
	      end

	      if (datain[15:0] & `CHAOS_CSR_TRANSMITTER_CLEAR) begin // write only
		 $display("setting CHAOS_CSR_TRANSMITTER_CLEAR (%o)", `CHAOS_CSR_TRANSMITTER_CLEAR);
	      end

	      if (datain[15:0] & `CHAOS_CSR_RESET) begin // write only
		 $display("setting CHAOS_CSR_RESET (%o)", `CHAOS_CSR_RESET);
		 csr_receive_done = 0;
		 csr_transmit_done = 1;
	      end
	   end

	   22'o17772061: begin // Write Buffer
	      twp = 1;
	   end
	 endcase
      end
   endtask
   
   task bus_read;
      input [21:0] addr;
      begin
	 case (addr)
	   22'o17772060: begin // Command/Status Register
	      dataout = { 16'b0, chaos_csr };
	   end
	   22'o17772061: begin // My Address
	      dataout = { 16'b0, chaos_addr };
	   end
	   22'o17772062: begin // Read Buffer
	   end
	   22'o17772063: begin // Bit Count
	      dataout = { 16'b0, chaos_bit_count };
	   end
	   22'o17772065: begin // Start Transmission
	      dataout = { 16'b0, chaos_addr };
	      $display("---!!! transmit xmit buffer");
	   end
	 endcase
      end
   endtask

  always @(posedge clk)
     if (reset) begin
	csr_timer_interrupt_enable = 0;
	csr_loop_back = 0;
	csr_receive_all = 0;
	csr_receiver_clear = 0;
	csr_receive_enable = 0;
	csr_transmit_enable = 0;
	csr_transmit_abort = 0;
	csr_transmit_done = 0;
	csr_transmitter_clear = 0;
	csr_lost_count = 0;
	csr_reset = 0;
	csr_crc_error = 0;
	csr_receive_done = 0;

	chaos_addr = `MY_ADDR;
	chaos_bit_count = 'o07777;

	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dataout = 32'h0;
	twp = 1'h0;
	// End of automatics
     end else begin
	dataout = 0;

	twp = 0;

	if (req & decode) begin
	   if (write) begin
	      bus_write(addr);
	   end else begin
	      bus_read(addr);
	   end
	end
     end

   ////////////////////////////////////////////////////////////////////////////////

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

   assign decode = req & ({addr[21:3], 3'b0} == 22'o17772060);

   assign interrupt = 0;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
