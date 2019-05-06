// mmc_wrapper.v --- ---!!!

/* verilator lint_off WIDTH */

`timescale 1ns/1ps
`default_nettype none

module mmc_wrapper(/*AUTOARG*/
   // Outputs
   state_out, data_out, done, mmc_cs, mmc_do, mmc_sclk,
   // Inputs
   cmd, data_in, clk, init, mmc_clk, mmc_di, rd, reset, send, speed,
   stop, wr
   );

   input [47:0] cmd;
   input [7:0] data_in;
   input clk;
   input init;
   input mmc_clk;
   input mmc_di;
   input rd;
   input reset;
   input send;
   input speed;
   input stop;
   input wr;
   output [3:0] state_out;
   output [7:0] data_out;
   output done;
   output mmc_cs;
   output mmc_do;
   output mmc_sclk;

   ////////////////////////////////////////////////////////////////////////////////

   reg [13:0] mmc2sampled0, mmc2sampled1;
   reg [62:0] sampled2mmc0, sampled2mmc1;

   wire [13:0] mmc2sample;
   wire [3:0] mmc2state_out;
   wire [47:0] cmd2mmc;
   wire [62:0] sample2mmc;
   wire [7:0] data_in2mmc;
   wire [7:0] mmc2mmc_data_out;
   wire mmc2mmc_done;
   wire rd2mmc, wr2mmc, init2mmc, send2mmc, stop2mmc, speed2mmc;

   /*AUTOWIRE*/
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   assign sample2mmc = { cmd, data_in, speed, stop, send, init, wr, rd };

   always @(posedge mmc_clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	sampled2mmc0 <= 63'h0;
	sampled2mmc1 <= 63'h0;
	// End of automatics
     end else begin
	sampled2mmc0 <= sample2mmc;
	sampled2mmc1 <= sampled2mmc0;
     end

   assign rd2mmc = sampled2mmc1[0];
   assign wr2mmc = sampled2mmc1[1];
   assign init2mmc = sampled2mmc1[2];
   assign send2mmc = sampled2mmc1[3];
   assign stop2mmc = sampled2mmc1[4];
   assign speed2mmc = sampled2mmc1[5];
   assign data_in2mmc = sampled2mmc1[13:6];
   assign cmd2mmc = sampled2mmc1[62:14];
   assign mmc2sample = { mmc2state_out, mmc2mmc_data_out, mmc2mmc_done };

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	mmc2sampled0 <= 14'h0;
	mmc2sampled1 <= 14'h0;
	// End of automatics
     end else begin
	mmc2sampled0 <= mmc2sample;
	mmc2sampled1 <= mmc2sampled0;
     end

   assign done = mmc2sampled1[0];
   assign data_out = mmc2sampled1[8:1];
   assign state_out = mmc2sampled1[13:9];

   mmc mmc
     (
      .clk(mmc_clk),
      .speed(speed2mmc),
      .rd(rd2mmc),
      .wr(wr2mmc),
      .init(init2mmc),
      .send(send2mmc),
      .stop(stop2mmc),
      .cmd(cmd2mmc),
      .data_in(data_in2mmc),
      .data_out(mmc2mmc_data_out),
      .done(mmc2mmc_done),
      .state_out(mmc2state_out),
      /*AUTOINST*/
      // Outputs
      .mmc_cs				(mmc_cs),
      .mmc_do				(mmc_do),
      .mmc_sclk				(mmc_sclk),
      // Inputs
      .mmc_di				(mmc_di),
      .reset				(reset));

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
