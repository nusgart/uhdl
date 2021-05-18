`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2019 03:28:26 PM
// Design Name: 
// Module Name: led_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led_controller(
    output wire [15:0] led,
    input wire sysclk,
    input wire reset,
    input wire sdram_reset,
    input wire [2:0] rst_st,
    input wire [11:0] bdst,
    input wire prom_disable,
    input wire [2:0] cpu_st,
    input wire [3:0] switches,
    input wire ddr_calib_done,
    input wire boot,
    input wire [13:0] pc,
    input wire [25:0] lc,
    input wire [23:0] bd_addr,
    input wire [5:0] bd_cmds
    );
   reg [15:0] r_led;
   reg [19:0] led_dimmer;
   reg led_enable;
   initial led_dimmer = 0;
   
   always @(posedge sysclk) begin
     led_dimmer <= led_dimmer + 1;
     led_enable <= led_dimmer[19];
   end
   
   reg prom_disabled;
   initial prom_disabled = 0;
   
   always @(posedge sysclk) begin
     if (reset) begin
        prom_disabled <= 0;
     end else if (prom_disable) begin
        prom_disabled <= 1;
      end else begin
        prom_disabled <= prom_disabled;
      end
   end
   
   reg calib_done;
   initial calib_done = 0;
   
   always @(posedge sysclk) begin
     if (sdram_reset) begin
       calib_done <= 1'b0;
     end else if (ddr_calib_done) begin
       calib_done <= 1;
     end else begin
       calib_done <= calib_done;
     end
   end
   
   //
   reg booted;
   initial booted = 0;
   
   always @(posedge sysclk) begin
     if (reset) begin
       booted <= 0;
     end else if (boot) begin
       booted <= 1;
      end else begin
        booted <= booted;
      end
   end
   
   
   always @(posedge sysclk) begin
     if (reset) begin
       r_led <= 0;
     end else begin
       case (switches)
       default: begin
         // monochromatic led's
         r_led[0] <= calib_done;
         r_led[1] <= cpu_st[2];
         r_led[2] <= cpu_st[1];
         r_led[3] <= cpu_st[0];
         // reset state
         r_led[4] <= rst_st[0];
         r_led[7] <= rst_st[1];
         r_led[10] <= rst_st[2];
         // promdisable
         r_led[5] <= prom_disabled;
         r_led[13] <= booted;
         r_led[6] <= bdst[0];
         r_led[8] <= bdst[1];
         r_led[9] <= bdst[2];
         r_led[11] <= bdst[3];
         r_led[12] <= bdst[4];
         r_led[14] <= bdst[5];
         r_led[15] <= bdst[6];
       end
       4'b0001: begin
         r_led[13:0] <= pc;
         r_led[14] <= calib_done;
         r_led[15] <= prom_disabled;
       end
       4'b0010: begin
         r_led[15:0] <= bd_addr[15:0];
       end
       4'b0011: begin
         r_led[15:0] <= {1'b0, bd_cmds[5:0], bd_addr[23:15]};
       end
       4'b0100: begin
         r_led[0] <= bdst[0];
         r_led[1] <= bdst[1];
         r_led[2] <= bdst[2];
         r_led[3] <= bdst[3];
         r_led[4] <= bdst[4];
         r_led[5] <= bdst[5];
         r_led[6] <= bdst[6];
         r_led[7] <= bdst[7];
         r_led[8] <= bdst[8];
         r_led[9] <= bdst[9];
         r_led[10] <= bdst[10];
         r_led[11] <= bdst[11];
         
       end
       4'b0101: begin
         r_led <= lc[15:0];
       end
       4'b0110: begin
         r_led <= lc[25:10];
       end
       
       4'b0111: begin
         r_led[13:0] <= pc;
         r_led[14] <= booted;
         r_led[15] <= prom_disabled;
       end
       
       endcase
     end
   end
   
   assign led = led_enable? r_led : 15'b0;
   /*
   assign led[3] = cpu_st[0]; //1'b1;
   assign led[2] = cpu_st[1]; //disk_state[1];
   assign led[1] = cpu_st[2]; //disk_state[2];
   assign led[0] = calib_done; //lpddr_calib_done;
   
   // led 0: B=4, R=5, G=6 
   assign led[4] = rst_st[0] & led_enable;
   assign led[5] = prom_disabled & led_enable;
   assign led[6] = bdst[0] & led_enable; //disk_state[0] & led_enable;
   // led 1 B=7
   assign led[7] = rst_st[1] & led_enable;
   assign led[8] = bdst[1] & led_enable; //~promdis & led_enable;
   assign led[9] = bdst[2] & led_enable; //disk_state[1] & led_enable;
   // led 2 B=10, R=11, G=12
   assign led[10] = rst_st[2] & led_enable;
   assign led[11] = bdst[3] & led_enable;//lpddr_reset;
   assign led[12] = bdst[4] & led_enable;//disk_state[2] & led_enable;//lpddr_reset;
   // led 3
   assign led[13] = a & led_enable;//lpddr_reset;
   assign led[14] = bdst[5] & led_enable;
   assign led[15] = bdst[6] & led_enable;
   
   */
endmodule
