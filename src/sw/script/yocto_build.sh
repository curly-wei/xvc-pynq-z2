# /bin/bash
## ref
## https://coldnew.github.io/c3e8558e/
yocto_branch=zeus #oct-2019, newest branch suit for meta-xilinx 
git clone git://git.yoctoproject.org/poky # -b ${yocto_branch}
cd poky
git clone git://github.com/Xilinx/meta-xilinx # -b ${yocto_branch}
