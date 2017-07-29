// ps2_send.v --- send bytes on the PS/2 clock and data lines
//
// Uses counter as a state machine; clocks 11 bits out:
//
//      start + data + parity + stop.

module ps2_send(clk,
                reset,
                ps2_clk,
                ps2_data,
                send,
                code,
                busy,
                rdy
                );

   input clk;                   // Main clock.
   input reset;                 // Asynchronous reset.
   input [7:0] code;            // Byte to send.
   input send;
   output busy;                 // Busy sending scancode.
   output rdy;                  // Ready pulse.

   output ps2_clk;              // Clock out.
   output ps2_data;             // Data out.

`ifdef null
   assign ps2_clk = 0;
   assign ps2_data = 0;
`else
   parameter FREQ = 25000;      // Frequency of the main clock (KHz).
   parameter PS2_FREQ = 10;     // Keyboard clock frequency (KHz).
   parameter DELAY = FREQ / PS2_FREQ; // PS2_CLK quiet timeout.

   reg [4:0] state;
   reg [15:0] delay;
   reg [10:0] ps2_out;

   wire delay_done;
   wire parity;

   assign delay_done = delay == 0;
   assign parity = ^code;

   always @(posedge clk)
     if (reset)
       delay <= 0;
     else
       delay <=
               (state == 0 || delay_done) ? DELAY :
               (delay != 0) ? delay - 1 :
               delay;

   always @(posedge clk)
     if (reset)
       state <= 0;
     else
       state <=
               (state == 22) ? 0 :
               (state == 0 && send) ? 1 :
               (state != 0 && delay_done) ? state + 1 :
               state;

   assign busy = state != 0;
   assign rdy = state == 0;

   assign ps2_clk = ~state[0];

   always @(posedge clk)
     if (reset)
       ps2_out <= 0;
     else
       if (state == 0)
         ps2_out <= { 1'b1, parity, code, 1'b0 };
       else
         if (delay_done && ~state[0])
           ps2_out <= { 1'b0, ps2_out[10:1] };

   assign ps2_data = state ? ps2_out[0] : 1'b1;
`endif

endmodule
