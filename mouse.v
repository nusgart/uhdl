// mouse.v --- ---!!!
// http://users.utcluj.ro/~baruch/sie/labor/PS2/PS-2_Mouse_Interface.htm

/* verilator lint_off CASEINCOMPLETE */

`timescale 1ns/1ps
`default_nettype none

module mouse(/*AUTOARG*/
   // Outputs
   x, y, button_l, button_m, button_r, ps2_clk_out, ps2_data_out,
   ps2_dir, strobe,
   // Inputs
   clk, reset, ps2_clk_in, ps2_data_in
   );

   input wire clk;
   input wire reset;

   input wire ps2_clk_in;
   input wire ps2_data_in;

   output [11:0] x;
   output [11:0] y;
   output wire button_l;
   output wire button_m;
   output wire button_r;

   output wire ps2_clk_out;
   output wire ps2_data_out;

   output wire ps2_dir;
   output wire strobe;

   ////////////////////////////////////////////////////////////////////////////////

   reg [7:0] b1, b2, b3, b4;
   reg full;

   wire [7:0] code;
   wire [7:0] out_code;
   wire busy;
   wire error;
   wire out_busy;
   wire out_rdy;
   wire out_send;
   wire rdy;

   ////////////////////////////////////////////////////////////////////////////////

   ps2 ps2_in
     (
      .ps2_clk(ps2_clk_in),
      .ps2_data(ps2_data_in),
      .parity(),
      /*AUTOINST*/
      // Outputs
      .code				(code[7:0]),
      .busy				(busy),
      .rdy				(rdy),
      .error				(error),
      // Inputs
      .clk				(clk),
      .reset				(reset));

   assign out_code = 8'h3b;
   assign out_send = state == POLL1;

   ps2_send ps2_out
     (
      .ps2_clk(ps2_clk_out),
      .ps2_data(ps2_data_out),
      .code(out_code),
      .send(out_send),
      .busy(out_busy),
      .rdy(out_rdy),
      /*AUTOINST*/
      // Inputs
      .clk				(clk),
      .reset				(reset));

   ////////////////////////////////////////////////////////////////////////////////
   // State Machine
   //
   // State machine to handle a 4 byte packet from the mouse (assumes
   // it responds to Microsoft Intellimouse data packet format).
   
   localparam [4:0]
     IDLE = 0,
     POLL1 = 1,
     POLL2 = 2,
     RX1A = 3,			// Byte 1: yovf, xovf, ysgn, xsgn, 1, mbtn, rbtn, lbtn
     RX1B = 4,
     RX2A = 5,			// Byte 2: xmov
     RX2B = 6,
     RX3A = 7,			// Byte 3: ymov
     RX3B = 8,
     RX4A = 9,			// Byte 4: 0, 0, 5th, 4th, z3, z2, z1, z0
     RX4B = 10;

   reg [4:0] state = IDLE;
   wire [4:0] state_ns;

   always @(posedge clk)
     if (reset)
       state <= IDLE;
     else
       state <= state_ns;

   assign state_ns =
		    error ? IDLE :
		    (state == IDLE && ~full) ? POLL1 :
		    (state == POLL1 && ~out_rdy) ? POLL2 :
		    (state == POLL2 && out_rdy) ? RX1A :
		    (state == RX1A && rdy) ? RX1B :
		    (state == RX1B && ~rdy) ? RX2A:
		    (state == RX2A && rdy) ? RX2B :
		    (state == RX2B && ~rdy) ? RX3A:
		    (state == RX3A && rdy) ? RX3B :
		    (state == RX3B && ~rdy) ? RX4A:
		    (state == RX4A && rdy) ? RX4B :
		    (state == RX4B && ~rdy) ? IDLE:
		    state;

   ////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	b1 <= 8'h0;
	b2 <= 8'h0;
	b3 <= 8'h0;
	b4 <= 8'h0;
	// End of automatics
     end else if (rdy) begin
	case (state)
	  RX1A: b1 <= code;
	  RX2A: b2 <= code;
	  RX3A: b3 <= code;
	  RX4A: b4 <= code;
	endcase
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	full <= 1'h0;
	// End of automatics
     end else if (state == RX4B) begin
	full <= 1;
     end else begin
	full <= 0;
     end

   assign x = { b2[4], b2[4], b2[4], b2[4], b3 };
   assign y = { b2[5], b2[5], b2[5], b2[5], b4 };

   assign button_l = b2[0];
   assign button_m = b2[2];
   assign button_r = b2[1];

   assign ps2_dir = out_busy;
   assign strobe = full;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
