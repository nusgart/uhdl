// MD --- MEMORY DATA REGISTER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-16 05:16:20 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module MD(/*AUTOARG*/
   // Outputs
   md, mddrive, mdgetspar,
   // Inputs
   clk, reset, state_alu, state_fetch, state_mmu, state_write, spy_in,
   mds, destmdr, ldmdh, ldmdl, loadmd, memrq, srcmd
   );

   input clk;
   input reset;

   input state_alu;
   input state_fetch;
   input state_mmu;
   input state_write;

   input [15:0] spy_in;
   input [31:0] mds;
   input destmdr;
   input ldmdh;
   input ldmdl;
   input loadmd;
   input memrq;
   input srcmd;
   output [31:0] md;
   output mddrive;
   output mdgetspar;

   ////////////////////////////////////////////////////////////////////////////////

   reg [31:0] md;
   reg mdhaspar;
   reg mdpar;
   wire ignpar;
   wire mdclk;

   ////////////////////////////////////////////////////////////////////////////////

   assign mdgetspar = ~destmdr & ~ignpar;
   assign ignpar = 1'b0;
   assign mdclk = loadmd | destmdr;

   always @(posedge clk)
     if (reset) begin
	md <= 32'b0;
	mdhaspar <= 1'b0;
	mdpar <= 1'b0;
     end else if ((loadmd && memrq) || (state_alu && destmdr)) begin
	md <= mds;
	mdhaspar <= mdgetspar;
     end else if (ldmdh)
       md[31:16] <= spy_in;
     else if (ldmdl)
       md[15:0] <= spy_in;

   assign mddrive = srcmd & (state_alu || state_write || state_mmu || state_fetch);
   assign mdgetspar = ~destmdr & ~ignpar;
   assign ignpar = 1'b0;
   assign mdclk = loadmd | destmdr;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
