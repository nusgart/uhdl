// mmc_dpi.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module mmc_dpi(/*AUTOARG*/
   // Outputs
   mmc_do,
   // Inputs
   clk, mmc_sclk, mmc_cs, mmc_di
   );

   input clk;

   input mmc_sclk;
   input mmc_cs;
   input mmc_di;
   output mmc_do;

   ////////////////////////////////////////////////////////////////////////////////

   int ddo;
   wire [31:0] ddoo = ddo;

   import "DPI-C" function void mmc_dpi(input int m_di,
					output int m_do,
					input int m_cs,
					input int m_sclk);

   always @(posedge clk)
     mmc_dpi({31'b0, mmc_di}, ddo, {31'b0, mmc_cs}, {31'b0, mmc_sclk});

   assign mmc_do = ddoo[0];

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
