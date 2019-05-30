// xbus_ram.v --- interface for ram controller

`timescale 1ns/1ps
`default_nettype none

module xbus_ram (/*AUTOARG*/
   // Outputs
   output wire [31:0] dataout,
   output wire ack,
   output wire decode,
   output wire [21:0] sdram_addr,
   output wire [31:0] sdram_data_out,
   output wire sdram_req,
   output wire sdram_write,
   // Inputs
   input wire clk,
   input wire reset,
   input wire [21:0] addr,
   input wire [31:0] datain, 
   input wire req,
   input wire write,
   input wire [31:0] sdram_data_in,
   input wire sdram_ready,
   input wire sdram_done
   );

   ////////////////////////////////////////////////////////////////////////////////
  
   // Need some dram address space at the end which is decoded but
   // does not read/write...
   assign decode = addr < 22'o11000000 ? 1'b1: 1'b0;
   
   assign sdram_req = req & decode & ~write;
   assign sdram_write = req & decode & write;
   
`ifdef SIMULATION
   parameter DRAM_SIZE = 131072;
   parameter DRAM_BITS = 17;
   
   reg [31:0] ram[DRAM_SIZE-1:0];
   
   integer i, debug, debug_decode, debug_detail_delay;
   
   initial begin
      debug = 0;
      debug_decode = 0;
      debug_detail_delay = 0;
      for (i = 0; i < DRAM_SIZE; i = i + 1)
	ram[i] = 0;
   end
   
   parameter DELAY = 3;
   
   reg [21:0] reg_addr;
   reg req_delayed;
   reg [DELAY:0] ack_delayed;
   wire local_ack;
   
   assign ack = req_delayed;
   
   assign local_ack = ack_delayed[DELAY];
   
   always @(posedge clk)
     if (reset)
       reg_addr <= 0;
     else if (req & decode & ~|ack_delayed)
       reg_addr <= addr;
   
   wire [DRAM_BITS-1:0] reg_addr20;
   assign reg_addr20 = reg_addr[DRAM_BITS-1:0];
   
   always @(posedge clk)
     if (reset) begin
	req_delayed <= 0;
	ack_delayed <= 0;
     end else begin
	req_delayed <= (sdram_write || sdram_req) & ~|ack_delayed;
	ack_delayed <= { ack_delayed[DELAY-1:0], req_delayed };
     end
   
   always @(posedge clk) begin
      if (req & decode & req_delayed & ~|ack_delayed)
	if (write) begin
	   if (reg_addr < DRAM_SIZE)
	     ram[reg_addr20] <= datain;
	end else begin
	end
   end
   
   assign dataout = reg_addr < DRAM_SIZE ? ram[reg_addr20] : 32'hffffffff;
   
`else
   assign dataout = sdram_data_in;
   assign ack = (sdram_write && sdram_done) || (sdram_req && sdram_ready);
   
   assign sdram_addr = addr;
   assign sdram_data_out = datain;
`endif
   
endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
