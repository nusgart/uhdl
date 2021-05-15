`timescale 1ns/1ps
`default_nettype none

// ISIM: wave add /

module ps2_send_tb;

   reg i_ps2_clk;
   reg i_ps2_data;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			busy;			// From DUT of ps2_send.v
   wire			ps2_clk;		// From DUT of ps2_send.v
   wire			ps2_data;		// From DUT of ps2_send.v
   wire			rdy;			// From DUT of ps2_send.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			clk;			// To DUT of ps2_send.v
   reg [7:0]		code;			// To DUT of ps2_send.v
   reg			reset;			// To DUT of ps2_send.v
   reg			send;			// To DUT of ps2_send.v
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   ps2_send DUT(/*AUTOINST*/
		// Outputs
		.busy			(busy),
		.rdy			(rdy),
		.ps2_clk		(ps2_clk),
		.ps2_data		(ps2_data),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.code			(code[7:0]),
		.send			(send));

   ////////////////////////////////////////////////////////////////////////////////

   task sendbyte;
      input [7:0] scan;
      begin
	 code = scan;
	 @(posedge clk);
	 send = 1;
	 @(posedge clk);
	 send = 0;
	 while (busy)
	   @(posedge clk);
      end
   endtask

   task clockout;
      input bit;
      begin
	 i_ps2_data = bit;
	 i_ps2_clk = 0;
	 repeat (100) @(posedge clk);
	 i_ps2_clk = 1;
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
	 repeat(30000) @(posedge clk);
	 $display("----");
      end
   endtask

   task sender;
      begin
	 $display("begin test");
	 #1000 reset = 0;
	 #100000;
	 #100000;
	 #100000;

	 // press "a"
	 sendbyte(8'h00); pause;
	 sendbyte(8'hff); pause;
	 sendbyte(8'h01); pause;
	 sendbyte(8'h81); pause;
	 $display("end test");
	 #5000 $finish;
      end
   endtask

   task monitor;
      begin
	 $display("monitor start");
	 while (1)
	   @(posedge clk);
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
      send = 0;
      code = 0;
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
