// PDLPTR --- PDL INDEX AND POINTER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-03 03:26:25 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module PDLPTR(/*AUTOARG*/
   // Outputs
   pdlidx, pdlptr, pidrive, ppdrive,
   // Inputs
   clk, reset, state_alu, state_fetch, state_read, state_write, ob,
   destpdlp, destpdlx, pdlcnt, srcpdlidx, srcpdlpop, srcpdlptr
   );

   input clk;
   input reset;

   input state_alu;
   input state_fetch;
   input state_read;
   input state_write;

   input [31:0] ob;
   input destpdlp;
   input destpdlx;
   input pdlcnt;
   input srcpdlidx;
   input srcpdlpop;
   input srcpdlptr;
   output [9:0] pdlidx;
   output [9:0] pdlptr;
   output pidrive;
   output ppdrive;

   ////////////////////////////////////////////////////////////////////////////////

   reg [9:0] pdlidx;
   reg [9:0] pdlptr;

   ////////////////////////////////////////////////////////////////////////////////

   assign pidrive = srcpdlidx & (state_alu || state_write || state_fetch);
   assign ppdrive = srcpdlptr & (state_alu || state_write || state_fetch);

   always @(posedge clk)
     if (reset)
       pdlidx <= 0;
     else if (state_write && destpdlx)
       pdlidx <= ob[9:0];

   always @(posedge clk)
     if (reset)
       pdlptr <= 0;
     else if (state_read) begin
	if (~destpdlp && pdlcnt && ~srcpdlpop)
	  pdlptr <= pdlptr + 10'd1;
     end else if (state_fetch) begin
	if (destpdlp)
	  pdlptr <= ob[9:0];
	else if (pdlcnt && srcpdlpop)
	  pdlptr <= pdlptr - 10'd1;
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
