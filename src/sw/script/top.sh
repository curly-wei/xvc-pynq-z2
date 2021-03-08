#/bin/bash
sw_proj_name=${1}
path_to_xsa=${2}

#source ${home}/petalinux/settings.sh

#virtualenv --python=/usr/bin/python2.7

if [ "${1}" = "" ]; then
  echo "empty argument 1 <project name>"
  echo "please folloing"
  echo "bash /<root-to-proj>/src/sw/top.sh <project name> <path to .xsa and contain .xsa file>"
  exit -1
fi

if [ "${2}" = "" ]; then
  echo "empty argument 2 <path to .xsa and contain .xsa file>"
  echo "please folloing"
  echo "bash /<root-to-proj>/src/sw/top.sh <project name> <path to .xsa and contain .xsa file>"
  exit -1
fi

if [ ! -f ${2} ]; then
  echo "${2}, this .xsa file does not exist"
  echo "Please ensure you have executed(compiled hw) /<root-to-proj>/src/hw/script/top.tcl"
  echo "and result of compiled hw is passed"
  exit -1
fi

current_gcc_ver="$(gcc -dumpversion)"
required_gcc_ver="5.0.0"

petalinux-create -t project -n ${sw_proj_name} --template zynq

xsa_file_path="$( readlink -m ${2} )"

cd ${sw_proj_name}

petalinux-config  --get-hw-description=${xsa_file_path}

#petalinux-create -t apps -n "xvcServer" --enable --template c
#cp "../../src/sw/app/xvcServer.c" "./components/apps/xvcServer/"

cp -f ../../src/sw/device_tree/pl.dtsi ./project-spec/meta-user/recipes-bsp/device-tree/files/pl-custom.dtsi
cp -f ../../src/sw/device_tree/system-top.dts ./project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

#petalinux-config -c kernel

#Enable UIO_PDRV_GENIRQ driver
#CONFIG_UIO=y
#CONFIG_UIO_CIF is not set
#CONFIG_UIO_PDRV_GENIRQ=y

#petalinux-build -c device-tree

petalinux-build 
