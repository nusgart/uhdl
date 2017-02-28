#!/bin/sh

BASE=/opt/Xilinx/14.7/ISE_DS

export PATH=$PATH:$BASE/ISE/bin/lin64

. $BASE/settings64.sh

#/home/ams/cpus-caddr/xvcd/xvcd &

xilinx_xvc host=127.0.0.1:2542 disableversioncheck=true

