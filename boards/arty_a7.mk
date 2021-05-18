VENDOR		= xilinx-vivado
TARGET		= xc7a100ticsg324-1l
CONSTRAINTS	= boards/arty_a7.xdc

PROGRAMMER	= vivado

XCORES		= boards/arty_a7/cores/xilinx

XSTFLAGS	= -sd $(XCORES)
NGDBUILDFLAGS	= -sd $(XCORES)

TOPLEVEL	= uhdl_arty_a7
SYN_SRCS_V	+= \
	uhdl_arty_a7.v \
	support_arty_a7.v \
	ram_controller_X7.sv \
	led_controller.sv

SYN_SRCS_IP	+= \
	$(XCORES)/clk_wiz_0/clk_wiz_0.xci \
	$(XCORES)/clk_wiz_dram/clk_wiz_dram.xci \
	$(XCORES)/clk_wiz/clk_wiz.xci \
	$(XCORES)/ddr_memif/ddr_memif.xci \
	$(XCORES)/dram_memif/dram_memif.xci \
	$(XCORES)/ise_AMEM/ise_AMEM.xci \
	$(XCORES)/ise_DRAM/ise_DRAM.xci \
	$(XCORES)/ise_IRAM/ise_IRAM.xci \
	$(XCORES)/ise_MMEM/ise_MMEM.xci \
	$(XCORES)/ise_PDL/ise_PDL.xci \
	$(XCORES)/ise_SPC/ise_SPC.xci \
	$(XCORES)/ise_VMEM0/ise_VMEM0.xci \
	$(XCORES)/ise_VMEM1/ise_VMEM1.xci \
	$(XCORES)/ise_vram/ise_vram.xci \
	$(XCORES)/mig_7series_0/mig_7series_0.xci \
	$(XCORES)/sysclk_wiz/sysclk_wiz.xci

# support_tb.v
isim: TESTBENCHES += uhdl_arty_a7_tb
