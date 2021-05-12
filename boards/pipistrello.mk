VENDOR		= xilinx-ise
TARGET		= xc6slx45-csg324-3
CONSTRAINTS	= boards/pipistrello.ucf

PROGRAMMER	= fpgaprog

XCORES		= boards/pipistrello/cores/xilinx

XSTFLAGS	= -sd $(XCORES)
NGDBUILDFLAGS	= -sd $(XCORES)

TOPLEVEL	= uhdl_pipistrello
SYN_SRCS_V	+= \
	uhdl_pipistrello.v \
	support_pipistrello.v \
	ram_controller_pipistrello.v \
	$(XCORES)/clk_wiz.v \
	$(XCORES)/ise_MMEM.v \
	$(XCORES)/ise_SPC.v \
	$(XCORES)/ise_VMEM0.v \
	$(XCORES)/ise_DRAM.v \
	$(XCORES)/ise_PDL.v \
	$(XCORES)/ise_AMEM.v \
	$(XCORES)/ise_VMEM1.v \
	$(XCORES)/ise_IRAM.v \
	$(XCORES)/ise_vram.v \
	$(XCORES)/mig_32bit/user_design/rtl/infrastructure.v \
	$(XCORES)/mig_32bit/user_design/rtl/mcb_controller/iodrp_controller.v \
	$(XCORES)/mig_32bit/user_design/rtl/mcb_controller/iodrp_mcb_controller.v \
	$(XCORES)/mig_32bit/user_design/rtl/mcb_controller/mcb_raw_wrapper.v \
	$(XCORES)/mig_32bit/user_design/rtl/mcb_controller/mcb_soft_calibration.v \
	$(XCORES)/mig_32bit/user_design/rtl/mcb_controller/mcb_soft_calibration_top.v \
	$(XCORES)/mig_32bit/user_design/rtl/mcb_controller/mcb_ui_top.v \
	$(XCORES)/mig_32bit/user_design/rtl/memc_wrapper.v \
	$(XCORES)/mig_32bit/user_design/rtl/mig_32bit.v

# support_tb.v
isim: TESTBENCHES += uhdl_pipistrello_tb
