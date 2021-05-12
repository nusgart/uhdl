// DSPCTL --- DISPATCH CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-03 04:33:59 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module DSPCTL
  (input wire	     state_fetch,

   input wire [3:0]  funct,
   input wire [48:0] ir,
   input wire	     irdisp,
   output wire [6:0] dmask,
   output reg [9:0] dc,
   output wire	     dispwr,
   output wire	     dmapbenb,

   input wire	     clk,
   input wire	     reset);

   localparam	     ADDR_WIDTH = 2;
   localparam	     DATA_WIDTH = 7;
   localparam	     MEM_DEPTH = 8;

   reg [7:0]	     q;

   wire		     nc_dmask;

   ////////////////////////////////////////////////////////////////////////////////

   assign dmapbenb = ir[8] | ir[9];
   assign dispwr = irdisp & funct[2];

   always @(posedge clk)
     if (reset)
       dc <= 0;
     else if (state_fetch && irdisp)
       dc <= ir[41:32];

   wire nclk = ~clk;
   always @(posedge nclk)
     case ({1'b0, 1'b0, ir[7], ir[6], ir[5]})
       5'h00:   q = 8'h00;
       5'h01:   q = 8'h01;
       5'h02:   q = 8'h03;
       5'h03:   q = 8'h07;
       5'h04:   q = 8'h0f;
       5'h05:   q = 8'h1f;
       5'h06:   q = 8'h3f;
       5'h07:   q = 8'h7f;
       default: q = 8'h00;
     endcase

   assign {nc_dmask, dmask[6:0]} = q;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
