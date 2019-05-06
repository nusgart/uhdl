`timescale 1ns/1ps
`default_nettype none

// ISIM: wave add /

module support_tb;

   reg [2:0] slow;
   reg [3:0] button;
   reg locked;
   reg sysclk;

   wire boot;
   wire clk1x;
   wire dcm_reset;
   wire halt;
   wire interrupt;
   wire lpddr_calib_done;
   wire lpddr_reset;
   wire reset;
   wire sysclk_buf;

   /*AUTOWIRE*/
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   support DUT
     (
      .sysclk(sysclk_buf),
      .cpuclk(clk1x),
      .button_r(button[3]),
      .button_b(button[2]),
      .button_h(button[1]),
      .button_c(button[0]),
      /*AUTOINST*/
      // Outputs
      .boot				(boot),
      .dcm_reset			(dcm_reset),
      .halt				(halt),
      .interrupt			(interrupt),
      .lpddr_reset			(lpddr_reset),
      .reset				(reset),
      // Inputs
      .lpddr_calib_done			(lpddr_calib_done));

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge sysclk)
     slow <= slow + 1;

   assign sysclk_buf = sysclk;
   assign clk1x = slow[0] & locked;

   initial begin
      $timeformat(-9, 0, "ns", 7);
      $dumpfile(`VCDFILE);
      $dumpvars(0, DUT);
   end

   always @(posedge sysclk) begin
      if (dcm_reset)
	locked = 0;
      else if (~dcm_reset)
	#20 locked = 1;
   end

   initial begin
      slow = 0;
      sysclk = 0;
      button = 4'b0000;
      locked = 0;

      #5000 button = 4'b1000;
      #40000000 button = 4'b0000;
      #4000000; button = 4'b1000;
      #40000000 button = 4'b0000;
      #40000000 $finish;
   end

   always begin
      #10 sysclk = 0;
      #10 sysclk = 1;
   end

endmodule
