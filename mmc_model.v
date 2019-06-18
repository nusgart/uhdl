// mmc_model.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

`define CMD0	8'h40
`define CMD1	8'h41
`define CMD16	8'h50
`define CMD17	8'h51
`define CMD24	8'h58

module mmc_model(/*AUTOARG*/
   // Outputs
   spiDataOut,
   // Inputs
   spiClk, spiDataIn, spiCS_n
   );

   input wire spiClk;
   input wire spiDataIn;
   output spiDataOut;
   input wire spiCS_n;

   ////////////////////////////////////////////////////////////////////////////////

   parameter [3:0]
     POWERUP = 4'd0,
     IDLE = 4'd1,
     CMD = 4'd2,
     CMD_RESP = 4'd3,
     READ = 4'd4,
     READ_RESP = 4'd5,
     WRITE = 4'd6,
     WRITE_DATA = 4'd7;

   integer blockNumber;
   integer blockSize;
   integer diskAddr;
   integer i;
   integer init_seq;
   integer respCount;
   integer respDelay;
   integer respIndex;

   reg [3:0] state;
   reg [7:0] cmdBytes[0:5];
   reg [7:0] cnt;
   reg [7:0] rd_data[0:511];
   reg [7:0] respByte;
   reg [7:0] rxByte;
   reg [7:0] wr_data[0:511];
   reg spiDataOut;

`ifdef USE_FILE
   integer file_fd;
   integer file_ret;
`else
   reg [7:0] block0[0:511];
   reg [7:0] block1[0:511];
   reg [7:0] block2[0:511];
   reg [7:0] block3[0:511];
`endif

   ////////////////////////////////////////////////////////////////////////////////

   initial begin
      state = POWERUP;
      spiDataOut = 0;
      init_seq = 0;
      blockSize = 512;
`ifdef USE_FILE
      file_fd = $fopen("disk.img", "rw");
`else
      for (i = 0; i < 512; i = i + 1)
	begin
	   block0[i] = i;
	   block1[i] = i;
	   block2[i] = i;
	   block3[i] = i;
	end
