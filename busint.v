// busint.v --- bus interface
//
// Bus interface:
//	input [21:0] addr;	/* request address */
//	input [31:0] datain;	/* request data */
//	input req;		/* request */
//	input write;		/* request read#/write */
//	input timeout;
//	output [31:0] dataout;
//	output ack;		/* request done */
//	output decode;		/* request addr ok */
//	output interrupt;

`timescale 1ns/1ps
`default_nettype none

module busint(/*AUTOARG*/
   // Outputs
   dataout, ack, load, interrupt, sdram_addr, sdram_data_out,
   sdram_req, sdram_write, bd_data_out, bd_cmd, bd_addr, bd_rd,
   bd_start, bd_wr, disk_state, vram_addr, vram_data_out, vram_req,
   vram_write, promdisable, spyout, spyrd, spywr, spyreg,
   // Inputs
   clk, reset, addr, datain, req, write, sdram_data_in, sdram_done,
   sdram_ready, bd_state, bd_data_in, bd_bsy, bd_err, bd_iordy,
   bd_rdy, vram_data_in, vram_done, vram_ready, kb_data, kb_ready,
   ms_x, ms_y, ms_button, ms_ready, spyin
   );

   input wire clk;
   input wire reset;

   input [21:0] addr;
   input [31:0] datain;
   input wire req;
   input wire write;
   output [31:0] dataout;
   output wire ack;
   output wire load;
   output wire interrupt;

   // ---!!! //////////////////////////////////////////////////////////////////////

   input [31:0] sdram_data_in;
   input wire sdram_done;
   input wire sdram_ready;
   output [21:0] sdram_addr;
   output [31:0] sdram_data_out;
   output wire sdram_req;
   output wire sdram_write;

   // ---!!! //////////////////////////////////////////////////////////////////////

   input [11:0] bd_state;
   input [15:0] bd_data_in;
   input wire bd_bsy;
   input wire bd_err;
   input wire bd_iordy;
   input wire bd_rdy;
   output [15:0] bd_data_out;
   output [1:0] bd_cmd;
   output [23:0] bd_addr;
   output wire bd_rd;
   output wire bd_start;
   output wire bd_wr;

   output [4:0] disk_state;

   // ---!!! //////////////////////////////////////////////////////////////////////

   input [31:0] vram_data_in;
   input wire vram_done;
   input wire vram_ready;
   output [14:0] vram_addr;
   output [31:0] vram_data_out;
   output wire vram_req;
   output wire vram_write;

   // ---!!! //////////////////////////////////////////////////////////////////////

   input [15:0] kb_data;
   input wire kb_ready;

   input [11:0] ms_x;
   input [11:0] ms_y;
   input [2:0] ms_button;
   input wire ms_ready;

   // ---!!! ///////////////////////////////////////////////////////////////////////

   output wire promdisable;

   // ---!!! //////////////////////////////////////////////////////////////////////

   input [15:0] spyin;
   output [15:0] spyout;
   output wire spyrd;
   output wire spywr;
   output [3:0] spyreg;

   ////////////////////////////////////////////////////////////////////////////////

   wire device_ack;
   wire timedout;
   wire req_valid;

   wire [21:0] dram_addr;
   wire dram_reqin;
   wire dram_writein;
   wire [31:0] dram_datain;

   wire busgrantin2disk;
   wire [31:0] disk_datain;
   wire decodein_disk;
   wire ackin_disk;

   wire disk_req2busint;
   wire [21:0] addrout_disk;
   wire disk_write2busint;

   wire disk_busreq2busint;

   wire ack_disk;
   wire ack_tv;
   wire ack_io;
   wire ack_unibus;
   wire ack_spy;
   wire ack_dram;

   wire decode_disk;
   wire decode_tv;
   wire decode_io;
   wire decode_unibus;
   wire decode_spy;
   wire decode_dram;

   wire [31:0] dataout_disk;
   wire [31:0] dataout_dram;
   wire [31:0] dataout_io;
   wire [31:0] dataout_spy;
   wire [31:0] dataout_tv;
   wire [31:0] dataout_unibus;

   wire interrupt_disk;
   wire interrupt_tv;
   wire interrupt_io;
   wire interrupt_unibus;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [7:0]		vector;			// From io of xbus_io.v
   // End of automatics
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   xbus_ram dram
     (
      .addr(dram_addr),
      .datain(dram_datain),
      .dataout(dataout_dram),
      .req(dram_reqin),
      .write(dram_writein),
      .ack(ack_dram),
      .decode(decode_dram),
      /*AUTOINST*/
      // Outputs
      .sdram_addr			(sdram_addr[21:0]),
      .sdram_data_out			(sdram_data_out[31:0]),
      .sdram_req			(sdram_req),
      .sdram_write			(sdram_write),
      // Inputs
      .clk				(clk),
      .reset				(reset),
      .sdram_data_in			(sdram_data_in[31:0]),
      .sdram_ready			(sdram_ready),
      .sdram_done			(sdram_done));

   xbus_disk disk
     (
      .addrin(addr),
      .datain(disk_datain),
      .dataout(dataout_disk),
      .reqin(req_valid),
      .writein(write),
      .ackout(ack_disk),
      .decodeout(decode_disk),
      .interrupt(interrupt_disk),
      .busreqout(disk_busreq2busint),
      .busgrantin(busgrantin2disk),
      .addrout(addrout_disk),
      .reqout(disk_req2busint),
      .ackin(ackin_disk),
      .writeout(disk_write2busint),
      .decodein(decodein_disk),
      /*AUTOINST*/
      // Outputs
      .bd_data_out			(bd_data_out[15:0]),
      .bd_cmd				(bd_cmd[1:0]),
      .bd_addr				(bd_addr[23:0]),
      .bd_rd				(bd_rd),
      .bd_start				(bd_start),
      .bd_wr				(bd_wr),
      .disk_state			(disk_state[4:0]),
      // Inputs
      .clk				(clk),
      .reset				(reset),
      .bd_state				(bd_state[11:0]),
      .bd_data_in			(bd_data_in[15:0]),
      .bd_bsy				(bd_bsy),
      .bd_err				(bd_err),
      .bd_iordy				(bd_iordy),
      .bd_rdy				(bd_rdy));

   xbus_tv tv
     (
      .dataout(dataout_tv),
      .req(req_valid),
      .ack(ack_tv),
      .decode(decode_tv),
      .interrupt(interrupt_tv),
      /*AUTOINST*/
      // Outputs
      .vram_addr			(vram_addr[14:0]),
      .vram_data_out			(vram_data_out[31:0]),
      .vram_req				(vram_req),
      .vram_write			(vram_write),
      // Inputs
      .clk				(clk),
      .reset				(reset),
      .addr				(addr[21:0]),
      .datain				(datain[31:0]),
      .write				(write),
      .vram_data_in			(vram_data_in[31:0]),
      .vram_done			(vram_done),
      .vram_ready			(vram_ready));

   xbus_io io
     (
      .datain(datain),
      .dataout(dataout_io),
      .req(req_valid),
      .ack(ack_io),
      .decode(decode_io),
      .interrupt(interrupt_io),
      /*AUTOINST*/
      // Outputs
      .vector				(vector[7:0]),
      // Inputs
      .clk				(clk),
      .reset				(reset),
      .addr				(addr[21:0]),
      .write				(write),
      .ms_ready				(ms_ready),
      .ms_x				(ms_x[11:0]),
      .ms_y				(ms_y[11:0]),
      .ms_button			(ms_button[2:0]),
      .kb_ready				(kb_ready),
      .kb_data				(kb_data[15:0]));

   xbus_unibus unibus
     (
      .dataout(dataout_unibus),
      .req(req_valid),
      .ack(ack_unibus),
      .decode(decode_unibus),
      .interrupt(interrupt_unibus),
      /*AUTOINST*/
      // Outputs
      .promdisable			(promdisable),
      // Inputs
      .clk				(clk),
      .addr				(addr[21:0]),
      .datain				(datain[31:0]),
      .write				(write),
      .timedout				(timedout));

   xbus_spy spy
     (
      .dataout(dataout_spy),
      .req(req_valid),
      .ack(ack_spy),
      .decode(decode_spy),
      /*AUTOINST*/
      // Outputs
      .spyout				(spyout[15:0]),
      .spyreg				(spyreg[3:0]),
      .spyrd				(spyrd),
      .spywr				(spywr),
      // Inputs
      .clk				(clk),
      .addr				(addr[21:0]),
      .datain				(datain[31:0]),
      .write				(write),
      .spyin				(spyin[15:0]));

   ////////////////////////////////////////////////////////////////////////////////
   // Bus state machine and arbiter

   localparam [3:0]
     IDLE = 4'b0000,
     REQ = 4'b0001,
     WAIT = 4'b0010,
     SLAVE = 4'b0100,
     SWAIT = 4'b1000;

   reg [3:0] state;
   wire [3:0] state_ns;

   always @(posedge clk)
     if (reset) begin
	state <= IDLE;
     end else begin
	state <= state_ns;
     end

   assign device_ack = ack_dram | ack_disk | ack_tv | ack_io | ack_unibus | ack_spy | timedout;

   assign state_ns =
		    (state == IDLE && req) ? REQ :
		    (state == IDLE && disk_busreq2busint) ? SLAVE :
		    (state == REQ && device_ack) ? WAIT :
		    (state == REQ && ~device_ack) ? REQ :
		    (state == WAIT && ~req) ? IDLE :
		    (state == WAIT && req) ? WAIT :
		    (state == SLAVE && ack_dram) ? SWAIT :
		    (state == SLAVE && ~ack_dram) ? SLAVE :
		    (state == SWAIT && (disk_busreq2busint || ack_dram)) ? SWAIT :
		    (state == SWAIT && ~disk_busreq2busint) ? IDLE :
		    IDLE;

   assign req_valid = req && state == REQ;

   ////////////////////////////////////////////////////////////////////////////////
   // Bus timeout

   reg [5:0] timeout_count;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	timeout_count <= 6'h0;
	// End of automatics
     end else if (state == REQ && ~timedout) begin
	timeout_count <= timeout_count + 6'b000001;
     end else if (state == WAIT) begin
	timeout_count <= 0;
     end

   assign timedout = timeout_count == 6'b111111;

   ////////////////////////////////////////////////////////////////////////////////
   // Allow disk to drive DRAM.

   assign dram_addr = state == SLAVE ? addrout_disk : addr;
   assign dram_reqin = state == SLAVE ? disk_req2busint : (req && state == REQ);
   assign dram_writein = state == SLAVE ? disk_write2busint : (write && state == REQ);
   assign dram_datain = state == SLAVE ? dataout_disk : datain;

   assign busgrantin2disk = state == SLAVE;
   assign disk_datain = state == SLAVE ? dataout_dram : datain;
   assign decodein_disk = busgrantin2disk & decode_dram;
   assign ackin_disk = busgrantin2disk & ack_dram;

   ////////////////////////////////////////////////////////////////////////////////

   assign dataout =
		   (req & decode_dram & ~write) ? dataout_dram :
		   (req & decode_disk & ~write) ? dataout_disk :
		   (req & decode_tv & ~write) ? dataout_tv :
		   (req & decode_io & ~write) ? dataout_io :
		   (req & decode_unibus & ~write) ? dataout_unibus :
		   (req & decode_spy & ~write) ? dataout_spy :
		   (req & timedout & ~write) ? 32'h00000000 : 32'hffffffff;
   assign ack = (load || state == WAIT);
   assign load = device_ack & ~write & (state == REQ);
   assign interrupt = interrupt_disk | interrupt_tv | interrupt_io | interrupt_unibus;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
