#!/bin/sh

export PATH=$PATH:/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64

#cd ise
xst -intstyle ise -ifn "/home/ams/cpus-caddr/ise-lx45/top.xst" -ofn "/home/ams/cpus-caddr/ise-lx45/top.syr" && \
ngdbuild -intstyle ise -dd _ngo -sd ipcore_dir -nt timestamp -uc /home/ams/cpus-caddr/pipistrello/pipistrello_v2.01.ucf -p xc6slx45-csg324-3 top.ngc top.ngd   && \
map -intstyle ise -p xc6slx45-csg324-3 -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off -o top_map.ncd top.ngd top.pcf  && \
par -w -intstyle ise -ol high -mt off top_map.ncd top.ncd top.pcf  && \
trce -intstyle ise -v 3 -s 3 -n 3 -fastpaths -xml top.twx top.ncd -o top.twr top.pcf && \
bitgen -intstyle ise -f top.ut top.ncd

echo DONE!
