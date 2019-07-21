// DRAM --- DISPATCH RAM
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog; merge of DRAM0,
//   DRAM1, and DRAM2.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-16 05:07:49 TK) DRAM0: Initial.
//   (1978-08-16 05:09:51 TK) DRAM1: Initial.
//   (1978-08-16 05:10:33 TK) DRAM2: Initial.

`timescale 1ns/1ps
`default_nettype none

module DRAM(/*AUTOARG*/
   // Outputs
   dpc, dn, dp, dr,
   // Inputs
   clk, reset, state_prefetch, state_write, vmo, a, r, ir, dmask,
   dispwr
   );

   input wire clk;
   input wire reset;

   input wire state_prefetch;
   input wire state_write;

   input [23:0] vmo;
   input [31:0] a;
   input [31:0] r;
   input [48:0] ir;
   input [6:0] dmask;
   input wire dispwr;
   output [13:0] dpc;
   output wire dn;
   output wire dp;
   output wire dr;

   ////////////////////////////////////////////////////////////////////////////////

   localparam ADDR_WIDTH = 11;
   localparam DATA_WIDTH = 17;
   localparam MEM_DEPTH = 2048;

   wire [10:0] dadr;
   wire daddr0;
   wire dwe;

   ////////////////////////////////////////////////////////////////////////////////

   assign daddr0 = (ir[8] & vmo[18]) | (ir[9] & vmo[19]) | (dmask[0] & r[0]) | (ir[12]);
   assign dadr = {ir[22:13], daddr0} | ({4'b0000, dmask[6:1], 1'b0} & {4'b0000, r[6:1], 1'b0});
   assign dwe = dispwr & state_write;
//`define INFER
`ifdef INFER
   reg [16:0] ram [0:2047];
   reg [16:0] out_a;

   assign {dr,dp,dn,dpc} = out_a;


   always @(posedge clk)
     if (1'b0) begin
       ram[dadr] <= 17'b0;
     end else if (dwe) begin
       ram[dadr] <= a[16:0];
     end

   always @(posedge clk)
     if (reset)
       out_a <= 0;
     else if (~state_prefetch && ~dwe) begin
       out_a <= ram[dadr];
     end

`elsif ISE
   wire ena_a = ~state_prefetch && ~dwe | 1'b0;
   wire ena_b = 1'b0 | dwe;

   ise_DRAM inst
     (
      .clka(clk),
      .ena(ena_a),
      .wea(1'b0),
      .addra(dadr),
      .dina(17'b0),
      .douta({dr, dp, dn, dpc}),
      .clkb(clk),
      .enb(ena_b),
      .web(dwe),
      .addrb(dadr),
      .dinb(a[16:0]),
      .doutb()
      /*AUTOINST*/);
`else
altera_DRAM inst(
	.clock(clk),
	.data(a[16:0]),
	.rdaddress(dadr),
	.wraddress(dadr),
	.wren(dwe),
	.q({dr, dp, dn, dpc})
);
`endif

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".." "../cores/xilinx")
// End:
