export VERILATOR_ROOT = $(HOME)/w/verilator

PROJECT		= uhdl

include cadr.mk

TOPLEVEL	?= top
SRCS_V		= .version $(CADR_SRCS)

TESTBENCHES	= busint_chaos_tb busint_tb busint_disk_tb ram_controller_tb mouse_tb keyboard_tb mmc_tb ps2_send_tb scancode_convert_tb spy_port_tb
TB_SRCS_V	= mmc_model.v ram_controller.v

VERILATORFLAGS	= --trace -LDFLAGS "-lSDL -lpthread"

obj_dir/V$(TOPLEVEL): SRCS_V += ram_controller.v mmc_dpi.v vga_dpi.v mmc_dpi.cpp vga_dpi.cpp

include boards/pipistrello.mk
include hdlmake.mk/hdlmake.mk

hardcopy:
	a2ps -A fill -B -2 --pro=color -o CADR4.ps $(CADR4_SRCS)
	ps2pdf CADR4.ps CADR4.pdf

###---!!! We really want to run this on commit.
.version: .git/COMMIT_EDITMSG .git/HEAD
	echo -n "\`define BUILD_ID 16'h" > .version
	git rev-parse --short=4 HEAD >> .version
clean::
	rm -f .version
