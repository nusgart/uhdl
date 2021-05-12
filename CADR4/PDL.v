// PDL --- PDL BUFFER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog; merge of PDL0, and PDL1.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-02 20:56:26 TK) PDL0: Initial.
//   (1978-02-02 20:53:20 TK) PDL1: Initial.

`timescale 1ns/1ps
`default_nettype none

module PDL
  (input wire [31:0]  l,
   input wire [9:0]   pdla,
   input wire	      prp,
   input wire	      pwp,
   output wire [31:0] pdlo,

   input wire	      clk,
   input wire	      reset);

   localparam	      ADDR_WIDTH = 10;
   localparam	      DATA_WIDTH = 32;
   localparam	      MEM_DEPTH = 1024;

   ////////////////////////////////////////////////////////////////////////////////

//`define INFER

`ifdef INFER
   reg [31:0] ram [0:1023];
   reg [31:0] out_a;

   assign pdlo = out_a;

   always @(posedge clk)
     if (pwp) begin
       ram[pdla] <= l;
     end

   always @(posedge clk)
     if (reset)
       out_a <= 0;
     else if (prp) begin
       out_a <= ram[pdla];
     end
`elsif ISE
   wire ena_a = prp | 1'b0;
   wire ena_b = 1'b0 | pwp;

   ise_PDL inst
     (
      .clka(clk),
      .ena(ena_a),
      .wea(1'b0),
      .addra(pdla),
      .dina(32'b0),
      .douta(pdlo),
      .clkb(clk),
      .enb(ena_b),
      .web(pwp),
      .addrb(pdla),
      .dinb(l),
      .doutb()
      /*AUTOINST*/);
`else
	/// TODO IMPLEMENT SRAM BASED PDL
	alt_pdl inst (
		.clock(clk),
		.rdaddress(pdla),
		.wraddress(pdla),
		.data(l),
		.q(pdlo),
		.wren(pwp));
`endif

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".." "../boards/pipistrello/cores/xilinx")
// End:
