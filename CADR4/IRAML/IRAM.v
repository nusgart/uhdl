// IRAM --- RAM
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog; merge of IRAM00,
//	IRAM01, IRAM02, IRAM03, IRAM10, IRAM11, IRAM12, IRAM13, IRAM20,
//	IRAM21, IRAM22, IRAM23, IRAM30, IRAM31, IRAM32, and IRAM33.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-17 14:18:27 TK) IRAM33: Initial.
//   (1978-08-17 14:17:51 TK) IRAM32: Initial.
//   (1978-08-17 14:17:24 TK) IRAM31: Initial.
//   (1978-08-17 14:17:08 TK) IRAM30: Initial.
//   (1978-08-17 14:16:37 TK) IRAM23: Initial.
//   (1978-08-17 14:16:08 TK) IRAM22: Initial.
//   (1978-08-17 14:15:30 TK) IRAM21: Initial.
//   (1978-08-17 14:15:00 TK) IRAM20: Initial.
//   (1978-08-17 14:14:26 TK) IRAM13: Initial.
//   (1978-08-17 14:13:56 TK) IRAM12: Initial.
//   (1978-08-17 14:13:12 TK) IRAM11: Initial.
//   (1978-08-17 14:12:41 TK) IRAM10: Initial.
//   (1978-08-17 14:11:01 TK) IRAM03: Initial.
//   (1978-08-17 14:10:13 TK) IRAM02: Initial.
//   (1978-08-17 14:09:27 TK) IRAM01: Initial.
//   (1978-08-17 14:08:30 TK) IRAM00: Initial.

`timescale 1ns/1ps
`default_nettype none

module IRAM(/*AUTOARG*/
   // Outputs
   iram,
   // Inputs
   clk, reset, pc, iwr, iwe
   );

   input clk;
   input reset;

   input [13:0] pc;
   input [48:0] iwr;
   input iwe;
   output [48:0] iram;

   ////////////////////////////////////////////////////////////////////////////////

   localparam ADDR_WIDTH = 14;
   localparam DATA_WIDTH = 49;
   localparam MEM_DEPTH = 16384;

   ////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
   reg [48:0] ram [0:MEM_DEPTH-1];
   reg [48:0] out_a;

   assign iram = out_a;


   /* synthesis syn_ramstyle="block_ram" */
   always @(posedge clk)
     if (iwe) begin
	ram[pc] <= iwr;
     end

   always @(posedge clk)
     if (1'b1) begin
     end
`else
   wire ena_a = 1'b1 | iwe;

   ise_IRAM inst
     (
      .clka(clk),
      .ena(ena_a),
      .wea(iwe),
      .addra(pc),
      .dina(iwr),
      .douta(iram)
      /*AUTOINST*/);
`endif

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../.." "../../cores/xilinx")
// End:
