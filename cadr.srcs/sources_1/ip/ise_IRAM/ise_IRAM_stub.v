// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Thu May 30 17:18:50 2019
// Host        : nnusgart-G3-3579 running 64-bit Ubuntu 18.04.2 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/nnusgart/Xilinx/cadr/cadr.srcs/sources_1/ip/ise_IRAM/ise_IRAM_stub.v
// Design      : ise_IRAM
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tftg256-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module ise_IRAM(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[13:0],dina[48:0],douta[48:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [13:0]addra;
  input [48:0]dina;
  output [48:0]douta;
endmodule
