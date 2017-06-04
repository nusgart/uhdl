//
// mmc_wrapper.v
//
// clock domain aware wrapper for mmc card interface
// handles the faster mmc clock and slower cpu clock
//


module mmc_wrapper(clk, mmc_clk, reset,
		   speed, rd, wr, init, send, stop, cmd,
		   data_in, data_out, done, state_out,
		   mmc_cs, mmc_di, mmc_do, mmc_sclk);

   input clk;
   input mmc_clk;
   input reset;

   input speed;
   input rd;
   input wr;
   input init;
   input send;
   input stop;
   input [47:0] cmd;
   input [7:0] 	data_in;

   output [7:0] data_out;
   output      done;
   output [3:0] state_out;
   
   output mmc_cs;
   output mmc_do;
   output mmc_sclk;
   input  mmc_di;

   // clock domain crossing
   wire [62:0] sample2mmc;
   reg  [62:0] sampled2mmc0, sampled2mmc1;

   wire [13:0] mmc2sample;
   reg  [13:0] mmc2sampled0, mmc2sampled1;

   assign sample2mmc = { cmd, data_in, speed, stop, send, init, wr, rd };

   always @(posedge mmc_clk)
     if (reset)
       begin
	  sampled2mmc0 <= 0;
	  sampled2mmc1 <= 0;
       end
     else
       begin
	  sampled2mmc0 <= sample2mmc;
	  sampled2mmc1 <= sampled2mmc0;
       end

   wire rd2mmc, wr2mmc, init2mmc, send2mmc, stop2mmc, speed2mmc;
   wire [7:0] data_in2mmc;
   wire [47:0] cmd2mmc;

   assign rd2mmc = sampled2mmc1[0];
   assign wr2mmc = sampled2mmc1[1];
   assign init2mmc = sampled2mmc1[2];
   assign send2mmc = sampled2mmc1[3];
   assign stop2mmc = sampled2mmc1[4];
   assign speed2mmc = sampled2mmc1[5];
   assign data_in2mmc = sampled2mmc1[13:6];
   assign cmd2mmc = sampled2mmc1[62:14];

   wire        mmc2mmc_done;
   wire [7:0]  mmc2mmc_data_out;
   wire [3:0]  mmc2state_out;
   
   assign mmc2sample = { mmc2state_out, mmc2mmc_data_out, mmc2mmc_done };

   always @(posedge clk)
     if (reset)
       begin
	  mmc2sampled0 <= 0;
	  mmc2sampled1 <= 0;
       end
     else
       begin
	  mmc2sampled0 <= mmc2sample;
	  mmc2sampled1 <= mmc2sampled0;
       end

   assign done      = mmc2sampled1[0];
   assign data_out  = mmc2sampled1[8:1];
   assign state_out = mmc2sampled1[13:9];
   
   mmc mmc(.clk(mmc_clk), .reset(reset),
	   .speed(speed2mmc), .rd(rd2mmc), .wr(wr2mmc), .init(init2mmc), .send(send2mmc), .stop(stop2mmc),
	   .cmd(cmd2mmc), .data_in(data_in2mmc),
	   .data_out(mmc2mmc_data_out), .done(mmc2mmc_done), .state_out(mmc2state_out),
	   .mmc_cs(mmc_cs), .mmc_di(mmc_di), .mmc_do(mmc_do), .mmc_sclk(mmc_sclk));

endmodule // mmc_wrapper

