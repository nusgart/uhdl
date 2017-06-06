module IWR(clk, reset, state_fetch, iwr, a, m);
input clk;
input reset;
input state_fetch;
output reg [48:0] iwr;
input [31:0] a;
input [31:0] m;

  always @(posedge clk)
     if (reset)
       iwr <= 0;
     else
       if (state_fetch)
	 begin
	    iwr[48] <= 0;
	    iwr[47:32] <= a[15:0];
	    iwr[31:0] <= m[31:0];
	 end
endmodule
