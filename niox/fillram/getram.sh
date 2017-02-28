#!/bin/sh

BASE=/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64

NGC=../ise/top_niox.ngc
#NGC=./top_niox.ngc
OUT=./top_niox.edf

rm -f $OUT
$BASE/ngc2edif $NGC $OUT
