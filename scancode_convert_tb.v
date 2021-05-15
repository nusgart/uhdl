`timescale 1ns/1ps
`default_nettype none

// ISIM: wave add /

module scancode_convert_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]		keycode;		// From DUT of scancode_convert.v
   wire			strobe_out;		// From DUT of scancode_convert.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			clk;			// To DUT of scancode_convert.v
   reg [7:0]		code;			// To DUT of scancode_convert.v
   reg			reset;			// To DUT of scancode_convert.v
   reg			strobe_in;		// To DUT of scancode_convert.v
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   scancode_convert DUT(/*AUTOINST*/
			// Outputs
			.strobe_out	(strobe_out),
			.keycode	(keycode[15:0]),
			// Inputs
			.clk		(clk),
			.reset		(reset),
			.strobe_in	(strobe_in),
			.code		(code[7:0]));

   ////////////////////////////////////////////////////////////////////////////////

   task sendscan;
      input [7:0] scan;
      begin
	 @(posedge clk);
	 strobe_in = 1;
	 code = scan;
	 @(posedge clk);
	 strobe_in = 0;
	 repeat (100) @(posedge clk);
      end
   endtask

   task dumpstate;
      begin
	 if (DUT.state != DUT.state_ns)
	   case (DUT.state)
	     DUT.E0: $display("E0");
	     DUT.F0: $display("F0");
	     DUT.E0F0: $display("E0F0");
	     DUT.CONVERT_UP: $display("CONVERT_UP");
	     DUT.CONVERT_DOWN: $display("CONVERT_DOWN");
	     DUT.STROBE: $display("STROBE");
	   endcase
      end
   endtask

   task pause;
      begin
	 repeat(500) @(posedge clk);
	 $display("----");
      end
   endtask

   task monitor;
      begin
	 while (1) begin
	    @(posedge clk);
	    if (strobe_in)
	      $display("in: 0x%x %o", code, code);
	    if (strobe_out)
	      $display("out: 0x%x %o; ", keycode, keycode);
	 end
      end
   endtask

   task sender;
      begin
	 #200 reset = 0;

	 $display("sending scancode for \"a\"");
	 sendscan(8'h1c);
	 sendscan(8'hf0);
	 sendscan(8'h1c);
	 pause;

	 $display("sending scancode for \"b\"");
	 sendscan(8'h32);
	 sendscan(8'hf0);
	 sendscan(8'h32);
	 pause;

	 $display("sending scancode for enter");
	 sendscan(8'h5a);
	 sendscan(8'hf0);
	 sendscan(8'h5a);
	 pause;

	 $display("sending scancode for shift \"a\"");
	 sendscan(8'h12);
	 sendscan(8'h1c);
	 sendscan(8'hf0);
	 sendscan(8'h1c);
	 sendscan(8'hf0);
	 sendscan(8'h12);
	 pause;

	 $display("sending scancode for \"c\"");
	 sendscan(8'h21);
	 sendscan(8'hf0);
	 sendscan(8'h21);
	 pause;

	 $display("sending scancode for ctrl \"a\"");
	 sendscan(8'h14);
	 sendscan(8'h1c);
	 sendscan(8'hf0);
	 sendscan(8'h1c);
	 sendscan(8'hf0);
	 sendscan(8'h14);
	 pause;

	 $display("sending scancode for \"d\"");
	 sendscan(8'h23);
	 sendscan(8'hf0);
	 sendscan(8'h23);
	 pause;

	 #5000 $finish;
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
      strobe_in = 0;
      fork
	 monitor;
	 sender;
      join
   end

   always @(posedge clk)
     dumpstate;

   always begin
      #40 clk = 0;
      #40 clk = 1;
   end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
