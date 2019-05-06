`timescale 1ns/1ps
`default_nettype none

`include "chaos.vh"
`include "assert.vh"

// ISIM: wave add /

module busint_chaos_tb;

   reg clk;
   reg reset;

   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [21:0]		addr;			// To busint of busint.v
   reg			bd_bsy;			// To busint of busint.v
   reg [15:0]		bd_data_in;		// To busint of busint.v
   reg			bd_err;			// To busint of busint.v
   reg			bd_iordy;		// To busint of busint.v
   reg			bd_rdy;			// To busint of busint.v
   reg [11:0]		bd_state;		// To busint of busint.v
   reg [31:0]		datain;			// To busint of busint.v
   reg [15:0]		kb_data;		// To busint of busint.v
   reg			kb_ready;		// To busint of busint.v
   reg [2:0]		ms_button;		// To busint of busint.v
   reg			ms_ready;		// To busint of busint.v
   reg [11:0]		ms_x;			// To busint of busint.v
   reg [11:0]		ms_y;			// To busint of busint.v
   reg			req;			// To busint of busint.v
   reg [31:0]		sdram_data_in;		// To busint of busint.v
   reg			sdram_done;		// To busint of busint.v
   reg			sdram_ready;		// To busint of busint.v
   reg [15:0]		spyin;			// To busint of busint.v
   reg [31:0]		vram_data_in;		// To busint of busint.v
   reg			vram_done;		// To busint of busint.v
   reg			vram_ready;		// To busint of busint.v
   reg			write;			// To busint of busint.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			ack;			// From busint of busint.v
   wire [23:0]		bd_addr;		// From busint of busint.v
   wire [1:0]		bd_cmd;			// From busint of busint.v
   wire [15:0]		bd_data_out;		// From busint of busint.v
   wire			bd_rd;			// From busint of busint.v
   wire			bd_start;		// From busint of busint.v
   wire			bd_wr;			// From busint of busint.v
   wire [31:0]		dataout;		// From busint of busint.v
   wire [4:0]		disk_state;		// From busint of busint.v
   wire			interrupt;		// From busint of busint.v
   wire			load;			// From busint of busint.v
   wire			promdisable;		// From busint of busint.v
   wire [21:0]		sdram_addr;		// From busint of busint.v
   wire [31:0]		sdram_data_out;		// From busint of busint.v
   wire			sdram_req;		// From busint of busint.v
   wire			sdram_write;		// From busint of busint.v
   wire [15:0]		spyout;			// From busint of busint.v
   wire			spyrd;			// From busint of busint.v
   wire [3:0]		spyreg;			// From busint of busint.v
   wire			spywr;			// From busint of busint.v
   wire [14:0]		vram_addr;		// From busint of busint.v
   wire [31:0]		vram_data_out;		// From busint of busint.v
   wire			vram_req;		// From busint of busint.v
   wire			vram_write;		// From busint of busint.v
   // End of automatics
   
