// uart.v --- ---!!!

/* verilator lint_off WIDTH */

`timescale 1ns/1ps
`default_nettype none

module uart(/*AUTOARG*/
   // Outputs
   rx_data, ld_tx_ack, rx_ack, rx_empty, tx_empty, tx_out,
   // Inputs
   tx_data, clk, ld_tx_req, reset, rx_enable, rx_in, rx_req,
   tx_enable
   );

   parameter [31:0] FREQ = 50000000;
   parameter [31:0] RATE = 115200;

   input [7:0] tx_data;
   input clk;
   input ld_tx_req;
   input reset;
   input rx_enable;
   input rx_in;
   input rx_req;
   input tx_enable;
   output [7:0] rx_data;
   output ld_tx_ack;
   output rx_ack;
   output rx_empty;
   output tx_empty;
   output tx_out;

   ////////////////////////////////////////////////////////////////////////////////

   parameter BITWIDTH = FREQ / RATE;

   reg [15:0] rx_bit_time;
   reg [15:0] tx_bit_time;
   reg [1:0] rx_ld_state;
   reg [1:0] tx_ld;
   reg [3:0] rx_bit_cnt;
   reg [3:0] tx_bit_cnt;
   reg [7:0] rx_data;
   reg [7:0] rx_reg;
   reg [7:0] tx_reg;
   reg rx_bit_middle, rx_bit_end;
   reg rx_busy;
   reg rx_d1;
   reg rx_d2;
   reg rx_empty;
   reg rx_frame_err;
   reg rx_over_run;
   reg rx_sampled;
   reg rx_start_bit;
   reg tx_bit_start, tx_bit_end;
   reg tx_empty;
   reg tx_out;
   reg tx_over_run;

   wire [1:0] rx_ld_next;
   wire [1:0] tx_ld_next;
   wire ld_tx_data;
   wire rx_waiting;

   /*AUTOWIRE*/
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   initial begin
      rx_ld_state = 0;
      tx_ld = 0;
   end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rx_ld_state <= 2'h0;
	// End of automatics
     end else
       rx_ld_state <= rx_ld_next;

   assign rx_ld_next =
		      (rx_ld_state == 0 && rx_req) ? 2'd1 :
		      (rx_ld_state == 1 && ~rx_req) ? 2'd0 :
		      (rx_ld_state == 1 && rx_req) ? 2'd2 :
		      (rx_ld_state == 2 && ~rx_req) ? 2'd0 :
		      rx_ld_state;
   assign rx_waiting = (rx_ld_state == 1);
   assign rx_ack = (rx_ld_state == 2);

   always @(posedge clk)
     if (reset) begin
	rx_bit_middle <= 0;
	rx_bit_end <= 0;
     end else begin
	rx_bit_middle <= rx_bit_time == BITWIDTH/2 ? 1'b1 : 1'b0;
	rx_bit_end <= rx_bit_time == BITWIDTH - 1 ? 1'b1 : 1'b0;
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	tx_ld <= 2'h0;
	// End of automatics
     end else
       tx_ld <= tx_ld_next;

   assign tx_ld_next =
		      (tx_ld == 0 && ld_tx_req) ? 2'd1 :
		      (tx_ld == 1) ? 2'd2 :
		      (tx_ld == 2 && ~ld_tx_req) ? 2'd3 :
		      (tx_ld == 3 && tx_empty) ? 2'd0 :
		      tx_ld;
   assign ld_tx_ack = tx_ld == 2;
   assign ld_tx_data = tx_ld == 1;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	tx_bit_end <= 1'h0;
	tx_bit_start <= 1'h0;
	// End of automatics
     end else begin
	tx_bit_start <= (tx_bit_time == 0) ? 1'b1 : 1'b0;
	tx_bit_end <= (tx_bit_time == BITWIDTH - 1) ? 1'b1 : 1'b0;
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rx_bit_cnt <= 4'h0;
	rx_bit_time <= 16'h0;
	rx_busy <= 1'h0;
	rx_d1 <= 1'h0;
	rx_d2 <= 1'h0;
	rx_data <= 8'h0;
	rx_empty <= 1'h0;
	rx_frame_err <= 1'h0;
	rx_over_run <= 1'h0;
	rx_reg <= 8'h0;
	rx_sampled <= 1'h0;
	rx_start_bit <= 1'h0;
	// End of automatics
     end else begin
	if (rx_waiting && ~rx_empty) begin
	   rx_data <= rx_reg;
	   rx_empty <= 1;
	end
	if (rx_enable) begin
	   if (!rx_bit_end)
	     rx_bit_time <= rx_bit_time + 16'h0001;
	   else
	     rx_bit_time <= 0;
	   rx_d1 <= rx_in;
	   rx_d2 <= rx_d1;
	   if (!rx_busy && !rx_start_bit && !rx_d2) begin
	      rx_start_bit <= 1;
	      rx_bit_time <= 0;
	   end
	   if (rx_bit_middle)
	     rx_sampled <= 1'b1;
	   else
	     rx_sampled <= 1'b0;
	   if (rx_sampled) begin
	      if (!rx_busy && !rx_d2) begin
		 rx_start_bit <= 0;
		 rx_busy <= 1;
		 rx_bit_cnt <= 0;
	      end
	      if (rx_busy) begin
		 rx_bit_cnt <= rx_bit_cnt + 4'd1;
		 if (rx_bit_cnt < 8)
		   rx_reg[rx_bit_cnt] <= rx_d2;
		 if (rx_bit_cnt == 4'd9) begin
		    rx_busy <= 0;
		    if (rx_d2 == 0)
		      rx_frame_err <= 1;
		    else begin
		       rx_empty <= 0;
		       rx_frame_err <= 0;
		       rx_over_run <= (rx_empty) ? 1'b0 : 1'b1;
		    end
		 end
	      end
	   end
	end
	if (!rx_enable) begin
	   rx_start_bit <= 0;
	   rx_busy <= 0;
	end
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	tx_bit_cnt <= 4'h0;
	tx_bit_time <= 16'h0;
	tx_empty <= 1'h0;
	tx_out <= 1'h0;
	tx_over_run <= 1'h0;
	tx_reg <= 8'h0;
	// End of automatics
     end else begin
	if (ld_tx_data) begin
	   if (!tx_empty)
	     tx_over_run <= 1;
	   else begin
	      tx_reg <= tx_data;
	      tx_empty <= 0;
	   end
	end else if (tx_enable && !tx_empty) begin
	   if (tx_bit_end) begin
	      tx_bit_time <= 0;
	      tx_bit_cnt <= tx_bit_cnt + 4'b1;
	      if (tx_bit_cnt == 4'd10) begin
		 tx_empty <= 1;
		 tx_bit_cnt <= 0;
	      end
	   end else begin
	      tx_bit_time <= tx_bit_time + 16'h0001;
	      if (tx_bit_start) begin
		 case (tx_bit_cnt)
		   4'd0: tx_out <= 1'b0;
		   4'd1: tx_out <= tx_reg[0];
		   4'd2: tx_out <= tx_reg[1];
		   4'd3: tx_out <= tx_reg[2];
		   4'd4: tx_out <= tx_reg[3];
		   4'd5: tx_out <= tx_reg[4];
		   4'd6: tx_out <= tx_reg[5];
		   4'd7: tx_out <= tx_reg[6];
		   4'd8: tx_out <= tx_reg[7];
		   4'd9: tx_out <= 1'b1;
		   4'd10: tx_out <= 1'b1;
		   default: tx_out <= tx_out;
		 endcase
	      end
	   end
	end
	if (!tx_enable)
	  tx_bit_cnt <= 0;
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
