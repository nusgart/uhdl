VENDOR		= xilinx-vivado
TARGET		= xc7a35ticsg324-1l
CONSTRAINTS	= boards/arty_a7.xdc

PROGRAMMER	= fpgaprog

XSTFLAGS	= -sd cores/xilinx
NGDBUILDFLAGS	= -sd cores/xilinx

TOPLEVEL	= top_lx45
SYN_SRCS_V	+= \
	top_a7.v \
	support_a7.v \
	ram_controller_a7.v \
	cores/xilinx/clk_wiz.v \
	cores/xilinx/ise_MMEM.v \
	cores/xilinx/ise_SPC.v \
	cores/xilinx/ise_VMEM0.v \
	cores/xilinx/ise_DRAM.v \
	cores/xilinx/ise_PDL.v \
	cores/xilinx/ise_AMEM.v \
	cores/xilinx/ise_VMEM1.v \
	cores/xilinx/ise_IRAM.v \
	cores/xilinx/ise_vram.v \
	cores/xilinx/mig_32bit/user_design/rtl/infrastructure.v \
	cores/xilinx/mig_32bit/user_design/rtl/mcb_controller/iodrp_controller.v \
	cores/xilinx/mig_32bit/user_design/rtl/mcb_controller/iodrp_mcb_controller.v \
	cores/xilinx/mig_32bit/user_design/rtl/mcb_controller/mcb_raw_wrapper.v \
	cores/xilinx/mig_32bit/user_design/rtl/mcb_controller/mcb_soft_calibration.v \
	cores/xilinx/mig_32bit/user_design/rtl/mcb_controller/mcb_soft_calibration_top.v \
	cores/xilinx/mig_32bit/user_design/rtl/mcb_controller/mcb_ui_top.v \
	cores/xilinx/mig_32bit/user_design/rtl/memc_wrapper.v \
	cores/xilinx/mig_32bit/user_design/rtl/mig_32bit.v

# support_tb.v
isim: TESTBENCHES += top_a7_tb

