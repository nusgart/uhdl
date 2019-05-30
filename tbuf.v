// chaos transmit/xmit buffer

`timescale 1ns/1ps
`default_nettype none

module tbuf(/*AUTOARG*/
   // Outputs
   tdata,
   // Inputs
   clk, reset, datain, tbct, trp, twp
   );
   wire clk, reset, trp, twp;
   input clk;
   input reset;
   
   input [15:0] datain;
   input [7:0] tbct;
   input trp;
   input twp;
   output [15:0] tdata;
   
   ////////////////////////////////////////////////////////////////////////////////

   reg [15:0] ram [0:255];
   reg [15:0] out;
   
   assign tdata = out;

   integer i;
   initial begin
      for (i = 0; i < 255; i=i+1) begin
         ram[i] = 16'b0;
      end
   end
   
   always @(posedge clk)
     if (twp) begin
	ram[tbct] <= datain;
	$display("tbuf: W %o <- %o; %t", tbct, datain, $time);
     end
   
   always @(posedge clk)
     if (trp) begin
	out <= ram[tbct];
	$display("tbuf: R %o -> %o; %t", tbct, datain, $time);
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
