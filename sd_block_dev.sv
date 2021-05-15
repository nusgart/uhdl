`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2019 11:06:07 AM
// Design Name: 
// Module Name: sd_block_dev
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


module sd_block_dev(
    // Outputs
   output wire [11:0] bd_state,
   output wire [15:0] bd_data_out,
   output wire bd_bsy,
   output wire bd_err,
   output wire bd_iordy,
   output wire bd_rdy,
   output wire mmc_cs,
   output wire mmc_do,
   output wire mmc_sclk,
   // Inputs
   input wire [15:0] bd_data_in,
   input wire [1:0] bd_cmd,
   input wire [23:0] bd_addr,
   input wire bd_rd,
   input wire bd_start,
   input wire bd_wr,
   input wire clk,
   input wire mmc_di,
   input wire mmc_clk,
   input wire reset
    );
    
    localparam [3:0]
      STATE_IDLE = 4'd0,
      STATE_RESET = 4'd1,
      STATE_READ = 4'd2,
      STATE_WRITE = 4'd3,
      STATE_WAIT = 4'd4;
    //// SD-module iface
    // set to 1 to command a block read
    reg rd;
    // set to 1 to command a block write
    reg wr;
    
    wire sd_reset;
    wire sd_busy;
    wire sd_error;
    wire [7:0] sd_state;
    wire [2:0] sd_errcode;
    
    wire [7:0] dout;
    wire dout_valid;
    reg dout_taken;
    
    reg [7:0] din;
    reg din_valid;
    wire din_taken;
    
    reg [3:0] state;
    
    // state mech
    reg [23:0] addr;
    reg [15:0] data_out;
    reg [15:0] data_in;
    // read/write state
    reg [9:0] byte_ctr;
    reg [1:0] block_ctr;
    wire hi_byte;
    assign hi_byte = byte_ctr[0];
    
    // board output state
    reg iordy;
    reg rdy;
    reg err;
    assign sd_reset = reset || (state == STATE_RESET);
    
    
    assign bd_bsy = state != STATE_IDLE;
    assign bd_iordy = iordy;
    assign bd_err = err;
    assign bd_rdy = rdy;
    assign bd_data_out = data_out;
    assign bd_state = {state, sd_state};
    
    task set_state;
      byte_ctr <= 0;
      block_ctr <= 0;
      rdy <= 0;
      iordy <= 0;
      data_out <= 0;
      err <= 0;
      din_valid <= 1'b0;
      dout_taken <= 1'b0;
    endtask
    
    always @(posedge clk) begin
      if (reset) begin
        rd <= 1'b0;
        wr <= 1'b0;
        addr <= 23'b0;
        byte_ctr <= 0;
        block_ctr <= 0;
        set_state();
        state <= STATE_RESET;
      end else
      case (state)
      STATE_IDLE: begin
        if (bd_start) begin
          case (bd_cmd)
          2'b00: begin
            // reset
            state <= STATE_RESET;
            set_state();
          end
          2'b01: begin
            // read
            state <= STATE_READ;
            addr <= bd_addr;
            set_state();
            iordy <= 1'b0;
            rdy <= 1'b0;
          end
          2'b10: begin
            // write
            state <= STATE_WRITE;
            set_state();
            addr <= bd_addr;
            iordy <= 1'b1;
            rdy <= 1'b0;
          end
          2'b11: begin
            // ????
            err <= 1'b1;
            rdy <= 1'b1;
          end
          endcase
        end else begin
          rdy <= 1'b1;
          iordy <= 1'b0;
          err <= 1'b0;
        end
      end
      STATE_RESET: begin
        state <= STATE_WAIT;
      end
      
      STATE_WRITE: begin
        wr <= 1'b1;
        rdy <= 1'b1;
        
        if (iordy && bd_wr) begin
          data_in <= bd_data_in;
          din <= bd_data_in[7:0];
          din_valid <= 1'b1;
          iordy <= 1'b0;
        end
        if (!iordy && din_taken) begin
          byte_ctr <= byte_ctr + 1;
          if (hi_byte) begin
            iordy <= 1'b1;
            din_valid <= 1'b0;
          end else begin
            din <= data_in[15:7];
            din_valid <= 1'b1;
          end
          if (byte_ctr == 9'd511) begin
            block_ctr <= block_ctr + 1;
            byte_ctr <= 9'd0;
            addr <= addr + 1;
            // if we have read 2 blocks then we are done
            if (block_ctr == 1'b1) begin
              wr <= 1'b0;
              rdy <= 1'b0;
              state <= STATE_WAIT;
            end
          end
        end
      end
      
      STATE_READ: begin
        rd <= 1'b1;
        rdy <= 1'b1;
        
        if (iordy && bd_rd) begin
          iordy <= 0;
          dout_taken <= 1'b1;
          byte_ctr <= byte_ctr + 1;
        end
        
        
        if (dout_valid && ~iordy) begin
          if (!hi_byte) begin
             data_out[7:0] <= dout;
             dout_taken <= 1'b1;
             byte_ctr <= byte_ctr + 1;
          end else begin
            data_out[15:8] <= dout;
            iordy <= 1'b1;
          end
        end
        
        if (byte_ctr == 9'd511 && iordy && bd_rd) begin
          block_ctr <= block_ctr + 1'b1;
          addr <= addr + 1;
          if (block_ctr == 1) begin
            rd <= 1'b0;
            state <= STATE_WAIT;
            rdy <= 1'b0;
          end
        end
        
      end
      
      // wait for any SD io to complete
      STATE_WAIT: begin
        rd <= 1'b0;
        wr <= 1'b0;
        if (!sd_busy) begin
          state <= STATE_IDLE;
          rdy <= 1'b1;
        end
      end
      endcase
      
    end
    
    
    
    
    sd_controller #(
       .CLOCK_RATE(40_625_000)
    ) sd (
      .cs(mmc_cs),
      .mosi(mmc_do),
      .miso(mmc_di),
      .sclk(mmc_sclk),
      .card_present(1'b1),
      .card_write_prot(1'b0),
      
      .rd(1'b0),
      .rd_multiple(rd),
      .dout(dout),
      .dout_taken(dout_taken),
      .dout_avail(dout_valid),
      
      .wr(1'b0),
      .wr_multiple(wr),
      .din(din),
      .din_valid(din_valid),
      .din_taken(din_taken),
      
      .addr(addr),
      .erase_count(8'd2),
      .sd_busy(sd_busy),
      .sd_fsm(sd_state),
      .sd_error(sd_error),
      .sd_error_code(sd_errcode),
      .reset(sd_reset),
      .clk(clk)
    );
endmodule
