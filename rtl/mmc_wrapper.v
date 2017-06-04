module mmc_wrapper(clk, mmc_clk, reset, speed, rd, wr, init, send, stop, cmd,
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

   mmc mmc(.clk(mmc_clk), .reset(reset), .speed(mmc_speed),
			   .wr(mmc_wr), .rd(mmc_rd), .init(mmc_init), .send(mmc_send), .stop(mmc_stop),
			   .cmd(mmc_cmd), .data_in(mmc_in), .data_out(mmc_out), .done(mmc_done),
			   .state_out(mmc_state),
			   .mmc_cs(mmc_cs), .mmc_di(mmc_di), .mmc_do(mmc_do), .mmc_sclk(mmc_sclk));
endmodule
