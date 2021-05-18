<title>MIT CADR HDL</title>
# Preliminaries

This is a work-in progress port of the UHDL implementation of the MIT CADR to
the Arty-A7-35T FPGA.  Please note that some of the information below may be
inaccurate or incomplete as a result of this.

# Getting started

Requirements:

  - Icarus Verilog
  - Verilator
  - (Arty-A7 port): Xilinx Vivado 2018.3**
  - (Pipistrello port): Xilinx ISE 14.7

** Other versions have not been tested
```
git clone https://github.com/nusgart/uhdl
fossil clone https://tumbleweed.nu/r/hdlmake.mk hdlmake.mk.fossil

cd uhdl
mkdir hdlmake.mk
cd hdlmake.mk
fossil open  ../../hdlmake.mk.fossil

cd ../..
```

See hdlmake.mk/README for detailed instructions on how to run test
benches, create bitstreams and download them to boards.  To get an
overview of available targets run "make help".

A disk image is also required, for example
https://tumbleweed.nu/r/sys78/uv/disk.img.gz .  But any disk image
created by `diskmaker` in usim will work.

To generate the bitstream and to program the device:

```
make syn prog
```

# Supported boards

Currently supported FPGA boards are:

  - Pipistrello (Xilinx Spartan-6), with a Papilio Arcade Megawing
    (BPW5031) wing.

In the works:

  - Arty A7-35T with a VGA pmod, a PS/2 pmod + a PS/2 splitter, and a micro SD
    card pmod.
  - Arty A7-100T with a Pmod shield, with VGA, 2 x PS/2, micro SD card
    Pmods.

## Common notes

The current MMC code is _very_ peculiar about what kind of card it accepts;
it works at least with a SDSC card (<2GB).  It does not currently work with
SDHC cards or higher speed SD cards.

The disk image should be written directly to the SD card, using dd(1)
or similar.

Currently, all ports output VGA video.


## Pipistrello

Requirements:

  - Xilinx ISE 14.7
  - fpgaprog (https://tumbleweed.nu/r/fpgaprog/)

At the time of writing (2021-02-28, AMS), uhdl (and hdlmake.mk) for
the Pipistrello are being mainly developed on Centos 8.  Centos 8
requires minimal amount of work to get Xilinx ISE running properly.
Other GNU/Linux systems should work as long as they can run GNU Make
and Xilinx ISE.

The keyboard will be on PS/2 port A if using the Papilio Arcade
Megawing (BPW5031) board.  Mouse is currently non-functional.



## (WIP) Arty A7

The port to this board is a work in progress and does not boot to lisp yet.
Currently, it successfully loads the microcode but gets stuck some time later,
usually in a FINDCORE loop.

# Adding a new board

To add a new board, the following files are at a minimum needed:

   - boards/BOARD.mk
   - uhdl_BOARD.v
   - uhdl_BOARD_tb.v
   - ram_controller_BOARD.v
   - support_BOARD.v

Pass the BOARD variable to make to do synthesis or simulation.

# Test Protocol

This is a basic test protocol to assure that things work as they
should.

  - Check that that CC can talk to the board.
  - Check that Lisp boots (output on the display)
  - Check that keyboard can send input by trying out (DEMO:HACKS).
