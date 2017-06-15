// OLORD2
//
// TK		CADR	OVERLORD

module OLORD2(clk, reset, statstop, err, errhalt, boot, boot_trap, ldmode, spy_in, errstop, ext_reset, ext_boot, srun, ext_halt, stat_ovf);

   input clk;
   input ext_reset;

   input [15:0] spy_in;
   input	errstop;
   input	ext_boot;
   input	ext_halt;
   input	ldmode;
   input	srun;
   input	stat_ovf;
   output	boot;
   output	boot_trap;
   output	err;
   output	errhalt;
   output	reset;
   output	statstop;

   ////////////////////////////////////////////////////////////////////////////////

   reg		boot_trap;
   reg		halted;
   reg		statstop;
   wire		bus_reset;
   wire		prog_boot;
   wire		prog_bus_reset;
   wire		prog_reset;

   always @(posedge clk)
     if (reset)
       begin
	  halted <= 0;
	  statstop <= 0;
       end
     else
       begin
	  halted <= ext_halt;
	  statstop <= stat_ovf;
       end

   assign prog_reset = ldmode & spy_in[6];

   assign reset = ext_reset | prog_reset;

   assign err = halted;

   assign errhalt = errstop & err;

   // external
   assign prog_bus_reset = 0;

  assign bus_reset  = prog_bus_reset | ext_reset;

   // external

   assign prog_boot = ldmode & spy_in[7];

   assign boot  = ext_boot | prog_boot;

   always @(posedge clk)
     if (reset)
       boot_trap <= 0;
     else
       if (boot)
	 boot_trap <= 1'b1;
       else
	 if (srun)
	   boot_trap <= 1'b0;

endmodule
