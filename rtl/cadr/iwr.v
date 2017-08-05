// IWR --- INSTRUCTION WRITE REGISTER

module IWR(clk, reset, state_fetch, a, m, iwr);

   input clk;
   input reset;

   input state_fetch;

   input [31:0] a;
   input [31:0] m;

   output [48:0] iwr;

   ////////////////////////////////////////////////////////////////////////////////

   reg [48:0] iwr;

   ////////////////////////////////////////////////////////////////////////////////

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
