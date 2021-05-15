// hz60.v --- 60Hz clock

`timescale 1ns/1ps
`default_nettype none

module hz60
  (input wire 	     hz60_enabled,
   output wire 	     hz60_clk_fired,
   output reg [31:0] hz60_clk,

   input wire 	     clk,
   input wire 	     reset);

   parameter SYS_CLK = 26'd40_625_000;//26'd50000000;
   parameter HZ60_CLK_RATE = 26'd60;
   parameter HZ60_CLK_DIV = SYS_CLK / HZ60_CLK_RATE;

   ////////////////////////////////////////////////////////////////////////////////

   reg [19:0] 	     hz60_counter;
   wire [25:0] 	     hz60_clk_div = HZ60_CLK_DIV;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	hz60_clk <= 32'h0;
	hz60_counter <= 20'h0;
	// End of automatics
     end else if (hz60_enabled) begin
	if (hz60_clk_fired) begin
	   hz60_counter <= 0;
	   hz60_clk <= hz60_clk + 1;
	end else
	  hz60_counter <= hz60_counter + 20'd1;
     end

   assign hz60_clk_fired = hz60_counter == hz60_clk_div[19:0];

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
