/*
 * $Id$
 */

module xbus_ram (
		reset,
		clk,
		addr,
		datain,
		dataout,
		req,
		write,
		ack,
		decode
		);

   input reset;
   input clk;
   input [21:0] addr;
   input [31:0] datain;
   input 	req;
   input 	write;
   
   output [31:0] dataout;
   output 	 ack;
   output 	 decode;

   parameter 	 RAM_SIZE = 2097152/*131072*/;
   
   //
   reg [31:0] 	 ram[RAM_SIZE-1:0];

   integer i;
   
   initial
     for (i = 0; i < RAM_SIZE; i = i + 1)
       ram[i] = 0;
   
   reg 		 req_delayed;
   reg [6:0] 	 ack_delayed;

   // need some dram address space at the end 
   // which is decoded but does not read/write...
   assign 	 decode = addr < 22'o11000000 ? 1'b1: 1'b0;

   assign 	 ack = ack_delayed[6];

   wire [16:0] 	 addr17;
   
   assign addr17 = addr[16:0];
   
   always @(posedge clk)
     if (reset)
       begin
          req_delayed <= 0;
          ack_delayed <= 7'b0;
       end
    else
      begin
         req_delayed <= req & decode & ~|ack_delayed;
         ack_delayed[0] <= req_delayed;
         ack_delayed[1] <= ack_delayed[0];
         ack_delayed[2] <= ack_delayed[1];
         ack_delayed[3] <= ack_delayed[2];
         ack_delayed[4] <= ack_delayed[3];
         ack_delayed[5] <= ack_delayed[4];
         ack_delayed[6] <= ack_delayed[5];

`ifdef debug_detail_delay
	 if (req & decode)
	   $display("ddr: decode %b; %b %b",
		    req & decode, req_delayed, ack_delayed);

	 if (req & decode & ~|ack_delayed)
	   $display("ddr: req_delayed %b", req & decode & ~|ack_delayed);

	 if (ack_delayed[6])
	     $display("ddr: ack %b", ack);
`endif
      end

   always @(posedge clk)
     begin
	if (req & decode & req_delayed & ~|ack_delayed)
	  if (write)
	    begin
`ifdef debug
               #1 $display("ddr: write @%o <- %o", addr17, datain);
`endif
	       if (addr < RAM_SIZE)
		 ram[addr17] = datain;
	    end
	  else
	    begin
`ifdef debug
               #1 $display("ddr: read @%o -> %o (0x%x), %t",
			   addr, ram[addr17], ram[addr17], $time);
`endif
	    end
     end

   assign dataout = addr < RAM_SIZE ? ram[addr17] : 32'hffffffff;

endmodule
