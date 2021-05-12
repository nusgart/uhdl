export VERILATOR_ROOT = $(HOME)/w/verilator

BOARD		?= pipistrello
PROJECT		= $(if $(BOARD), uhdl_$(BOARD), uhdl)

include cadr.mk

TOPLEVEL	?= uhdl
SRCS_V		= build_id.vh $(CADR_SRCS)

TESTBENCHES	= busint_tb busint_disk_tb ram_controller_tb mouse_tb keyboard_tb mmc_tb scancode_convert_tb spy_port_tb
TB_SRCS_V	= mmc_model.v ram_controller.v

VERILATORFLAGS	= --trace -LDFLAGS "-lSDL -lpthread"

obj_dir/V$(TOPLEVEL): SRCS_V += ram_controller.v mmc_dpi.v vga_dpi.v mmc_dpi.cpp vga_dpi.cpp

ifneq ($(BOARD),)
include boards/$(BOARD).mk
endif
include hdlmake.mk/hdlmake.mk

hardcopy:
	a2ps -A fill -B -2 --pro=color -o CADR4.ps $(CADR4_SRCS)
	ps2pdf CADR4.ps CADR4.pdf

###---!!! We really want to run this on commit.
build_id.vh: .git/COMMIT_EDITMSG .git/HEAD
	echo -n "\`define BUILD_ID 16'h" > build_id.vh
	git rev-parse --short=4 HEAD >> build_id.vh
clean::
	rm -f build_id.vh
