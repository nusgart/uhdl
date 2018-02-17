// Q --- Q REGISTER

`include "defines.vh"

module Q(clk, reset, state_fetch, qs0, qs1, alu, q);

   input clk;
   input reset;

   input state_fetch;

   input qs0;
   input qs1;

   input [32:0] alu;
   output [31:0] q;

   ////////////////////////////////////////////////////////////////////////////////

   reg [31:0] q;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset)
       q <= 0;
     else
       if (state_fetch && (qs1 | qs0))
         begin
            case({qs1, qs0})
              2'b00: q <= q;
              2'b01: q <= {q[30:0], ~alu[31]};
              2'b10: q <= {alu[0], q[31:1]};
              2'b11: q <= alu[31:0];
            endcase
         end

endmodule
