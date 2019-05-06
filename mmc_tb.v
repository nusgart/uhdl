`timescale 1ns/1ps
`default_nettype none

// ISIM: wave add /

module mmc_tb;

   reg [47:0] mmc_cmd;
   reg [7:0] data;
   reg [7:0] mmc_data_in;
   reg clk;
   reg mmc_init;
   reg mmc_rd;
   reg mmc_send;
   reg mmc_speed;
   reg mmc_stop;
   reg mmc_wr;
   reg reset;

   wire [7:0] mmc_data_out;
   wire mmc_cs;
   wire mmc_di;
   wire mmc_do;
   wire mmc_done;
   wire mmc_sclk;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]		state_out;		// From DUT of mmc.v
   // End of automatics
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   mmc DUT
     (
      .speed(mmc_speed),
      .wr(mmc_wr),
      .rd(mmc_rd),
      .init(mmc_init),
      .send(mmc_send),
      .stop(mmc_stop),
      .cmd(mmc_cmd),
      .data_in(mmc_data_in),
      .data_out(mmc_data_out),
      .done(mmc_done),
      /*AUTOINST*/
      // Outputs
      .state_out			(state_out[3:0]),
      .mmc_cs				(mmc_cs),
      .mmc_do				(mmc_do),
      .mmc_sclk				(mmc_sclk),
      // Inputs
      .clk				(clk),
      .mmc_di				(mmc_di),
      .reset				(reset));

   mmc_model mmc_card
     (
      .spiClk(mmc_sclk),
      .spiDataIn(mmc_do),
      .spiDataOut(mmc_di),
      .spiCS_n(mmc_cs)
      /*AUTOINST*/);

   ////////////////////////////////////////////////////////////////////////////////

   task wait_for_mmc_busy;
      integer loops;
      begin
	 @(posedge clk);
	 while (mmc_done == 1'b1) begin
	    loops = loops + 1;
	    if (loops > 100000) begin
	       $display("TIMEOUT: wait_for_mmc_busy");
	       $finish;
	    end
	    @(posedge clk);
	 end
      end
   endtask

   task wait_for_mmc_done;
      integer loops;
      begin
	 loops = 0;
	 while (mmc_done == 1'b0) begin
	    loops = loops + 1;
	    if (loops > 100000) begin
	       $display("TIMEOUT: wait_for_mmc_done");
	       $finish;
	    end
	    @(posedge clk);
	 end
      end
   endtask

   task wait_for_data;
      input [7:0] want;
      integer loops;
      begin
	 loops = 0;
	 do_mmc_read(data);
	 $display("-> %x", data);
	 while (data != want) begin
	    loops = loops + 1;
	    if (loops > 1000) begin
	       $display("TIMEOUT: wait_for_data");
	       $finish;
	    end
	    do_mmc_read(data);
	 end
	 $display("-> %x (good)", data);
      end
   endtask

   task get_block;
      input [31:0] size;
      integer i;
      begin
	 for (i = 0; i < size; i = i + 1) begin
	    do_mmc_read(data);
	    $display("[%d] %x", i, data);
	 end
      end
   endtask

   task do_mmc_init;
      begin
	 @(posedge clk);
	 mmc_init = 1;
	 @(negedge clk);
	 wait_for_mmc_busy;
	 mmc_init = 0;
	 wait_for_mmc_done;
      end
   endtask

   task do_mmc_send;
      input [47:0] cmd;
      begin
	 mmc_cmd = cmd;
	 @(posedge clk);
	 mmc_send = 1;
	 @(negedge clk);
	 wait_for_mmc_busy;
	 mmc_send = 0;
	 wait_for_mmc_done;
	 @(posedge clk);
      end
   endtask

   task do_mmc_write;
      input [7:0] data;
      begin
	 mmc_data_in = data;
	 @(posedge clk);
	 mmc_wr = 1;
	 @(negedge clk);
	 wait_for_mmc_busy;
	 mmc_wr = 0;
	 wait_for_mmc_done;
	 @(posedge clk);
      end
   endtask

   task do_mmc_read;
      output [7:0] data;
      begin
	 @(posedge clk);
	 mmc_rd = 1;
	 @(negedge clk);
	 wait_for_mmc_busy;
	 mmc_rd = 0;
	 wait_for_mmc_done;
	 data = mmc_data_out;
	 @(posedge clk);
      end
   endtask

   task do_mmc_done;
      begin
	 @(posedge clk);
	 mmc_stop = 1;
	 @(negedge clk);
	 wait_for_mmc_done;
	 mmc_stop = 0;
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
      mmc_speed = 0;
      mmc_wr = 0;
      mmc_rd = 0;
      mmc_init = 0;
      mmc_send = 0;
      mmc_cmd = 0;
      mmc_stop = 0;
      mmc_data_in = 0;
      #5000 reset = 0;
      #50 ;
      do_mmc_init;
      do_mmc_send(48'h400000000095);
      wait_for_data(8'h01);
      do_mmc_done;
      do_mmc_send(48'h410000000095);
      wait_for_data(8'h00);
      do_mmc_done;
      mmc_speed = 1;
      do_mmc_send(48'h580000000095);
      wait_for_data(8'h00);
      get_block(512);
      data = 8'h12;
      do_mmc_write(data);
      data = 8'h11;
      do_mmc_write(data);
      do_mmc_done;
      #50000 $finish;
   end

   always begin
      #5 clk = 0;
      #5 clk = 1;
   end

endmodule

// Local Variables:
// verilog-library-directories: (".")
// End:
