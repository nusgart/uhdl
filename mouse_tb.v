`timescale 1ns/1ps
`default_nettype none

// ISIM: wave add /

module mouse_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			button_l;		// From DUT of mouse.v
   wire			button_m;		// From DUT of mouse.v
   wire			button_r;		// From DUT of mouse.v
   wire			ps2_clk_out;		// From DUT of mouse.v
   wire			ps2_data_out;		// From DUT of mouse.v
   wire			ps2_dir;		// From DUT of mouse.v
   wire			strobe;			// From DUT of mouse.v
   wire [11:0]		x;			// From DUT of mouse.v
   wire [11:0]		y;			// From DUT of mouse.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			clk;			// To DUT of mouse.v
   reg			ps2_clk_in;		// To DUT of mouse.v
   reg			ps2_data_in;		// To DUT of mouse.v
   reg			reset;			// To DUT of mouse.v
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   mouse DUT(/*AUTOINST*/
	     // Outputs
	     .x				(x[11:0]),
	     .y				(y[11:0]),
	     .button_l			(button_l),
	     .button_m			(button_m),
	     .button_r			(button_r),
	     .ps2_clk_out		(ps2_clk_out),
	     .ps2_data_out		(ps2_data_out),
	     .ps2_dir			(ps2_dir),
	     .strobe			(strobe),
	     // Inputs
	     .clk			(clk),
	     .reset			(reset),
	     .ps2_clk_in		(ps2_clk_in),
	     .ps2_data_in		(ps2_data_in));

   ////////////////////////////////////////////////////////////////////////////////

   task clockout;
      input bit;
      begin
	 ps2_data_in = bit;
	 ps2_clk_in = 0;
	 repeat (100) @(posedge clk);
	 ps2_clk_in = 1;
	 repeat (100) @(posedge clk);
      end
   endtask

   // y ovf, x ovf, y sign, x sign, 1, m, r, l
   // x movement
   // y movement
   task sendscan;
      input [7:0] scan;
      begin
	 @(posedge clk);
	 clockout(0);
	 clockout(scan[0]);
	 clockout(scan[1]);
	 clockout(scan[2]);
	 clockout(scan[3]);
	 clockout(scan[4]);
	 clockout(scan[5]);
	 clockout(scan[6]);
	 clockout(scan[7]);
	 clockout(0);
	 clockout(1);
	 repeat (10000) @(posedge clk);
      end
   endtask

   task pause;
      begin
	 repeat(5000) @(posedge clk);
	 $display("----");
      end
   endtask

   task sender;
      begin
	 $display("begin test");

	 #200 reset = 0;

	 #100000;

	 sendscan(8'hf);
	 sendscan(8'hf);
	 sendscan(8'hf);
	 pause;

	 sendscan(8'hf);
	 sendscan(8'hf);
	 sendscan(8'hf);
	 pause;

	 sendscan(8'hf);
	 sendscan(8'hf);
	 sendscan(8'hf);
	 pause;

	 $display("end test");

	 #5000 $finish;
      end
   endtask

   task monitor;
      begin
	 $display("monitor start");
	 while (1) begin
	    @(posedge clk);
	    if (strobe) begin
	       $display("out: button_l = %o; ", button_l);
	       $display("out: button_r = %o; ", button_r);
	       $display("out: button_m = %o; ", button_m);
	       $display("out: x,y = %d, %d", x, y);
	    end
	 end
	 $display("monitor end");
      end
   endtask

   ////////////////////////////////////////////////////////////////////////////////

   initial begin
      $timeformat(-9, 0, "ns", 7);
      $dumpfile(`VCDFILE);
      $dumpvars(0, DUT);
   end

   initial begin
      clk = 0;
      reset = 1;
      ps2_clk_in = 1;
      ps2_data_in = 1;
      fork
	 monitor;
	 sender;
      join
   end

   always begin
      #40 clk = 0;
      #40 clk = 1;
   end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
