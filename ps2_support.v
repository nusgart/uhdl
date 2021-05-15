// ps2_support.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module ps2_support
  (input wire 	      kb_ps2_clk_in,
   input wire 	      kb_ps2_data_in,
   output reg 	      kb_ready,
   output reg [15:0] kb_data,

   input wire 	      ms_ps2_clk_in,
   input wire 	      ms_ps2_data_in,
   output reg 	      ms_ready,
   output reg [11:0]  ms_x, ms_y,
   output reg [2:0]   ms_button,
   output wire 	      ms_ps2_clk_out,
   output wire 	      ms_ps2_data_out,
   output wire 	      ms_ps2_dir,

   input wire 	      clk,
   input wire 	      reset);

   ////////////////////////////////////////////////////////////////////////////////
   // Keyboard

   wire [15:0] kb_bits;
   wire kb_strobe;

   keyboard keyboard
     (
      .ps2_clk(kb_ps2_clk_in),
      .ps2_data(kb_ps2_data_in),
      .data(kb_bits),
      .strobe(kb_strobe),
      /*AUTOINST*/
      // Inputs
      .clk				(clk),
      .reset				(reset));

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	kb_data <= 16'h0;
	kb_ready <= 1'h0;
	// End of automatics
     end else begin
	kb_data <= kb_bits;
	kb_ready <= kb_strobe;
     end

   ////////////////////////////////////////////////////////////////////////////////
   // Mouse

   wire [11:0] m_x, m_y;
   wire m_ready;
   wire [2:0] m_button;

   mouse mouse
     (
      .ps2_clk_in(ms_ps2_clk_in),
      .ps2_data_in(ms_ps2_data_in),
      .ps2_clk_out(ms_ps2_clk_out),
      .ps2_data_out(ms_ps2_data_out),
      .ps2_dir(ms_ps2_dir),
      .button_l(m_button[2]),
      .button_m(m_button[1]),
      .button_r(m_button[0]),
      .x(m_x),
      .y(m_y),
      .strobe(m_ready),
      /*AUTOINST*/
      // Inputs
      .clk				(clk),
      .reset				(reset));

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	ms_button <= 3'h0;
	ms_ready <= 1'h0;
	ms_x <= 12'h0;
	ms_y <= 12'h0;
	// End of automatics
     end else begin
	ms_x <= m_x;
	ms_y <= m_y;
	ms_button <= m_button;
	ms_ready <= m_ready;
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