`endif
   end

   task txRxByte;
      input [7:0] txData;
      output [7:0] rxData;
      integer i;
      begin
	 spiDataOut <= txData[7];
	 for (i = 0; i < 8; i=i+1) begin
	    @(posedge spiClk);
	    if (spiCS_n == 0) begin
	       rxData = rxData << 1;
	       rxData[0] <= spiDataIn;
	       @(negedge spiClk);
	       spiDataOut <= txData[6];
	       txData = txData << 1;
	    end else begin
	       i = -1;
	       @(negedge spiClk);
	    end
	 end
      end
   endtask

   task setRespByte;
      input [7:0] dataByte;
      input [31:0] delay;
      begin
	 respByte = dataByte;
	 respDelay = delay;
      end
   endtask

   task waitForCS;
      integer done, clk, oldclk, clkcnt;
      begin
	 done = 0;
	 oldclk = 0;
	 clkcnt = 0;
	 while (done == 0) begin
	    if (spiCS_n == 0)
	      done = 1;
	    if (spiDataIn == 1) begin
	       clk = spiClk;
	       if (clk && oldclk == 0) begin
		  clkcnt = clkcnt + 1;
	       end
	       oldclk = clk;
	    end
	    #1;
	 end
	 if (clkcnt != 0)
	   $display("waitForCS: clkcnt %d; %t", clkcnt, $time);
	 if (clkcnt > 74)
	   state = IDLE;
      end
   endtask

   task yield;
      begin
	 #1;
      end
   endtask

   always begin
      case (state)
	POWERUP: begin
	   if (init_seq == 0) begin
	      $display("MMC: powerup");
	      init_seq = 1;
	   end
	   waitForCS;
	   cnt = 0;
	end
	IDLE: begin
	   txRxByte(8'hff, rxByte);
	   if (rxByte == 8'hff) begin
	      cnt = 0;
	   end else begin
	      $display("MMC: idle, byte %d = %x; %t", cnt, rxByte, $time);
	      cmdBytes[cnt] = rxByte;
	      cnt = cnt + 1;
	      if (cnt == 6)
		state = CMD;
	   end
	end
	CMD: begin
	   case (cmdBytes[0])
	     `CMD0: begin
		$display("MMC: cmd0; %t", $time);
		state = CMD_RESP;
		setRespByte(8'h01, 0);
	     end
	     `CMD1: begin
		$display("MMC: cmd1; %t", $time);
		state = CMD_RESP;
		setRespByte(8'h00, 0);
	     end
	     `CMD16: begin
		$display("MMC: cmd16");
		state = CMD_RESP;
		setRespByte(8'h00, 20);
		blockSize = { cmdBytes[1], cmdBytes[2], cmdBytes[3], cmdBytes[4] };
		$display("MMC: set blocksize %d bytes", blockSize);
	     end
	     `CMD17: begin
		$display("MMC: cmd17");
		state = CMD_RESP;
		setRespByte(8'h00, 20);
	     end
	     `CMD24: begin
		$display("MMC: cmd24");
		state = CMD_RESP;
		setRespByte(8'h00, 20);
	     end
	     default: begin
		state = CMD_RESP;
		setRespByte(8'h7f, 0);
	     end
	   endcase
	   yield;
	end
	CMD_RESP: begin
	   $display("MMC: cmd_resp; %t", $time);
	   txRxByte(8'hff, rxByte);
	   while (respDelay > 0) begin
	      txRxByte(8'hff, rxByte);
	      respDelay = respDelay - 1;
	   end
	   txRxByte(respByte, rxByte);
	   cnt = 0;
	   state = IDLE;
	   if (cmdBytes[0] == `CMD17)
	     state = READ;
	   if (cmdBytes[0] == `CMD24)
	     state = WRITE;
	   if (state == READ || state == WRITE) begin
	      diskAddr = { cmdBytes[1], cmdBytes[2], cmdBytes[3], cmdBytes[4] };
	      blockNumber = diskAddr / blockSize;
	      $display("MMC: byte-offset=0x%x, block=%d", diskAddr, blockNumber);
	   end
	   cmdBytes[0] = 0;
	end
	READ: begin
	   $display("MMC: read; %t", $time);
	   state = READ_RESP;
	   respCount = 512;
	   respIndex = 0;
`ifdef USE_FILE
	   file_ret = $fseek(file_fd, blockNumber*512, 0);
	   file_ret = $fread(file_fd, rd_data);
`else
	   case (blockNumber)
	     0: for (i = 0; i < 512; i = i + 1) rd_data[i] = block0[i];
	     1: for (i = 0; i < 512; i = i + 1) rd_data[i] = block1[i];
	     2: for (i = 0; i < 512; i = i + 1) rd_data[i] = block2[i];
	     3: for (i = 0; i < 512; i = i + 1) rd_data[i] = block3[i];
	   endcase
`endif
	   txRxByte(8'hff, rxByte);
	   txRxByte(8'hff, rxByte);
	   txRxByte(8'hfe, rxByte);
	end
	READ_RESP: begin
	   $display("MMC: read_resp");
	   while (respCount > 0) begin
	      txRxByte(rd_data[respIndex], rxByte);
	      respIndex = respIndex + 1;
	      respCount = respCount - 1;
	   end
	   cnt = 0;
	   state = IDLE;
	end
	WRITE: begin
	   $display("MMC: write %t", $time);
	   state = WRITE_DATA;
	   respCount = 512;
	   respIndex = 0;
	   txRxByte(8'h00, rxByte);
	end
	WRITE_DATA: begin
	   $display("MMC: write_data");
	   while (respCount > 0) begin
	      txRxByte(8'hff, rxByte);
	      wr_data[respIndex] = rxByte;
	      $display("MMC: write_data [%d] <- %x", respIndex, rxByte);
	      respIndex = respIndex + 1;
	      respCount = respCount - 1;
	   end
	   if (0) $display("MMC: write done %x %x %x %x", wr_data[0],wr_data[1],wr_data[2],wr_data[3]);
`ifdef USE_FILE
	   file_ret = $fseek(file_fd, blockNumber*512, 0);
	   file_ret = $fwrite(file_fd, wr_data);
	   $fflush(file_fd);
`else
	   case (blockNumber)
	     0: for (i = 0; i < 512; i = i + 1) block0[i] = wr_data[i];
	     1: for (i = 0; i < 512; i = i + 1) block1[i] = wr_data[i];
	     2: for (i = 0; i < 512; i = i + 1) block2[i] = wr_data[i];
	     3: for (i = 0; i < 512; i = i + 1) block3[i] = wr_data[i];
	   endcase
`endif
	   txRxByte(8'hff, rxByte);
	   txRxByte(8'hff, rxByte);
	   txRxByte(8'h15, rxByte);
	   cnt = 0;
	   state = CMD_RESP;
	   setRespByte(8'h01, 0/*20*/);
	end
      endcase
   end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
