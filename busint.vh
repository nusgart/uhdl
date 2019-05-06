// busint.vh -- common tasks for bus interface

task wait_for_bi_done;
   begin
      while (ack == 1'b0) @(posedge clk);
   end
endtask

task bus_read;
   input [21:0] a;
   output [31:0] out;
   begin
      @(posedge clk);
      write = 0;
      req = 1;
      addr = a;
      wait_for_bi_done;
      $display("read: addr %o in %o out %o, %t",
	       addr, datain, dataout, $time);
      out = dataout;
      req = 0;
      @(posedge clk);
   end
endtask

task bus_write;
   input [21:0] a;
   input [31:0] data;
   begin
      @(posedge clk);
      write = 1;
      addr = a;
      datain = data;
      req = 1;
      $display("write: addr %o in %o out %o, %t",
	       addr, datain, dataout, $time);
      wait_for_bi_done;
      req = 0;
      @(posedge clk);
   end
endtask