`include "busint.vh"
   busint busint(/*AUTOINST*/
		 // Outputs
		 .dataout		(dataout[31:0]),
		 .ack			(ack),
		 .load			(load),
		 .interrupt		(interrupt),
		 .sdram_addr		(sdram_addr[21:0]),
		 .sdram_data_out	(sdram_data_out[31:0]),
		 .sdram_req		(sdram_req),
		 .sdram_write		(sdram_write),
		 .bd_data_out		(bd_data_out[15:0]),
		 .bd_cmd		(bd_cmd[1:0]),
		 .bd_addr		(bd_addr[23:0]),
		 .bd_rd			(bd_rd),
		 .bd_start		(bd_start),
		 .bd_wr			(bd_wr),
		 .disk_state		(disk_state[4:0]),
		 .vram_addr		(vram_addr[14:0]),
		 .vram_data_out		(vram_data_out[31:0]),
		 .vram_req		(vram_req),
		 .vram_write		(vram_write),
		 .promdisable		(promdisable),
		 .spyout		(spyout[15:0]),
		 .spyrd			(spyrd),
		 .spywr			(spywr),
		 .spyreg		(spyreg[3:0]),
		 // Inputs
		 .clk			(clk),
		 .reset			(reset),
		 .addr			(addr[21:0]),
		 .datain		(datain[31:0]),
		 .req			(req),
		 .write			(write),
		 .sdram_data_in		(sdram_data_in[31:0]),
		 .sdram_done		(sdram_done),
		 .sdram_ready		(sdram_ready),
		 .bd_state		(bd_state[11:0]),
		 .bd_data_in		(bd_data_in[15:0]),
		 .bd_bsy		(bd_bsy),
		 .bd_err		(bd_err),
		 .bd_iordy		(bd_iordy),
		 .bd_rdy		(bd_rdy),
		 .vram_data_in		(vram_data_in[31:0]),
		 .vram_done		(vram_done),
		 .vram_ready		(vram_ready),
		 .kb_data		(kb_data[15:0]),
		 .kb_ready		(kb_ready),
		 .ms_x			(ms_x[11:0]),
		 .ms_y			(ms_y[11:0]),
		 .ms_button		(ms_button[2:0]),
		 .ms_ready		(ms_ready),
		 .spyin			(spyin[15:0]));
   
   initial begin
      $timeformat(-9, 0, "ns", 7);
      $dumpfile(`VCDFILE);
      $dumpvars(0, busint_chaos_tb);
   end

   reg [31:0] my_addr;
   reg [31:0] csr;
   reg [31:0] xmit_read;	// this should always be my_addr ...
   
   task chaos_read_my_addr;
      begin
	 $display("chaos read my addr");
	 bus_read(22'o17772061, my_addr);
      end
   endtask
   
   task chaos_write_csr;
      input  [15:0] r;
      begin
	 $display("chaos write csr");
	 bus_write(22'o17772060, r);
      end
   endtask

   task chaos_write_xmit;
      input  [15:0] r;
      begin
	 $display("chaos write xmit (%c, %c)", r[7:0], r[15:8]);
	 bus_write(22'o17772061, r);
	 `warn(out, r);
      end
   endtask

   task chaos_start_xmit;
      begin
	 $display("chaos start xmit");
	 bus_read(22'o17772065, xmit_read);
      end
   endtask

   task chaos_read_csr;
      begin
	 $display("chaos read csr");
	 bus_read(22'o17772060, csr);
      end
   endtask

      integer i;

   reg [15:0] out;
   initial begin
      #1;
      clk = 0;
      reset = 0;
      req = 0;
      write = 0;
      #1 reset = 1;
      #500 reset = 0;

      chaos_read_my_addr();	// unibus: chaos read my-number: 4401
      
      /// USIM BOOT
      chaos_write_csr('o20000); // unibus: chaos write csr 500020000
      chaos_read_csr();		// unibus: chaos read csr 000200
      `assert(csr, 'o000220);
      chaos_read_my_addr();	// unibus: chaos read my-number: 4401
      chaos_read_my_addr();	// unibus: chaos read my-number: 4401
      chaos_write_csr('o20000); // unibus: chaos write csr 500020000
      chaos_write_csr('o00060); // unibus: chaos write csr 500000060
      chaos_read_csr();		// unibus: chaos read csr 000260
      `assert(csr, 'o000260);
      chaos_write_csr('o220);	// unibus: chaos write csr 220
      chaos_read_csr();		// unibus: chaos read csr 000220
      `assert(csr, 'o000220);

      /// USIM SET-SYS-HOST SETUP
      
      chaos_write_csr('o000260); // unibus: chaos write csr 260
      chaos_read_csr();		 // unibus: chaos read csr 000260
      `assert(csr, 'o000260);
      chaos_write_xmit('o1400400); // unibus: chaos write-buffer write 1400400

      busint.chaos.tbct = 1;
      chaos_write_xmit('o6);	// unibus: chaos write-buffer write 6

      busint.chaos.tbct = 2;
      chaos_write_xmit('o4404);	// unibus: chaos write-buffer write 4404

      busint.chaos.tbct = 3;
      chaos_write_xmit('o0);	// unibus: chaos write-buffer write 0

      busint.chaos.tbct = 4;
      chaos_write_xmit('o4561004401); // unibus: chaos write-buffer write 4561004401

      busint.chaos.tbct = 5;
      chaos_write_xmit('o22704); // unibus: chaos write-buffer write 22704

      busint.chaos.tbct = 6;
      chaos_write_xmit('o0);	 // unibus: chaos write-buffer write 0

      busint.chaos.tbct = 7;
      chaos_write_xmit('o0);	 // unibus: chaos write-buffer write 0

      busint.chaos.tbct = 8;
      chaos_write_xmit('o12420252123); // unibus: chaos write-buffer write 12420252123

      busint.chaos.tbct = 9;
      chaos_write_xmit('o52101); // unibus: chaos write-buffer write 52101

      busint.chaos.tbct = 10;
      chaos_write_xmit('o1101051525); // unibus: chaos write-buffer write 1101051525

      busint.chaos.tbct = 11;
      chaos_write_xmit('o4404);	// unibus: chaos write-buffer write 4404

      chaos_start_xmit();      // unibus: chaos read xmt => 4401
      // chaos_xmit_pkt() 24 bytes, data len 6
//      `assert(busint.chaos.xmit_bytes, 24);
      
      $finish;
      
      chaos_write_csr('o260);      // unibus: chaos write csr 260
      chaos_write_csr('o220);      // unibus: chaos write csr 220
      chaos_read_csr();	      // unibus: chaos read csr 000220
      `assert(csr, 'o000220);
      chaos_read_csr();	      // unibus: chaos read csr 100220
      `assert(csr, 'o100220);
      // unibus: chaos read bit-count 1717
      // unibus: chaos read rcv buffer 2400
      // unibus: chaos read rcv buffer 144
      // unibus: chaos read rcv buffer 4401
      // unibus: chaos read rcv buffer 22704
      // unibus: chaos read rcv buffer 4404
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 62563
      // unibus: chaos read rcv buffer 73162
      // unibus: chaos read rcv buffer 71145
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 411
      // unibus: chaos read rcv buffer 40
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 3
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 0
      // unibus: chaos read rcv buffer 4401
      // unibus: chaos read rcv buffer 4404
      // chaos_get_rcv_buffer: marked buffer as empty
      // unibus: chaos read rcv buffer 0
      // unibus: chaos write csr 500100230
      // unibus: chaos read csr 000220
      // unibus: chaos write csr 220
      // unibus: chaos write csr 220

      $finish;
   end

   always begin
      #20 clk = 0;
      #20 clk = 1;
   end

endmodule
