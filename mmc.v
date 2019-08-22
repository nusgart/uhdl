// mmc.v --- ---!!!

/* verilator lint_off WIDTH */

`timescale 1ns/1ps
`default_nettype none

module mmc(/*AUTOARG*/
   // Outputs
   state_out, data_out, done, mmc_cs, mmc_do, mmc_sclk,
   // Inputs
   cmd, data_in, clk, init, mmc_di, rd, reset, send, speed, stop, wr
   );

   parameter [31:0] FREQ = 40_625_000;//50000000;
   parameter [31:0] RATE_HI = 10000000;
   parameter [31:0] RATE_LO = 100000;

   input [47:0] cmd;
   input [7:0] data_in;
   wire clk, init, mmc_di, rd, reset, send, speed, stop, wr, done;
   input clk;
   input init;
   input mmc_di;
   input rd;
   input reset;
   input send;
   input speed;
   input stop;
   input wr;
   output [3:0] state_out;
   output [7:0] data_out;
   output done;
   output mmc_cs;
   output mmc_do;
   output mmc_sclk;

   ////////////////////////////////////////////////////////////////////////////////

   parameter BITWIDTH_HI = FREQ / RATE_HI;
   parameter BITWIDTH_HI_MAXCNT = BITWIDTH_HI-1;
   parameter BITWIDTH_HI_MIDCNT = BITWIDTH_HI/2;
   parameter BITWIDTH_LO = FREQ / RATE_LO;
   parameter BITWIDTH_LO_1QTR = BITWIDTH_LO/4;
   parameter BITWIDTH_LO_3QTR = BITWIDTH_LO - BITWIDTH_LO/4;
   parameter BITWIDTH_LO_MAXCNT = BITWIDTH_LO-1;
   parameter BITWIDTH_LO_MIDCNT = BITWIDTH_LO/2;
   parameter [3:0]
     s0 = 4'd0,
     s_cmd0 = 4'd4,
     s_cmd1 = 4'd5,
     s_wr0 = 4'd6,
     s_rd0 = 4'd7,
     s_init0 = 4'd8,
     s_init1 = 4'd9,
     s_stp0 = 4'd10,
     s_stp1 = 4'd11,
     s_done0 = 4'd12,
     s_done1 = 4'd13,
     s_done2 = 4'd14;

   reg [15:0] bit_time;
   reg [1:0] sclk_state;
   reg [3:0] state;
   reg [47:0] s_cmd;
   reg [7:0] bitcount;
   reg [7:0] data_out;
   reg [7:0] s_data;
   reg bit_middle, bit_end, bit_1_3_quarter;
   reg mmc_clk_hi;
   reg mmc_cs;
   reg mmc_do;
   reg mmc_sclk;
   reg s_rd, s_wr, s_send;

   wire [1:0] sclk_state_next;
   wire [31:0] bit1quarter;
   wire [31:0] bit3quarter;
   wire [31:0] bitmiddle;
   wire [31:0] bitwidth;
   wire [3:0] next_state;
   wire bit100;
   wire bit120;
   wire bit48;
   wire bit80;
   wire bit8;
   wire bit_sample;
   wire bit_shift;
   wire counting_bits;
   wire mc_done;
   wire mmc_clk;
   wire mmc_reset;
   wire neg_edge, pos_edge;
   wire sclk_assert;
   wire sclk_assert_lo, sclk_assert_hi;
   wire sclk_toggle;

   ////////////////////////////////////////////////////////////////////////////////

   assign mmc_reset = reset;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	bit_time <= 16'h0;
	// End of automatics
     end else if (bit_end || state == s0 || state == s_cmd0)
       bit_time <= 0;
     else
       bit_time <= bit_time + 16'd1;

   assign bitmiddle = mmc_clk_hi ? (BITWIDTH_HI_MIDCNT) : (BITWIDTH_LO_MIDCNT);
   assign bitwidth = mmc_clk_hi ? (BITWIDTH_HI_MAXCNT) : (BITWIDTH_LO_MAXCNT);
   assign bit1quarter = BITWIDTH_LO_1QTR;
   assign bit3quarter = BITWIDTH_LO_3QTR;

   always @(posedge clk)
     if (speed)
       mmc_clk_hi <= 1;
     else
       mmc_clk_hi <= 0;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	bit_1_3_quarter <= 1'h0;
	bit_end <= 1'h0;
	bit_middle <= 1'h0;
	// End of automatics
     end else begin
	bit_middle <= (bit_time == bitmiddle) ? 1'b1 : 1'b0;
	bit_end <= (bit_time == bitwidth) ? 1'b1 : 1'b0;
	bit_1_3_quarter <= (bit_time >= bit1quarter && bit_time <= bit3quarter) ? 1'b1 : 1'b0;
     end

   assign neg_edge = (bit_middle | bit_end) & mmc_sclk;
   assign pos_edge = (bit_middle | bit_end) & ~mmc_sclk;
   assign bit_shift = bit_end && counting_bits;

   always @(posedge clk)
     if (mmc_reset)
       state <= s0;
     else begin
	state <= next_state;
     end

   assign next_state =
		      (state == s0 && init) ? s_init0 :
		      (state == s0 && send) ? s_cmd0 :
		      (state == s0 && wr) ? s_wr0 :
		      (state == s0 && rd) ? s_rd0 :
		      (state == s0 && stop) ? s_stp0 :
		      (state == s_cmd0) ? s_cmd1 :
		      (state == s_cmd1 && bit48) ? s_done0 :
		      (state == s_wr0 && bit8) ? s_done0 :
		      (state == s_rd0 && bit8) ? s_done0 :
		      (state == s_init0 && bit80) ? s_init1 :
		      (state == s_init1 && bit100) ? s_done0 :
		      (state == s_stp0 && bit_middle) ? s_stp1 :
		      (state == s_stp1 && bit8) ? s_done0 :
		      (state == s_done0 && bit_end) ? s_done1 :
		      (state == s_done1) ? s_done2 :
		      (state == s_done2) ? s0 :
		      state;

   assign state_out = state;
   assign mc_done = state == s0;
   assign done = mc_done;
   assign bit8 = bitcount == 8;
   assign bit48 = bitcount == 48;
   assign bit80 = bitcount == 80;
   assign bit100 = bitcount == 100;
   assign counting_bits = (state >= s_cmd0 && state <= s_stp1);

   always @(posedge clk)
     if (mmc_reset)
       bitcount <= 0;
     else if (bit_end && counting_bits)
       bitcount <= bitcount + 8'b00000001;
     else if (state == s0 || state == s_done0)
       bitcount <= 0;

   always @(posedge clk)
     if (mmc_reset)
       sclk_state <= 0;
     else
       sclk_state <= sclk_state_next;

   assign sclk_toggle = counting_bits && ~(state == s_init1 || state == s_cmd0);
   assign sclk_assert_lo = sclk_toggle && bit_1_3_quarter;
   assign sclk_assert_hi = sclk_toggle && bit_middle;
   assign sclk_assert = mmc_clk_hi ? sclk_assert_hi : sclk_assert_lo;
   assign sclk_state_next =
			   (sclk_state == 0 && sclk_toggle) ? 1 :
			   (sclk_state == 1 && ~sclk_toggle) ? 0 :
			   (sclk_state == 1 && bit_middle) ? 2 :
			   (sclk_state == 2 && ~sclk_toggle) ? 0 :
			   (sclk_state == 2 && bit_end) ? 1 :
			   sclk_state;

   assign bit_sample = (mmc_clk_hi ? mmc_sclk : bit_middle) && counting_bits;

   always @(posedge clk)
     if (mmc_reset)
       mmc_sclk <= 1'b0;
     else if (sclk_assert)
       mmc_sclk <= 1;
     else
       mmc_sclk <= 0;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	data_out <= 8'h0;
	// End of automatics
     end else begin
	if (state == s0 && rd)
	  data_out <= 0;
	else if (state == s_rd0 && bit_sample)
	  data_out <= { data_out[6:0], mmc_di };
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	mmc_cs <= 1'h0;
	mmc_do <= 1'h0;
	s_cmd <= 48'h0;
	s_data <= 8'h0;
	s_rd <= 1'h0;
	s_send <= 1'h0;
	s_wr <= 1'h0;
	// End of automatics
     end else begin
	case (state)
	  s0: begin
	     if (send) begin
		s_send <= 1;
		s_cmd <= cmd;
	     end
	     if (wr) begin
		s_wr <= 1;
		s_data <= data_in;
	     end
	     if (rd)
	       s_rd <= 1;
	  end
	  s_cmd0: begin
	     mmc_cs <= 1'b0;
	     mmc_do <= s_cmd[47];
	     if (bit_shift)
	       s_cmd <= { s_cmd[46:0], 1'b0 };
	  end
	  s_cmd1: begin
	     if (next_state != s_done0)
	       mmc_do <= s_cmd[47];
	     if (bit_shift)
	       s_cmd <= { s_cmd[46:0], 1'b0 };
	  end
	  s_wr0: begin
	     if (next_state != s_done0)
	       mmc_do <= s_data[7];
	     if (bit_shift)
	       s_data <= { s_data[6:0], 1'b0 };
	  end
	  s_init0: begin
	     mmc_do <= 1'b1;
	     mmc_cs <= 1'b1;
	  end
	  s_init1:
	    mmc_do <= 1'b1;
	  s_stp0: begin
	     mmc_cs <= 1'b1;
	     mmc_do <= 1'b1;
	  end
	  s_done0: begin
	     mmc_do <= 1'b1;
	     s_rd <= 0;
	     s_wr <= 0;
	     s_send <= 0;
	  end
	  default:
	    ;
	endcase
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
