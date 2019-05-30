// OLORD2 --- OVERLORD
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-10-11 15:45:37 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module OLORD2(/*AUTOARG*/
   // Outputs
   boot, boot_trap, err, errhalt, reset, statstop,
   // Inputs
   clk, ext_reset, spy_in, errstop, ext_boot, ext_halt, ldmode, srun,
   stat_ovf
   );

   input wire clk;
   input wire ext_reset;

   input [15:0] spy_in;
   input wire errstop;
   input wire ext_boot;
   input wire ext_halt;
   input wire ldmode;
   input wire srun;
   input wire stat_ovf;
   output wire boot;
   output boot_trap;
   output wire err;
   output wire errhalt;
   output wire reset;
   output statstop;

   ////////////////////////////////////////////////////////////////////////////////

   reg boot_trap;
   reg halted;
   reg statstop;
   wire bus_reset;
   wire prog_boot;
   wire prog_bus_reset;
   wire prog_reset;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset) begin
	halted <= 0;
	statstop <= 0;
     end else begin
	halted <= ext_halt;
	statstop <= stat_ovf;
     end

   assign prog_reset = ldmode & spy_in[6];
   assign reset = ext_reset | prog_reset;
   assign err = halted;
   assign errhalt = errstop & err;
   assign prog_bus_reset = 0;
   assign bus_reset = prog_bus_reset | ext_reset;
   assign prog_boot = ldmode & spy_in[7];
   assign boot = ext_boot | prog_boot;

   always @(posedge clk)
     if (reset)
       boot_trap <= 0;
     else if (boot)
       boot_trap <= 1'b1;
     else if (srun)
       boot_trap <= 1'b0;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
