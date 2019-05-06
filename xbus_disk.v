// xbus_disk.v --- disk controller
//
// This is a simplified Trident disk controller, much of the error
// checking (parity, ECC, etc) is missing, there is no concept of disk
// aspects of the disk (head movement, etc).
//
// Expects the block device to provide 1024 byte blocks with 16-bit
// interface.  Currently the LBA is passed with 512 byte block
// addressing.
//
// See (cadr)Disk Controller for details.

`timescale 1ns/1ps
`default_nettype none

module xbus_disk(/*AUTOARG*/
   // Outputs
   dataout, interrupt, addrout, reqout, writeout, ackout, busreqout,
   decodeout, bd_data_out, bd_cmd, bd_addr, bd_rd, bd_start, bd_wr,
   disk_state,
   // Inputs
   clk, reset, addrin, datain, reqin, writein, ackin, busgrantin,
   decodein, bd_state, bd_data_in, bd_bsy, bd_err, bd_iordy, bd_rdy
   );

   // Trident T-300
   parameter
     DISK_CYLS = 815,
     DISK_HEADS = 19,
     DISK_BLOCKS = 17;

   input clk;
   input reset;

   input [21:0] addrin;
   input [31:0] datain;
   input reqin;
   input writein;
   output [31:0] dataout;
   input ackin;
   input busgrantin;
   input decodein;
   output interrupt;

   output [21:0] addrout;
   output reqout;
   output writeout;
   output ackout;
   output busreqout;
   output decodeout;

   input [11:0] bd_state;
   input [15:0] bd_data_in;
   input bd_bsy;
   input bd_err;
   input bd_iordy;
   input bd_rdy;
   output [15:0] bd_data_out;
   output [1:0] bd_cmd;
   output [23:0] bd_addr;
   output bd_rd;
   output bd_start;
   output bd_wr;

   output [4:0] disk_state;

   ////////////////////////////////////////////////////////////////////////////////

   wire active;
   wire decode;

   reg [2:0] disk_unit;
   reg [11:0] disk_cyl;
   reg [4:0] disk_head;
   reg [4:0] disk_block;

   reg [21:0] disk_clp;

   reg [15:0] disk_data_hold;

   reg [31:0] ccw;

   reg clear_err;
   reg set_err;

   reg [7:0] wc;
   reg inc_wc;
   reg clear_wc;

   reg assert_int;
   reg deassert_int;

   reg [31:0] dma_data_hold;
   reg [31:0] dma_dataout;
   reg [31:0] reg_dataout;

   reg disk_start;

   reg done_intr_enb;
   reg attn_intr_enb;

   reg inc_da;
   reg inc_clp;

   /*AUTOWIRE*/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [21:0]		addrout;
   reg [1:0]		bd_cmd;
   reg [15:0]		bd_data_out;
   reg			bd_rd;
   reg			bd_start;
   reg			bd_wr;
   reg			busreqout;
   reg			reqout;
   reg			writeout;
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////
   // Disk state machine

   localparam
     DISK_CMD_READ = 10'o0000,
     DISK_CMD_RDCMP = 10'o0010,
     DISK_CMD_WRITE = 10'o0011,
     DISK_CMD_RECAL = 10'o1005,
     DISK_CMD_CLEAR = 10'o0405;

   reg [9:0] disk_cmd;

   localparam [4:0]
     IDLE = 0,
     BUSY = 1,
     READ_CCW = 2,
     READ_CCW_DONE = 3,
     INIT0 = 4,
     INIT1 = 5,
     READ0 = 6,
     READ1 = 7,
     READ2 = 8,
     READ3 = 9,
     WRITE0 = 10,
     WRITE1 = 11,
     WRITE1A = 12,
     WRITE2 = 13,
     WRITE2A = 14,
     LAST0 = 15,
     LAST1 = 16,
     LAST2 = 17,
     DONE0 = 18,
     DONE1 = 19,
     RESET = 20,
     RESET0 = 21;

   reg [4:0] state;
   reg [4:0] state_ns;

   always @(posedge clk)
     if (reset)
       state <= IDLE;
     else
       state <= state_ns;

   always @* begin
      state_ns = state;
      assert_int = 0;
      clear_err = 0;
      set_err = 0;
      inc_da = 0;
      inc_clp = 0;
      clear_wc = 0;
      inc_wc = 0;
      bd_rd = 0;
      bd_wr = 0;
      bd_data_out = 0;
      bd_start = 0;
      bd_cmd = 0;
      dma_dataout = 0;

      case (state)
	IDLE:
	  if (disk_start) begin
	     case (disk_cmd)
	       DISK_CMD_READ, DISK_CMD_RDCMP: state_ns = READ_CCW;
	       DISK_CMD_WRITE: state_ns = READ_CCW;
	       DISK_CMD_RECAL: state_ns = BUSY;
	       DISK_CMD_CLEAR: state_ns = RESET;
	       default: begin end
	     endcase
	  end
	BUSY: begin
	   state_ns = IDLE;
	end
	RESET: begin
	   bd_start = 1;
	   bd_cmd = 2'b0;

	   if (bd_bsy)
	     state_ns = RESET0;
	end
	RESET0: begin
	   if (bd_rdy)
	     state_ns = BUSY;
	end
	READ_CCW: begin
	   if (busgrantin && ackin)
	     state_ns = READ_CCW_DONE;
	end
	READ_CCW_DONE: begin
	   state_ns = INIT0;
	end
	INIT0: begin
	   bd_start = 1;

	   if (disk_cmd == DISK_CMD_WRITE)
	     bd_cmd = 2'b10;
	   else if (disk_cmd == DISK_CMD_RDCMP || disk_cmd == DISK_CMD_READ)
	     bd_cmd = 2'b01;

	   if (bd_bsy)
	     state_ns = INIT1;
	end
	INIT1: begin
	   if (bd_rdy && bd_err)
	     set_err = 1;

	   if (bd_rdy && ~bd_err) begin
	      clear_wc = 1;

	      if (disk_cmd == DISK_CMD_WRITE)
		state_ns = WRITE0;
	      else if (disk_cmd == DISK_CMD_READ || disk_cmd == DISK_CMD_RDCMP)
		state_ns = READ0;
	   end
	end
	READ0: begin
	   if (bd_iordy)
	     state_ns = READ1;
	end
	READ1: begin
	   bd_rd = 1;

	   if (~bd_iordy)
	     state_ns = READ2;
	end
	READ2: begin
	   if (bd_iordy)
	     state_ns = READ3;
	end
	READ3: begin
	   dma_dataout = { bd_data_in, disk_data_hold };

	   if (busgrantin && ackin) begin
	      inc_wc = 1;

	      if (wc == 8'hff)
		state_ns = LAST0;
	      else
		state_ns = READ0;

	      bd_rd = 1;
	   end
	end
	WRITE0: begin
	   if (busgrantin && ackin)
	     state_ns = WRITE1;
	end
	WRITE1: begin
	   bd_wr = 1;
	   bd_data_out = dma_data_hold[15: 0];

	   if (bd_iordy)
	     state_ns = WRITE1A;
	end
	WRITE1A: begin
	   if (~bd_iordy)
	     state_ns = WRITE2;
	end
	WRITE2: begin
	   bd_wr = 1;
	   bd_data_out = dma_data_hold[31:16];

	   if (bd_iordy) begin
	      inc_wc = 1;

	      if (wc == 8'hff)
		state_ns = LAST0;
	      else
		state_ns = WRITE2A;
	   end
	end
	WRITE2A: begin
	   if (~bd_iordy)
	     state_ns = WRITE0;
	end
	LAST0: begin
	   if (bd_rdy)
	     state_ns = LAST1;
	end
	LAST1: begin
	   if (bd_rdy) begin
	      if (bd_err)
		set_err = 1;

	      state_ns = LAST2;
	   end
	end
	LAST2: begin
	   if (ccw[0]) begin
	      inc_da = 1;
	      inc_clp = 1;
	      state_ns = READ_CCW;
	   end else
	     state_ns = DONE0;
	end
	DONE0: begin
	   assert_int = 1;
	   clear_err = 1;
	   state_ns = DONE1;
	end
	DONE1: begin
	   state_ns = IDLE;
	end
	default: begin end
      endcase
   end

   assign active = state != IDLE;

   ////////////////////////////////////////////////////////////////////////////////

   reg err;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	err <= 1'h0;
	// End of automatics
     end else if (clear_err)
       err <= 1'b0;
     else if (set_err)
       err <= 1'b1;

   ////////////////////////////////////////////////////////////////////////////////
   // Memory address register

   reg [31:0] disk_ma;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	disk_ma <= 32'h0;
	// End of automatics
     end else if (state == READ3 || state == WRITE0)
       disk_ma <= { 10'b0, addrout };

   ////////////////////////////////////////////////////////////////////////////////

   reg disk_interrupt;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	disk_interrupt <= 1'h0;
	// End of automatics
     end else if (assert_int)
       disk_interrupt <= 1;
     else if (deassert_int)
       disk_interrupt <= 0;

   ////////////////////////////////////////////////////////////////////////////////
   // Disk status register

   wire [31:0] disk_status;

   assign disk_status = { 18'b0, err, 9'b0, disk_interrupt, 2'b0, ~active };

   ////////////////////////////////////////////////////////////////////////////////

   wire disk_state_rd;
   wire disk_state_wr;

   assign disk_state_rd = (state == READ0) || (state == READ1) || (state == READ2) || (state == READ3);
   assign disk_state_wr = (state == WRITE0) || (state == WRITE1) || (state == WRITE2);
   assign disk_state = { 1'b0, err, disk_state_rd, disk_state_wr, active };

   // Disk address register
   wire [31:0] disk_da;
   assign disk_da = { 1'b0, disk_unit, disk_cyl,
		      3'b0, disk_head, 3'b0, disk_block};

   // Disk controller registers:
   //	0 read status
   //	1 read memory address
   //	2 read disk address
   //	3 read ECC register
   //	4 load command
   //	5 load command list pointer
   //	6 load disk address
   //	7 start

   // Read disk controller register
   task read_dcr;
      input [2:0] r;
      begin
	 case (r)
	   3'o0: reg_dataout = disk_status;
	   3'o1: reg_dataout = disk_ma;
	   3'o2: reg_dataout = disk_da;
	   3'o3: reg_dataout = 0;
	   3'o4: reg_dataout = disk_status;
	   3'o5: reg_dataout = { 8'b0, 2'b00, disk_clp };
	   3'o6: reg_dataout = disk_da;
	   3'o7: reg_dataout = { 2'b0, wc, bd_state, disk_state, state };
	 endcase
      end
   endtask

   // Write disk controller register
   task write_dcr;
      input [2:0] r;
      begin
	 case (r)
	   3'o0, 3'o1, 3'o2, 3'o3: begin end
	   3'o4: begin
	      disk_cmd <= datain[9:0];
	      attn_intr_enb <= datain[10];
	      done_intr_enb <= datain[11];
	      if (datain[11:10] != 2'b00)
		deassert_int = 1;
	   end
	   3'o5, 3'o6: begin end
	   3'o7: disk_start = 1;
	 endcase
      end
   endtask

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	deassert_int = 1'h0;
	disk_start = 1'h0;
	reg_dataout = 32'h0;
	// End of automatics
     end else begin
	deassert_int = 0;
	disk_start = 0;
	reg_dataout = 0;
	if (decode) begin
	   if (addrin[5:3] == 3'o7)
	     if (~writein)
	       read_dcr(addrin[2:0]);
	     else
	       write_dcr(addrin[2:0]);
	end
     end

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	disk_block <= 5'h0;
	disk_clp <= 22'h0;
	disk_cyl <= 12'h0;
	disk_head <= 5'h0;
	disk_unit <= 3'h0;
	// End of automatics
     end else begin
	if (decode && writein && (addrin[5:0] == 6'o75 || addrin[5:0] == 6'o76)) begin
	   if (addrin[2:0] == 3'o5) begin
	      disk_clp <= datain[21:0];
	   end else if (addrin[2:0] == 3'o6) begin
	      disk_unit <= datain[30:28];
	      disk_cyl <= datain[27:16];
	      disk_head <= datain[12:8];
	      disk_block <= datain[4:0];
	   end
	end else begin
	   if (inc_da) begin
	      // Increment disk address by one block.
	      if (disk_block == DISK_BLOCKS-1) begin
		 disk_block <= 0;

		 if (disk_head == DISK_HEADS-1) begin
		    disk_head <= 0;

		    if (disk_cyl == DISK_CYLS-1) begin
		       disk_cyl <= 0;
		    end else begin
		       disk_cyl <= disk_cyl + 12'd1;
		    end
		 end else begin
		    disk_head <= disk_head + 5'd1;
		 end
	      end else begin
		 disk_block <= disk_block + 5'd1;
	      end
	   end

	   if (inc_clp)
	     disk_clp <= disk_clp + 22'd1;
	end
     end

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	wc <= 8'h0;
	// End of automatics
     end else if (clear_wc)
       wc <= 8'b0;
     else if (inc_wc)
       wc <= wc + 8'b1;

   ////////////////////////////////////////////////////////////////////////////////
   // Grab the DMAed data, later used by disk.

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dma_data_hold <= 32'h0;
	// End of automatics
     end else if (state == WRITE0 && busgrantin && ackin)
       dma_data_hold <= datain;

   ////////////////////////////////////////////////////////////////////////////////
   // Grab disk data, later used by DMA.

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	disk_data_hold <= 16'h0;
	// End of automatics
     end else if ((state == READ0 || state == READ1) && bd_iordy)
       disk_data_hold <= bd_data_in;

   ////////////////////////////////////////////////////////////////////////////////
   // Channel Command Words

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	ccw <= 32'h0;
	// End of automatics
     end else if (state == READ_CCW && busgrantin && ackin) begin
	ccw <= { datain[31:24], datain[23:22], datain[21:8], datain[7:1], datain[0] };
     end

   ////////////////////////////////////////////////////////////////////////////////

   wire addr_match;
   assign addr_match = { addrin[21:6], 6'b0 } == 22'o17377700 ? 1'b1 : 1'b0;
   assign decode = (reqin && addr_match) ? 1'b1 : 1'b0;

   assign dataout = (state == READ3 && busgrantin) ?
		    dma_dataout : reg_dataout;

   assign interrupt = done_intr_enb & disk_interrupt;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	addrout <= 22'h0;
	// End of automatics
     end else
       addrout <= state_ns == READ_CCW ? { disk_clp } :
		  state_ns == READ3 ? { ccw[21:8], wc } :
		  state_ns == WRITE0 ? { ccw[21:8], wc } :
		  addrout;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	reqout <= 1'h0;
	// End of automatics
     end else
       reqout <= state_ns == READ_CCW ? 1'b1 :
		 state_ns == READ3 ? 1'b1 :
		 state_ns == WRITE0 ? 1'b1 :
		 1'b0;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	writeout <= 1'h0;
	// End of automatics
     end else
       writeout <= state_ns == READ3 ? 1'b1 : 1'b0;

   reg [1:0] ack_delayed;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	ack_delayed <= 2'h0;
	// End of automatics
     end else begin
	ack_delayed[0] <= decode && ~ack_delayed[1];
	ack_delayed[1] <= ack_delayed[0];
     end

   assign ackout = ack_delayed[1];

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	busreqout <= 1'h0;
	// End of automatics
     end else
       busreqout <= state_ns == READ_CCW ? 1'b1 :
		    state_ns == READ3 ? 1'b1 :
		    state_ns == WRITE0 ? 1'b1 :
		    1'b0;

   assign decodeout = decode;

   ////////////////////////////////////////////////////////////////////////////////

   reg [23:0] lba;

   wire [17:0] cylx10;
   wire [22:0] cyl_blocks;
   wire [8:0]  head_blocks;
   wire [22:0] block_number;

   // ---!!! This could probobly be done  somewhat cleaner.

   // = (cyl * 323)
   // = (cyl * 320) + cyl + cyl + cyl
   // = (cyl * 32 * 10) + cyl + cyl + cyl
   // = ((cyl * 8) + cyl + cyl) * 32 + cyl + cyl + cyl
   assign cylx10 = { 3'b0, disk_cyl, 3'b0 } + { 6'b0, disk_cyl } + { 6'b0, disk_cyl };
   
   // (cyl * blocks/track * heads/unit) = cyl * 323
   assign cyl_blocks = { cylx10, 5'b0 } + { 11'b0, disk_cyl } + { 11'b0, disk_cyl } + { 11'b0, disk_cyl };
   
   // (head * blocks/track) = head * 17
   assign head_blocks = { disk_head, 4'b0000 } + { 4'b0000, disk_head };
   
   assign block_number = cyl_blocks + { 14'b0, head_blocks } + { 18'b0, disk_block };

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	lba <= 24'h0;
	// End of automatics
     end else
       // LBA = block#  * 2
       lba <= { block_number, 1'b0 };

   assign bd_addr = lba;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
