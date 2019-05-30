##################################################################################################
## 
##  Xilinx, Inc. 2010            www.xilinx.com 
##  Mon May 20 22:03:20 2019

##  Generated by MIG Version 4.2
##  
##################################################################################################
##  File name :       example_top.xdc
##  Details :     Constraints file
##                    FPGA Family:       ARTIX7
##                    FPGA Part:         XC7A35T-FTG256
##                    Speedgrade:        -3
##                    Design Entry:      VERILOG
##                    Frequency:         333.32999999999998 MHz
##                    Time Period:       3000 ps
##################################################################################################

##################################################################################################
## Controller 0
## Memory Device: DDR3_SDRAM->Components->Alchitry-Au-DDR3
## Data Width: 16
## Time Period: 3000
## Data Mask: 1
##################################################################################################
############## NET - IOSTANDARD ##################


# PadFunction: IO_L4N_T0_35 
set_property IOSTANDARD LVCMOS25 [get_ports {init_calib_complete}]
set_property PACKAGE_PIN A3 [get_ports {init_calib_complete}]

# PadFunction: IO_L1N_T0_AD4N_35 
set_property IOSTANDARD LVCMOS25 [get_ports {tg_compare_error}]
set_property PACKAGE_PIN A7 [get_ports {tg_compare_error}]

