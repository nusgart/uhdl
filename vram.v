`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/20/2019 07:00:58 PM
// Design Name: 
// Module Name: vram
// Project Name: LM-3 UHDL
// Target Devices: 
// Tool Versions: 
// Description: This module implements the VRAM for the Artix 7
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vram(
  input wire clk1,
  input wire clk2,
  input wire we, 
  input wire en1, 
  input wire en2, 
  input wire [14:0] addr1, 
  input wire [14:0] addr2, 
  input wire [31:0] di, 
  output reg [31:0] res1, 
  output reg [31:0] res2 );
  
  //
  /* synthesis syn_ramstyle="block_ram" */
  reg[31:0] RAM [8191:0];
  
  reg[31:0] do1;
  reg[31:0] do2;
  /* synthesis syn_ramstyle="block_ram" */
  always @(posedge clk1) begin
    if (we == 1'b1)
      RAM[addr1] <= di;
    do1 <= RAM[addr1];
  end

  always @(posedge clk2) begin
    do2 <= RAM[addr2];
  end
  
  always @(posedge clk1) begin
    if (en1 == 1'b1)        res1 <= do1;
    end
  
  always @(posedge clk2) begin
    if (en2 == 1'b1)
      res2 <= do2;
  end 
endmodule