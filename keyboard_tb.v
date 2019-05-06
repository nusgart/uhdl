`timescale 1ns/1ps
`default_nettype none

// ISIM: wave add /

module keyboard_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]		data;			// From DUT of keyboard.v
   wire			strobe;			// From DUT of keyboard.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			clk;			// To DUT of keyboard.v
   reg			ps2_clk;		// To DUT of keyboard.v
   reg			ps2_data;		// To DUT of keyboard.v
   reg			reset;			// To DUT of keyboard.v
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   keyboard DUT(/*AUTOINST*/
		// Outputs
		.data			(data[15:0]),
		.strobe			(strobe),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.ps2_clk		(ps2_clk),
		.ps2_data		(ps2_data));

   ////////////////////////////////////////////////////////////////////////////////

   task clockout;
      input bit;
      begin
	 ps2_data = bit;
	 ps2_clk = 0;
	 repeat (100) @(posedge clk);
	 ps2_clk = 1;
	 repeat (100) @(posedge clk);
      end
   endtask

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

	 sendscan(8'h1c);
	 sendscan(8'hf0);
	 sendscan(8'h1c);
	 pause;

	 sendscan(8'h32);
	 sendscan(8'hf0);
	 sendscan(8'h32);
	 pause;

	 sendscan(8'h5a);
	 sendscan(8'hf0);
	 sendscan(8'h5a);
	 pause;

	 sendscan(8'h12);

	 sendscan(8'h1c);
	 sendscan(8'hf0);
	 sendscan(8'h1c);
	 sendscan(8'hf0);

	 sendscan(8'h12);
	 pause;

	 sendscan(8'h21);
	 sendscan(8'hf0);
	 sendscan(8'h21);
	 pause;

	 sendscan(8'h14);

	 sendscan(8'h1c);
	 sendscan(8'hf0);
	 sendscan(8'h1c);
	 sendscan(8'hf0);

	 sendscan(8'h14);
	 pause;

	 sendscan(8'h23);
	 sendscan(8'hf0);
	 sendscan(8'h23);
	 pause;

	 sendscan(8'he0);
	 sendscan(8'h69);
	 sendscan(8'he0);

	 sendscan(8'hf0);
	 sendscan(8'h69);
	 pause;

	 sendscan(8'h76);
	 sendscan(8'hf0);
	 sendscan(8'h76);
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
	    if (strobe)
	      $display("out: 0x%x %o; ", data, data);
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
      ps2_clk = 1;
      ps2_data = 1;
      fork
	 monitor;
	 sender;
      join
   end

   always @(posedge clk)
     if (DUT.rdy)
       $display("keyboard: scan_rdy, code 0x%x %o", DUT.code, DUT.code);

   always begin
      #40 clk = 0;
      #40 clk = 1;
   end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
