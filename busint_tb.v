`timescale 1ns/1ps
`default_nettype none

// ISIM: wave add /

module busint_tb;

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
      $dumpvars(0, busint_tb);
   end

   reg [15:0] out;
   initial begin
      #1;
      clk = 0;
      reset = 0;
      req = 0;
      write = 0;
      #1 reset = 1;
      #500 reset = 0;

      bus_read(22'o17772037, out);

      #10;
      bus_read(22'o17773020, out);      
      bus_write(22'o17773020, 1);
      bus_read(22'o17773020, out);      
      
      $display("TEST DONE");

      $finish;
   end

   always begin
      #20 clk = 0;
      #20 clk = 1;
   end

endmodule
