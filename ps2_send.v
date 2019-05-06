// ps2_send.v --- ---!!!

/* verilator lint_off WIDTH */

`timescale 1ns/1ps
`default_nettype none

module ps2_send(/*AUTOARG*/
   // Outputs
   busy, rdy, ps2_clk, ps2_data,
   // Inputs
   clk, reset, code, send
   );

   input clk;
   input reset;
   input [7:0] code;
   input send;
   output busy;
   output rdy;
   output ps2_clk;
   output ps2_data;

   ////////////////////////////////////////////////////////////////////////////////

   parameter FREQ = 25000;
   parameter PS2_FREQ = 10;
   parameter DELAY = FREQ / PS2_FREQ;

   reg [4:0] state;
   reg [15:0] delay;
   reg [10:0] ps2_out;

   wire delay_done;
   wire parity;

   /*AUTOWIRE*/
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   assign delay_done = delay == 0;
   assign parity = ^code;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	delay <= 16'h0;
	// End of automatics
     end else begin
	delay <=
		(state == 0 || delay_done) ? DELAY :
		(delay != 0) ? delay - 1 :
		delay;
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	state <= 5'h0;
	// End of automatics
     end else begin
	state <=
		(state == 22) ? 0 :
		(state == 0 && send) ? 1 :
		(state != 0 && delay_done) ? state + 1 :
		state;
     end

   assign busy = state != 0;
   assign rdy = state == 0;
   assign ps2_clk = ~state[0];

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	ps2_out <= 11'h0;
	// End of automatics
     end else if (state == 0)
       ps2_out <= { 1'b1, parity, code, 1'b0 };
     else if (delay_done && ~state[0])
       ps2_out <= { 1'b0, ps2_out[10:1] };

   assign ps2_data = state ? ps2_out[0] : 1'b1;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
