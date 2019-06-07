# Arty A7-35T DDR3 interface pins

### address
#set_property PACKAGE_PIN T8 [get_ports {ddr3_addr[13]}]
#set_property PACKAGE_PIN T6 [get_ports {ddr3_addr[12]}]
#set_property PACKAGE_PIN U6 [get_ports {ddr3_addr[11]}]
#set_property PACKAGE_PIN R6 [get_ports {ddr3_addr[10]}]
#set_property PACKAGE_PIN V7 [get_ports {ddr3_addr[9]}]
#set_property PACKAGE_PIN R8 [get_ports {ddr3_addr[8]}]
#set_property PACKAGE_PIN U7 [get_ports {ddr3_addr[7]}]
#set_property PACKAGE_PIN V6 [get_ports {ddr3_addr[6]}]
#set_property PACKAGE_PIN R7 [get_ports {ddr3_addr[5]}]
#set_property PACKAGE_PIN N6 [get_ports {ddr3_addr[4]}]
#set_property PACKAGE_PIN T4 [get_ports {ddr3_addr[3]}]
#set_property PACKAGE_PIN N4 [get_ports {ddr3_addr[2]}]
#set_property PACKAGE_PIN M6 [get_ports {ddr3_addr[1]}]
#set_property PACKAGE_PIN R2 [get_ports {ddr3_addr[0]}]
### bank address
#set_property PACKAGE_PIN P2 [get_ports {ddr3_ba[2]}]
#set_property PACKAGE_PIN P4 [get_ports {ddr3_ba[1]}]
#set_property PACKAGE_PIN R1 [get_ports {ddr3_ba[0]}]
### data
#set_property PACKAGE_PIN R3 [get_ports {ddr3_dq[15]}]
#set_property PACKAGE_PIN U3 [get_ports {ddr3_dq[14]}]
#set_property PACKAGE_PIN T3 [get_ports {ddr3_dq[13]}]
#set_property PACKAGE_PIN V1 [get_ports {ddr3_dq[12]}]
#set_property PACKAGE_PIN V5 [get_ports {ddr3_dq[11]}]
#set_property PACKAGE_PIN U4 [get_ports {ddr3_dq[10]}]
#set_property PACKAGE_PIN T5 [get_ports {ddr3_dq[9]}]
#set_property PACKAGE_PIN M2 [get_ports {ddr3_dq[7]}]
#set_property PACKAGE_PIN V4 [get_ports {ddr3_dq[8]}]
#set_property PACKAGE_PIN L4 [get_ports {ddr3_dq[6]}]
#set_property PACKAGE_PIN M1 [get_ports {ddr3_dq[5]}]
#set_property PACKAGE_PIN M3 [get_ports {ddr3_dq[4]}]
#set_property PACKAGE_PIN L6 [get_ports {ddr3_dq[3]}]
#set_property PACKAGE_PIN K3 [get_ports {ddr3_dq[2]}]
#set_property PACKAGE_PIN L3 [get_ports {ddr3_dq[1]}]
#set_property PACKAGE_PIN K5 [get_ports {ddr3_dq[0]}]

### data strobe
#set_property PACKAGE_PIN U2 [get_ports {ddr3_dqs_p[1]}]
#set_property PACKAGE_PIN V2 [get_ports {ddr3_dqs_n[1]}]
#set_property PACKAGE_PIN N2 [get_ports {ddr3_dqs_p[0]}]
#set_property PACKAGE_PIN N1 [get_ports {ddr3_dqs_n[0]}]

### command signals
#set_property PACKAGE_PIN U8 [get_ports ddr3_cs_n]
#set_property PACKAGE_PIN M4 [get_ports ddr3_cas_n]
#set_property PACKAGE_PIN P3 [get_ports ddr3_ras_n]
#set_property PACKAGE_PIN P5 [get_ports ddr3_we_n]
#set_property PACKAGE_PIN K6 [get_ports ddr3_reset_n]

## datamask
#set_property PACKAGE_PIN L1 [get_ports {ddr3_dm[0]}]
#set_property PACKAGE_PIN U1 [get_ports {ddr3_dm[1]}]
### clock and clock enable
#set_property PACKAGE_PIN U9 [get_ports ddr3_ck_p]
#set_property PACKAGE_PIN V9 [get_ports ddr3_ck_n]
#set_property PACKAGE_PIN N5 [get_ports ddr3_cke]
# system clock
set_property PACKAGE_PIN E3 [get_ports sysclk]
set_property PACKAGE_PIN H5 [get_ports {led[3]}]
set_property PACKAGE_PIN J5 [get_ports {led[2]}]
set_property PACKAGE_PIN T9 [get_ports {led[1]}]
set_property PACKAGE_PIN T10 [get_ports {led[0]}]
set_property PACKAGE_PIN D10 [get_ports rs232_rxd]
set_property PACKAGE_PIN A9 [get_ports rs232_txd]
set_property PACKAGE_PIN G13 [get_ports vga_b]
set_property PACKAGE_PIN B11 [get_ports vga_g]
set_property PACKAGE_PIN D12 [get_ports vga_hsync]
set_property PACKAGE_PIN A11 [get_ports vga_r]
set_property PACKAGE_PIN D13 [get_ports vga_vsync]
set_property PACKAGE_PIN A8 [get_ports switch]
set_property PACKAGE_PIN D15 [get_ports kb_ps2_clk]
set_property PACKAGE_PIN E15 [get_ports kb_ps2_data]
set_property PACKAGE_PIN V10 [get_ports ms_ps2_clk]
set_property PACKAGE_PIN U12 [get_ports ms_ps2_data]
set_property PACKAGE_PIN D4 [get_ports mmc_cs]
set_property PACKAGE_PIN D3 [get_ports mmc_di]
set_property PACKAGE_PIN F4 [get_ports mmc_do]
set_property PACKAGE_PIN F3 [get_ports mmc_sclk]

set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets sysclk_IBUF]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets ulpi_clk_in_c]


set_property IOSTANDARD LVCMOS33 [get_ports kb_ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports kb_ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports mmc_cs]
set_property IOSTANDARD LVCMOS33 [get_ports mmc_di]
set_property IOSTANDARD LVCMOS33 [get_ports mmc_do]
set_property IOSTANDARD LVCMOS33 [get_ports mmc_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports ms_ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports ms_ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports rs232_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports rs232_txd]
set_property IOSTANDARD LVCMOS33 [get_ports switch]
set_property IOSTANDARD LVCMOS33 [get_ports sysclk]
set_property IOSTANDARD LVCMOS33 [get_ports vga_b]
set_property IOSTANDARD LVCMOS33 [get_ports vga_g]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_r]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]

set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]




set_property IOSTANDARD SSTL135 [get_ports {ddr3_dm[1]}]
set_property IOSTANDARD SSTL135 [get_ports {ddr3_dm[0]}]
set_property PACKAGE_PIN R5 [get_ports ddr3_odt]
set_property IOSTANDARD SSTL135 [get_ports ddr3_odt]
set_property IOSTANDARD SSTL135 [get_ports ddr3_cs_n]
