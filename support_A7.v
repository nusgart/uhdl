// support_lx45.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module support_A7(/*AUTOARG*/
   // Outputs
   output wire boot, 
   output wire dcm_reset, 
   output wire halt,
   output wire interrupt,
   output wire lpddr_reset, 
   output wire reset,
   // Inputs
   input wire button_b,
   input wire button_c, 
   input wire button_h, 
   input wire button_r,
   input wire cpu_clk, 
   input wire lpddr_calib_done,
   input wire sysclk
   );

   ////////////////////////////////////////////////////////////////////////////////

   parameter 
     c_init = 3'd0,
     c_reset1 = 3'd1,
     c_reset2 = 3'd2,
     c_reset3 = 3'd3,
     c_boot = 3'd4,
     c_wait = 3'd5,
     c_idle = 3'd6;
   parameter 
     r_init = 3'd0,
     r_reset1 = 3'd1,
     r_reset2 = 3'd2,
     r_reset3 = 3'd3,
     r_reset4 = 3'd4,
     r_reset5 = 3'd5,
     r_wait = 3'd6,
     r_idle = 3'd7;

   reg [11:0] sys_slowcount;
   reg [1:0] cpu_slowcount;
   reg [2:0] cpu_state;
   reg [2:0] reset_state;
   reg [3:0] lpddr_reset_holdoff_cnt;
   reg [5:0] sys_medcount;
   reg [9:0] hold;
   reg press_history;

   wire [2:0] cpu_state_next;
   wire [2:0] reset_state_next;
   wire cpu_in_reset;
   wire cpu_slowevent;
   wire lpddr_reset_holdoff;
   wire press_detected;
   wire pressed;
   wire sys_medevent;
   wire sys_slowevent;

   /*AUTOWIRE*/
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   assign interrupt = 1'b0;
   assign halt = 1'b0;

   initial begin
      reset_state = 0;
      cpu_state = 0;
      sys_slowcount = 0;
      sys_medcount = 0;
      cpu_slowcount = 0;
      hold = 0;
      press_history = 0;
   end

   always @(posedge cpu_clk or posedge dcm_reset)
     if (dcm_reset)
       cpu_slowcount <= 0;
     else
       cpu_slowcount <= cpu_slowcount + 2'd1;

   initial
     lpddr_reset_holdoff_cnt = 0;

   always @(posedge sysclk)
     if (lpddr_reset_holdoff_cnt != 4'd4)
       lpddr_reset_holdoff_cnt <= lpddr_reset_holdoff_cnt + 4'd1;

   assign lpddr_reset_holdoff = lpddr_reset_holdoff_cnt != 4'd4;

   assign cpu_in_reset = (reset_state == r_init ||
			  reset_state == r_reset1 ||
			  reset_state == r_reset2 ||
			  reset_state == r_reset3) ||
			 (cpu_state == c_init ||
			  cpu_state == c_reset1 ||
			  cpu_state == c_reset2 ||
			  cpu_state == c_reset3);
   assign dcm_reset = reset_state == r_init;
   assign lpddr_reset = (reset_state == r_init || reset_state == r_reset1) &&
			~lpddr_reset_holdoff ? 1'b1 : 1'b0;
   assign reset = cpu_in_reset;
   assign boot = cpu_state == c_reset3 || cpu_state == c_boot;
   assign cpu_state_next =
			  (cpu_state == c_init && reset_state == r_reset4) ? c_reset1 :
			  (cpu_state == c_reset1) ? c_reset2 :
			  (cpu_state == c_reset2) ? c_reset3 :
			  (cpu_state == c_reset3) ? c_boot :
			  (cpu_state == c_boot) ? c_wait :
			  (cpu_state == c_wait && reset_state == r_idle) ? c_idle :
			  (cpu_state == c_idle && reset_state == r_reset4) ? c_reset1 :
			  cpu_state;
   assign cpu_slowevent = cpu_slowcount == 2'b11;

   always @(posedge cpu_clk)
     if (cpu_slowevent) begin
	cpu_state <= cpu_state_next;
     end

   assign reset_state_next =
			    (reset_state == r_init) ? r_reset1 :
			    (reset_state == r_reset1) ? r_reset2 :
			    (reset_state == r_reset2) ? r_reset3 :
			    (reset_state == r_reset3 && lpddr_calib_done) ? r_reset4 :
			    (reset_state == r_reset4 && cpu_state != c_idle) ? r_wait :
			    (reset_state == r_wait & ~pressed) ? r_idle :
			    (reset_state == r_idle && pressed) ? r_reset1 :
			    reset_state;

   always @(posedge sysclk)
     if (sys_medevent) begin
	reset_state <= reset_state_next;
     end

   always @(posedge sysclk) begin
      sys_medcount <= sys_medcount + 6'd1;
   end

   assign sys_medevent = sys_medcount == 6'b111111;

   always @(posedge sysclk) begin
      sys_slowcount <= sys_slowcount + 12'd1;
   end

   assign sys_slowevent = sys_slowcount == 12'hfff;

   always @(posedge sysclk)
     if (sys_slowevent)
       hold <= { hold[8:0], button_r };

   assign press_detected = hold == 10'b1111111111;

   always @(posedge sysclk)
     if (sys_slowevent)
       press_history <= press_detected;

   assign pressed = (!press_history && press_detected);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
