module OLORD2();

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
