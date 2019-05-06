`timescale 1ns/1ps
`default_nettype none

// ISIM: wave add /

module busint_disk_tb;

   reg clk;
   reg reset;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			ack;			// From busint of busint.v
   wire [23:0]		bd_addr;		// From busint of busint.v
   wire [1:0]		bd_cmd;			// From busint of busint.v
   wire [15:0]		bd_data_out;		// From busint of busint.v, ...
   wire			bd_rd;			// From busint of busint.v
   wire			bd_start;		// From busint of busint.v
   wire [11:0]		bd_state;		// From mmc_bd of block_dev_mmc.v
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
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [21:0]		addr;			// To busint of busint.v
   reg [15:0]		bd_data_in;		// To busint of busint.v, ...
   reg [31:0]		datain;			// To busint of busint.v
   reg [15:0]		kb_data;		// To busint of busint.v
   reg			kb_ready;		// To busint of busint.v
   reg			mmcclk;			// To mmc_bd of block_dev_mmc.v
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

   wire bd_err;
   wire bd_iordy;
   wire bd_bsy;
   wire [11:0] bd_state_in;
   wire bd_rdy;

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

   task wait_for_disk_idle;
      reg [31:0] status;
      begin
	 status = 0;
	 while ((status & 1) == 0) begin
	    bus_read(22'o17377774, status);
	    @(posedge clk);
	 end
	 $display("wait-for-disk: status %o", status);
      end
   endtask

   task wait_for_disk_busy;
      reg [31:0] status;
      begin
	 status = 0;
	 while ((status & 1) == 1) begin
	    bus_read(22'o17377774, status);
	    @(posedge clk);
	 end
	 $display("wait-for-disk: status %o", status);
      end
   endtask

   task disk_read;
      input [31:0] da;
      begin
	 bus_write(22'o22, 32'o1000);
	 wait_for_disk_idle;
	 bus_write(22'o17377776, da);
	 bus_write(22'o17377775, 32'o22);
	 bus_write(22'o17377774, 32'o0);
	 bus_write(22'o17377777, 32'o0);
	 wait_for_disk_busy;
	 wait_for_disk_idle;
      end
   endtask

   task zero_ram;
      integer i;
      begin
	 for (i = 0; i < 256; i = i + 1)
      	   busint.busint.dram.ram[i] = 0;
      end
   endtask

   task fill_ram;
      begin
      	 busint.busint.dram.ram['o1000] = 'h11112222;
	 busint.busint.dram.ram['o1001] = 'h33334444;
     	 busint.busint.dram.ram['o1002] = 'h55556666;
     	 busint.busint.dram.ram['o1003] = 'h12345678;
     	 busint.busint.dram.ram['o1004] = 'h87654321;
     	 busint.busint.dram.ram['o1005] = 'h00000000;
	 busint.busint.dram.ram['o1006] = 'h00000000;
      end
   endtask

   task disk_write;
      input [31:0] da;
      begin
	 bus_write(22'o22, 32'o1000);
	 wait_for_disk_idle;
	 bus_write(22'o17377776, da);
	 bus_write(22'o17377775, 32'o22);
	 bus_write(22'o17377774, 32'o11);
	 bus_write(22'o17377777, 32'o0);
	 wait_for_disk_busy;
	 wait_for_disk_idle;
      end
   endtask

   task check_rd_byte;
      input [31:0] index;
      input [7:0] v;
      begin
      end
   endtask

   task check_wr_byte;
      input [31:0] index;
      input [7:0] v;
      begin
      end
   endtask

   task check_read;
      begin
	 check_rd_byte(0, 8'h00);
	 check_rd_byte(1, 8'h01);
	 check_rd_byte(2, 8'h02);
	 check_rd_byte(3, 8'h03);
	 check_rd_byte(4, 8'h04);
	 check_rd_byte(5, 8'h05);
	 check_rd_byte(6, 8'h06);
	 check_rd_byte(7, 8'h07);
      end
   endtask

   task check_write;
      begin
	 check_wr_byte(0, 8'h22);
	 check_wr_byte(1, 8'h22);
	 check_wr_byte(2, 8'h11);
	 check_wr_byte(3, 8'h11);
	 check_wr_byte(4, 8'h44);
	 check_wr_byte(5, 8'h44);
	 check_wr_byte(6, 8'h33);
	 check_wr_byte(7, 8'h33);
      end
   endtask

   initial begin
      $timeformat(-9, 0, "ns", 7);
      $dumpfile(`VCDFILE);
      $dumpvars(0, busint_disk_tb);
   end

   initial begin
      #1;
      clk = 0;
      reset = 0;
      req = 0;
      write = 0;
      #1 reset = 1;
      #500 reset = 0;
      if (0) begin
	 zero_ram;
	 disk_read(32'o0);
	 check_read;
      end

      if (1) begin
	 zero_ram;
	 fill_ram;
	 disk_write(32'o1);
	 check_write;
      end

      $display("TEST DONE");

      $finish;
   end

   always begin
      #20 clk = 0;
      #20 clk = 1;
   end

   wire mmc_cs;
   wire mmc_di;
   wire mmc_do;
   wire mmc_sclk;

   block_dev_mmc mmc_bd(
			/*AUTOINST*/
			// Outputs
			.bd_state	(bd_state[11:0]),
			.bd_data_out	(bd_data_out[15:0]),
			.bd_bsy		(bd_bsy),
			.bd_err		(bd_err),
			.bd_iordy	(bd_iordy),
			.bd_rdy		(bd_rdy),
			.mmc_cs		(mmc_cs),
			.mmc_do		(mmc_do),
			.mmc_sclk	(mmc_sclk),
			// Inputs
			.bd_data_in	(bd_data_in[15:0]),
			.bd_cmd		(bd_cmd[1:0]),
			.bd_addr	(bd_addr[23:0]),
			.bd_rd		(bd_rd),
			.bd_start	(bd_start),
			.bd_wr		(bd_wr),
			.clk		(clk),
			.mmc_di		(mmc_di),
			.mmcclk		(mmcclk),
			.reset		(reset));

   mmc_model mmc_card(
		      .spiClk(mmc_sclk),
		      .spiDataIn(mmc_do),
		      .spiDataOut(mmc_di),
		      .spiCS_n(mmc_cs)
		      );

endmodule
