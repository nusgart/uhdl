// block_dev_mmc.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module block_dev_mmc(/*AUTOARG*/
   // Outputs
   output wire [11:0] bd_state,
   output wire [15:0] bd_data_out,
   output wire bd_bsy,
   output wire bd_err,
   output wire bd_iordy,
   output wire bd_rdy,
   output wire mmc_cs,
   output wire mmc_do,
   output wire mmc_sclk,
   // Inputs
   input wire [15:0] bd_data_in,
   input wire [1:0] bd_cmd,
   input wire [23:0] bd_addr,
   input wire bd_rd,
   input wire bd_start,
   input wire bd_wr,
   input wire clk,
   input wire mmc_di,
   input wire mmcclk,
   input wire reset
   );

   ////////////////////////////////////////////////////////////////////////////////

   parameter
     CMD01 = 48'h400000000095,
     CMD02 = 48'h410000000001,
     CMD16 = 48'h500000000001,
     CMD17 = 48'h510000000001;
   parameter [6:0]
     s_idle = 0,
     s_busy = 1,
     s_init0 = 4,
     s_init1 = 5,
     s_init2 = 6,
     s_init3 = 7,
     s_init4 = 8,
     s_init5 = 9,
     s_read0 = 10,
     s_read1 = 11,
     s_read2 = 12,
     s_read3 = 13,
     s_read4 = 14,
     s_read5 = 15,
     s_read6 = 16,
     s_write0 = 20,
     s_write1 = 21,
     s_write2 = 22,
     s_write2aa = 19,
     s_write2ab = 17,
     s_write3 = 23,
     s_write4 = 24,
     s_write5 = 25,
     s_write5a = 18,
     s_write6 = 26,
     s_write7 = 27,
     s_done0 = 28,
     s_reset = 29,
     s_reset0 = 30,
     s_reset1 = 31,
     s_reset2 = 32,
     s_reset3 = 33,
     s_reset4 = 34,
     s_reset5 = 35,
     s_reset6 = 36,
     s_reset7 = 37,
     s_reset8 = 38,
     s_reset9 = 39,
     s_reset10 = 40,
     s_reset11 = 41,
     s_reset1a = 42,
     s_reset2a = 43,
     s_reset3a = 44,
     s_reset4a = 45,
     s_reset5a = 46,
     s_reset6a = 47,
     s_reset7a = 48,
     s_reset8a = 49,
     s_reset9a = 50,
     s_reset10a = 51,
     s_init0a = 52,
     s_init1a = 53,
     s_init2a = 54,
     s_init4a = 55,
     s_init5a = 56,
     s_read0a = 57,
     s_read1a = 58,
     s_read3a = 59,
     s_read4a = 60,
     s_read5a = 61,
     s_write1a = 62,
     s_write2a = 63,
     s_write3a = 64,
     s_write4a = 65,
     s_write5aa = 66,
     s_write5b = 67,
     s_write6a = 68;

   reg [15:0] data_hold;
   reg [15:0] mmc_hold;
   reg [1:0] bc;
   reg [1:0] bd_cmd_hold;
   reg [1:0] r_bd_cmd;
   reg [31:0] lba32;
   reg [47:0] mmc_cmd;
   reg [6:0] state;
   reg [6:0] state_next;
   reg [7:0] mmc_in;
   reg [7:0] wc;
   reg clear_bc;
   reg clear_err;
   reg clear_wc;
   reg err;
   reg inc_bc;
   reg inc_lba;
   reg inc_wc;
   reg inited;
   reg mmc_hispeed;
   reg mmc_init;
   reg mmc_lospeed;
   reg mmc_rd;
   reg mmc_send;
   reg mmc_speed;
   reg mmc_stop;
   reg mmc_wr;
   reg r_bd_start;
   reg set_err;
   reg set_inited;

   wire [3:0] mmc_state;
   wire [4:0] mmc_active;
   wire [7:0] mmc_out;
   wire mmc_done;

   /*AUTOWIRE*/
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   mmc_wrapper mmc_wrapper
     (
      .mmc_clk(mmcclk),
      .speed(mmc_speed),
      .wr(mmc_wr),
      .rd(mmc_rd),
      .init(mmc_init),
      .send(mmc_send),
      .stop(mmc_stop),
      .cmd(mmc_cmd),
      .data_in(mmc_in),
      .data_out(mmc_out),
      .done(mmc_done),
      .state_out(mmc_state),
      /*AUTOINST*/
      // Outputs
      .mmc_cs				(mmc_cs),
      .mmc_do				(mmc_do),
      .mmc_sclk				(mmc_sclk),
      // Inputs
      .clk				(clk),
      .mmc_di				(mmc_di),
      .reset				(reset));

   assign bd_iordy = (state == s_read2) ||
		     (state == s_write2aa) ||
		     (state == s_write2ab);
   assign bd_rdy =
		  (state == s_idle) ||
		  (state == s_read0) || (state == s_read1) || (state == s_read2) ||
		  (state == s_write0) || (state == s_write1) ||
		  (state == s_done0);

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	data_hold <= 16'h0;
	// End of automatics
     end else if (state == s_write0 && bd_wr) begin
	data_hold <= bd_data_in;
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	mmc_hold <= 16'h0;
	// End of automatics
     end else if (mmc_done) begin
	if (state == s_read0a)
	  mmc_hold[7:0] <= mmc_out;
	else if (state == s_read1a)
	  mmc_hold[15:8] <= mmc_out;
	else if (state == s_reset2 || state == s_reset4 || state == s_reset6 ||
		 state == s_init2 || state == s_write5 || state == s_write5a)
	  mmc_hold[7:0] <= mmc_out;
     end

   assign bd_data_out = mmc_hold;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	wc <= 8'h0;
	// End of automatics
     end else if (clear_wc)
       wc <= 8'b0;
     else if (inc_wc)
       wc <= wc + 8'b00000001;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	bc <= 2'h0;
	// End of automatics
     end else if (clear_bc)
       bc <= 2'b0;
     else if (inc_bc)
       bc <= bc + 2'b01;

   assign bd_bsy = state != s_idle ? 1'b1 : 1'b0;
   assign bd_err = err;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	lba32 <= 32'h0;
	// End of automatics
     end else begin
	if (inc_lba)
	  lba32 <= lba32 + 32'd512;
	else if (bd_start)
	  lba32 <= { bd_addr[22:0], 9'b0 };
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	r_bd_cmd <= 2'h0;
	r_bd_start <= 1'h0;
	// End of automatics
     end else begin
	r_bd_cmd <= bd_cmd;
	r_bd_start <= bd_start;
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	inited <= 1'h0;
	// End of automatics
     end else if (set_inited)
       inited <= 1;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	bd_cmd_hold <= 2'h0;
	// End of automatics
     end else if (bd_start)
       bd_cmd_hold <= r_bd_cmd;

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

   always @(posedge clk)
     if (reset)
       state <= s_idle;
     else begin
		 state <= state_next;
     end

   assign mmc_active = { mmc_speed, mmc_state };
   assign bd_state = { mmc_active, state };

   always @(state or r_bd_cmd or bd_cmd_hold or r_bd_start or bd_rd or bd_wr or mmc_done or mmc_out or mmc_hold or bd_data_out) begin
      state_next = state;
      mmc_cmd = 0;
      mmc_rd = 0;
      mmc_wr = 0;
      mmc_init = 0;
      mmc_send = 0;
      mmc_stop = 0;
      mmc_in = 0;
      mmc_hispeed = 0;
      mmc_lospeed = 0;
      clear_err = 0;
      set_err = 0;
      clear_wc = 0;
      inc_wc = 0;
      clear_bc = 0;
      inc_bc = 0;
      inc_lba = 0;
      set_inited = 0;
      case (state)
	s_idle: begin
	   if (r_bd_start) begin
	      case (r_bd_cmd)
		2'b00: begin
		   state_next = s_reset;
		end
		2'b01: begin
		   state_next = s_init0;
		end
		2'b10: begin
		   state_next = s_init0;
		end
		2'b11:
		  ;
	      endcase
	   end
	end
	s_busy: begin
	   state_next = s_idle;
	end
	s_reset: begin
	   mmc_lospeed = 1;
	   mmc_init = 1;
	   if (~mmc_done)
	     state_next = s_reset0;
	end
	s_reset0: begin
	   if (mmc_done)
	     state_next = s_reset1;
	end
	s_reset1: begin
	   mmc_send = 1;
	   mmc_cmd = CMD01;
	   if (~mmc_done)
	     state_next = s_reset1a;
	end
	s_reset1a: begin
	   if (mmc_done)
	     state_next = s_reset2;
	end
	s_reset2: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_reset2a;
	end
	s_reset2a: begin
	   if (mmc_done) begin
	      if (mmc_out == 8'h01)
		state_next = s_reset3;
	      else if (mmc_out[7] == 1'b0)
		state_next = s_reset;
	      else
		state_next = s_reset2;
	   end
	end
	s_reset3: begin
	   mmc_stop = 1;
	   if (~mmc_done)
	     state_next = s_reset3a;
	end
	s_reset3a: begin
	   if (mmc_done)
	     state_next = s_reset4;
	end
	s_reset4: begin
	   mmc_send = 1;
	   mmc_cmd = CMD02;
	   if (~mmc_done)
	     state_next = s_reset4a;
	end
	s_reset4a: begin
	   if (mmc_done)
	     state_next = s_reset5;
	end
	s_reset5: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_reset5a;
	end
	s_reset5a: begin
	   if (mmc_done) begin
	      if (mmc_out == 8'h00)
		state_next = s_reset7;
	      else if (mmc_out != 8'hff)
		state_next = s_reset6;
	      else
		state_next = s_reset5;
	   end
	end
	s_reset6: begin
	   mmc_stop = 1;
	   if (~mmc_done)
	     state_next = s_reset6a;
	end
	s_reset6a: begin
	   if (mmc_done)
	     state_next = s_reset4;
	end
	s_reset7: begin
	   mmc_stop = 1;
	   if (~mmc_done)
	     state_next = s_reset7a;
	end
	s_reset7a: begin
	   if (mmc_done)
	     state_next = s_reset8;
	end
	s_reset8: begin
	   mmc_hispeed = 1;
	   mmc_send = 1;
	   mmc_cmd = { 8'h50, 32'd512, 8'h01 };
	   if (~mmc_done)
	     state_next = s_reset8a;
	end
	s_reset8a: begin
	   if (mmc_done)
	     state_next = s_reset9;
	end
	s_reset9: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_reset9a;
	end
	s_reset9a: begin
	   if (mmc_done) begin
	      if (mmc_out == 8'h00)
		state_next = s_reset10;
	      else
		state_next = s_reset9;
	   end
	end
	s_reset10: begin
	   mmc_stop = 1;
	   if (~mmc_done)
	     state_next = s_reset10a;
	end
	s_reset10a: begin
	   if (mmc_done)
	     state_next = s_reset11;
	end
	s_reset11: begin
	   set_inited = 1;
	   if (~inited && bd_cmd_hold != 2'b00)
	     state_next = s_init0;
	   else
	     state_next = s_busy;
	end
	s_init0: begin
	   if (~inited)
	     state_next = s_reset;
	   else
	     begin
		mmc_send = 1;
		mmc_cmd = { 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff };
		if (~mmc_done)
		  state_next = s_init0a;
	     end
	end
	s_init0a: begin
	   if (mmc_done)
	     state_next = s_init1;
	end
	s_init1: begin
	   mmc_send = 1;
	   mmc_cmd = bd_cmd_hold == 2'b10 ? { 8'h58, lba32, 8'h01 } :
		     bd_cmd_hold == 2'b01 ? { 8'h51, lba32, 8'h01 } :
		     48'b0;
	   if (~mmc_done)
	     state_next = s_init1a;
	end
	s_init1a: begin
	   if (mmc_done)
	     state_next = s_init2;
	end
	s_init2: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_init2a;
	end
	s_init2a: begin
	   if (mmc_done) begin
	      if (mmc_out == 8'hff)
		state_next = s_init2;
	      else if (mmc_out == 8'h00)
		state_next = s_init3;
	      else begin
		 set_err = 1;
		 state_next = s_done0;
	      end
	   end
	end
	s_init3: begin
	   clear_wc = 1;
	   if (bd_cmd_hold == 2'b10)
	     state_next = s_init5;
	   else if (bd_cmd_hold == 2'b01)
	     state_next = s_init4;
	end
	s_init4: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_init4a;
	end
	s_init4a: begin
	   if (mmc_done) begin
	      if (mmc_out == 8'hff)
		state_next = s_init4;
	      else if (mmc_out == 8'hfe)
		state_next = s_read0;
	   end
	end
	s_init5: begin
	   mmc_wr = 1;
	   mmc_in = 8'hfe;
	   if (~mmc_done)
	     state_next = s_init5a;
	end
	s_init5a: begin
	   if (mmc_done)
	     state_next = s_write0;
	end
	s_read0: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_read0a;
	end
	s_read0a: begin
	   if (mmc_done)
	     state_next = s_read1;
	end
	s_read1: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_read1a;
	end
	s_read1a: begin
	   if (mmc_done)
	     state_next = s_read2;
	end
	s_read2: begin
	   if (bd_rd) begin
	      inc_wc = 1;
	      if (wc == 8'hff)
		state_next = s_read3;
	      else
		state_next = s_read0;
	   end
	end
	s_read3: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_read3a;
	end
	s_read3a: begin
	   if (mmc_done)
	     state_next = s_read4;
	end
	s_read4: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_read4a;
	end
	s_read4a: begin
	   if (mmc_done)
	     state_next = s_read5;
	end
	s_read5: begin
	   mmc_stop = 1;
	   if (~mmc_done)
	     state_next = s_read5a;
	end
	s_read5a: begin
	   if (mmc_done)
	     state_next = s_read6;
	end
	s_read6: begin
	   inc_bc = 1;
	   inc_lba = 1;
	   if (bc == 2'h01)
	     state_next = s_done0;
	   else
	     state_next = s_init0;
	end
	s_write0: begin
	   if (bd_wr)
	     state_next = s_write1;
	end
	s_write1: begin
	   mmc_wr = 1;
	   mmc_in = data_hold[7:0];
	   if (~mmc_done)
	     state_next = s_write1a;
	end
	s_write1a: begin
	   if (mmc_done)
	     state_next = s_write2;
	end
	s_write2: begin
	   mmc_wr = 1;
	   mmc_in = data_hold[15:8];
	   if (~mmc_done)
	     state_next = s_write2a;
	end
	s_write2a: begin
	   if (mmc_done) begin
	      inc_wc = 1;
	      if (wc == 8'hff)
		state_next = s_write2ab;
	      else
		state_next = s_write2aa;
	   end
	end
	s_write2aa: begin
	   if (~bd_wr)
	     state_next = s_write0;
	end
	s_write2ab: begin
	   if (~bd_wr)
	     state_next = s_write3;
	end
	s_write3: begin
	   mmc_wr = 1;
	   mmc_in = 8'h0;
	   if (~mmc_done)
	     state_next = s_write3a;
	end
	s_write3a: begin
	   if (mmc_done)
	     state_next = s_write4;
	end
	s_write4: begin
	   mmc_wr = 1;
	   mmc_in = 8'h0;
	   if (~mmc_done)
	     state_next = s_write4a;
	end
	s_write4a: begin
	   if (mmc_done)
	     state_next = s_write5;
	end
	s_write5: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_write5a;
	end
	s_write5a: begin
	   if (mmc_done) begin
	      if (mmc_out[4] == 1'b0 && mmc_out[0] == 1'b1) begin
		 if (mmc_out[3:1] != 3'b010)
		   set_err = 1;
	      end
	      state_next = s_write5aa;
	   end
	end
	s_write5aa: begin
	   mmc_rd = 1;
	   if (~mmc_done)
	     state_next = s_write5b;
	end
	s_write5b: begin
	   if (mmc_done) begin
	      if (mmc_out != 8'h00)
		state_next = s_write6;
	      else
		state_next = s_write5aa;
	   end
	end
	s_write6: begin
	   mmc_stop = 1;
	   if (~mmc_done)
	     state_next = s_write6a;
	end
	s_write6a: begin
	   if (mmc_done)
	     state_next = s_write7;
	end
	s_write7: begin
	   inc_bc = 1;
	   inc_lba = 1;
	   if (bc == 2'h01)
	     state_next = s_done0;
	   else
	     state_next = s_init0;
	end
	s_done0: begin
	   state_next = s_idle;
	   clear_err = 1;
	   clear_bc = 1;
	end
	default: begin
	end
      endcase
   end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	mmc_speed <= 1'h0;
	// End of automatics
     end else if (mmc_hispeed)
       mmc_speed <= 1;
     else if (mmc_lospeed)
       mmc_speed <= 0;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
