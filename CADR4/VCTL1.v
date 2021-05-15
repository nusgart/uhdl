// VCTL1 --- VMEMORY CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-10-25 10:08:02 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module VCTL1
  (input wire  state_alu,
   input wire  state_fetch,
   input wire  state_prefetch,
   input wire  state_write,

   input wire  ifetch,
   input wire  lcinc,
   input wire  lvmo_22,
   input wire  lvmo_23,
   input wire  memack,
   input wire  memrd,
   input wire  memwr,
   input wire  needfetch,
   output reg  memprepare,
   output wire memrq,
   output reg  memstart,
   output wire pfr, // VMA permissions (read).
   output wire pfw, // VMA permissions (write).
   output reg  vmaok, // VMA access OK.
   output wire waiting,
   output reg  wrcyc,

   input wire  clk,
   input wire  reset);

   reg	       mbusy;
   reg	       memcheck;
   reg	       rdcyc;
   wire        mfinish;
   wire        memop;

   ////////////////////////////////////////////////////////////////////////////////

   assign memop = memrd | memwr | ifetch;

   always @(posedge clk)
     if (reset)
       memprepare <= 0;
     else if (state_alu || state_write)
       memprepare <= memop;
     else
       memprepare <= 0;

   // Read VMEM.
   always @(posedge clk)
     if (reset)
       memstart <= 0;
     else if (~state_alu)
       memstart <= memprepare;
     else
       memstart <= 0;

   // Check result of VMEM.
   always @(posedge clk)
     if (reset)
       memcheck <= 0;
     else
       memcheck <= memstart;

   // VMA permissions.
   assign pfw = (lvmo_23 & lvmo_22) & wrcyc;
   assign pfr = lvmo_23 & ~wrcyc;

   always @(posedge clk)
     if (reset)
       vmaok <= 1'b0;
     else if (memcheck)
       vmaok <= pfr | pfw;

   always @(posedge clk)
     if (reset) begin
	rdcyc <= 0;
	wrcyc <= 0;
     end else if ((state_fetch || state_prefetch) && memstart && memcheck) begin
	if (memwr) begin
	   rdcyc <= 0;
	   wrcyc <= 1;
	end else begin
	   rdcyc <= 1;
	   wrcyc <= 0;
	end
     end else if ((~memrq && ~memprepare && ~memstart) || mfinish) begin
	rdcyc <= 0;
	wrcyc <= 0;
     end

   assign memrq = mbusy | (memcheck & ~memstart & (pfr | pfw));

   always @(posedge clk)
     if (reset)
       mbusy <= 0;
     else if (mfinish)
       mbusy <= 1'b0;
     else if (memcheck & (pfr | pfw))
       mbusy <= 1;

   assign mfinish = memack | reset;
   assign waiting = (memrq & mbusy) | (lcinc & needfetch & mbusy);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
