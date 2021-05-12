// OLORD1 --- OVERLORD
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-30 20:50:21 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module OLORD1
  (input wire	     state_fetch,

   input wire [15:0] spy_in,
   input wire	     boot,
   input wire	     errhalt,
   input wire	     ldclk,
   input wire	     ldmode,
   input wire	     ldopc,
   input wire	     ldscratch1,
   input wire	     ldscratch2,
   input wire	     set_promdisable,
   input wire	     statstop,
   input wire	     waiting,
   output reg [15:0] scratch,
   output reg	     errstop,
   output reg	     idebug,
   output reg	     lpc_hold,
   output wire	     machrun,
   output reg	     nop11,
   output reg	     opcclk,
   output reg	     opcinh,
   output reg	     promdisable,
   output reg	     promdisabled,
   output reg	     srun,
   output reg	     ssdone,
   output wire	     stat_ovf,
   output wire	     stathalt,

   input wire	     clk,
   input wire	     reset);

   reg		     ldstat;
   reg		     run;
   reg		     sstep;
   reg		     stathenb;
   reg		     step;
   reg		     trapenb;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset) begin
	promdisable <= 0;
	trapenb <= 0;
	stathenb <= 0;
	errstop <= 0;
     end else if (ldmode) begin
	promdisable <= spy_in[5];
	trapenb <= spy_in[4];
	stathenb <= spy_in[3];
	errstop <= spy_in[2];
     end else if (set_promdisable)
       promdisable <= 1;

   always @(posedge clk)
     if (reset)
       scratch <= 16'h1234;
     else if (ldscratch2 || ldscratch1)
       scratch <= spy_in;

   always @(posedge clk)
     if (reset) begin
	opcinh <= 0;
	opcclk <= 0;
	lpc_hold <= 0;
     end else if (ldopc) begin
	opcinh <= spy_in[2];
	opcclk <= spy_in[1];
	lpc_hold <= spy_in[0];
     end

   always @(posedge clk)
     if (reset) begin
	ldstat <= 0;
	idebug <= 0;
	nop11 <= 0;
	step <= 0;
     end else if (ldclk) begin
	ldstat <= spy_in[4];
	idebug <= spy_in[3];
	nop11 <= spy_in[2];
	step <= spy_in[1];
     end

   always @(posedge clk)
     if (reset)
       run <= 1'b0;
     else if (boot)
       run <= 1'b1;
     else if (ldclk)
       run <= spy_in[0];

   always @(posedge clk)
     if (reset) begin
	srun <= 1'b0;
	sstep <= 1'b0;
	ssdone <= 1'b0;
	promdisabled <= 1'b0;
     end else begin
	srun <= run;
	if (sstep == 0 && step) begin
	   sstep <= step;
	   ssdone <= 0;
	end else
	  sstep <= step;
	if (state_fetch)
	  ssdone <= sstep;
	promdisabled <= promdisable;
     end

   assign machrun = (sstep & ~ssdone) | (srun & ~errhalt & ~waiting & ~stathalt);
   assign stat_ovf = 1'b0;
   assign stathalt = statstop & stathenb;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
