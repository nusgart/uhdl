// xbus_spy.v --- ---!!!

/* verilator lint_off WIDTH */

`timescale 1ns/1ps
`default_nettype none

module xbus_spy(/*AUTOARG*/
   // Outputs
   dataout, ack, decode, spyout, spyreg, spyrd, spywr,
   // Inputs
   clk, addr, datain, req, write, spyin
   );

   input clk;

   input [21:0] addr;
   input [31:0] datain;
   input req;
   input write;
   output [31:0] dataout;
   output ack;
   output decode;

   input [15:0] spyin;
   output [15:0] spyout;
   output [3:0] spyreg;
   output spyrd;
   output spywr;

   ////////////////////////////////////////////////////////////////////////////////

   reg [2:0] ack_delayed = 0;
   reg [2:0] ack_state = 0;

   /*AUTOWIRE*/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [31:0]		dataout;
   reg [15:0]		spyout;
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   wire spyrd_d;

   always @(posedge clk) begin
      ack_delayed <= { ack_delayed[1:0], decode};
      ack_state <= { ack_state[1:0], ~ack_delayed[0] && decode };
   end

   assign spyrd_d = ack_state[1] && ~write;

   always @(posedge clk) begin
      if (spyrd_d) begin
	 dataout <= spyin;
      end

      if (req & decode) begin
	 if (write) begin
	    spyout <= datain[15:0];
	 end else begin
	    // Nothing on read.
	 end
      end
   end

   assign decode = req & ({addr[21:6], 6'b0} == 22'o17766000);

   assign ack = ack_delayed[2];

   ////////////////////////////////////////////////////////////////////////////////

   assign spyreg = addr[3:0];
   assign spyrd = ack_state[0] && ~write;
   assign spywr = ack_state[0] && write;
   
endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
