// AMEM --- A MEMORY
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-01 05:42:47 TK) AMEM1: Initial.
//   (1978-02-01 05:41:38 TK) AMEM0: Initial.

`timescale 1ns/1ps
`default_nettype none

module AMEM(/*AUTOARG*/
   // Outputs
   output wire [31:0] amem,
   // Inputs
   input wire clk,
   input wire reset,
   input wire [31:0] l,
   input wire [9:0] aadr,
   input wire arp,
   input wire awp
   );

   ////////////////////////////////////////////////////////////////////////////////

   localparam ADDR_WIDTH = 10;
   localparam DATA_WIDTH = 32;
   localparam MEM_DEPTH = 1024;

   ////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
   reg [31:0] ram [0:1023];
   reg [31:0] out_a;
   reg [31:0] out_b;

   assign amem = out_a;

   always @(posedge clk)
     if (1'b0) begin
	ram[aadr] <= 32'b0;
     end else if (awp) begin
	ram[aadr] <= l;
     end

   always @(posedge clk)
     if (reset)
       out_a <= 0;
     else if (arp) begin
	out_a <= ram[aadr];
     end

   always @(posedge clk)
     if (reset)
       out_b <= 0;
     else if (1'b0) begin
	out_b <= ram[aadr];
     end
`elsif ISE
   wire ena_a = arp | 1'b0;
   wire ena_b = 1'b0 | awp;

	
   ise_AMEM inst
     (
      .clka(clk),
      .ena(ena_a),
      .wea(1'b0),
      .addra(aadr),
      .dina(32'b0),
      .douta(amem),
      .clkb(clk),
      .enb(ena_b),
      .web(awp),
      .addrb(aadr),
      .dinb(l),
      .doutb()
      /*AUTOINST*/);
`else 
altera_AMEM inst (
		.rdaddress(aadr),
		.wraddress(aadr),
		.clock(clk),
		.data(l),
		.wren(awp),
		.q(amem));
`endif

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".." "../cores/xilinx")
// End:
