// us.v --- microsecond clock

`timescale 1ns/1ps
`default_nettype none

module us
  (output reg [31:0] us_clk,

   input wire	     clk,
   input wire	     reset);

   parameter SYS_CLK = 26'd50000000;
   parameter US_CLK_RATE = 26'd1000000;
   parameter US_CLK_DIV = SYS_CLK / US_CLK_RATE;

   ////////////////////////////////////////////////////////////////////////////////

   reg [7:0]	     us_counter;
   wire [25:0]	     us_clk_div;

   assign us_clk_div = US_CLK_DIV;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	us_clk <= 32'h0;
	us_counter <= 8'h0;
	// End of automatics
     end else if (us_counter == us_clk_div[7:0]) begin
	us_counter <= 0;
	us_clk <= us_clk + 1;
     end else
       us_counter <= us_counter + 8'd1;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
