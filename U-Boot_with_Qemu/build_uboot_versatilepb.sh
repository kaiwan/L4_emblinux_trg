#!/bin/bash
# 1build_uboot_versatilepb.sh
# 
# Helper shell script to configure and build Das U-Boot bootloader
# for the ARM Versatile Express platform.
# We test it using QEMU.
#
# Based on:
# http://balau82.wordpress.com/2010/03/10/u-boot-for-arm-on-qemu/
#
# (C) Kaiwan NB.
# kaiwanTECH.
# 
name=$(basename $0)

##################### UPDATE as required
#export CXX=arm-none-eabi-  # toolchain prefix ; tc to use; expect that the PATH is setup..
export CXX=arm-none-linux-gnueabi-  # toolchain prefix ; tc to use; expect that the PATH is setup..
###------###

export DIR=$(pwd)
export UBOOT_FOLDER=${DIR}/u-boot-2013.10

source ./common.sh || {
	echo "$name: source failed! ./common.sh missing or invalid?"
	exit 1
}

# Target name: how do we get it?
# $ grep -i versatilepb u-boot-2014.04/boards.cfg 
# Status, Arch,    CPU:SPLCPU,  SoC,    Vendor, Board name,    Target,   Options,       Maintainers
# Active  arm     arm926ejs  versatile  armltd  versatile   versatilepb      versatile:ARCH_VERSATILE_PB
#
# If boards.cfg is not present, generate it with:
#  tools/genboardscfg.py
TARGET=versatilepb
CONFIG=${TARGET}_config
TARGET_DESC="Versatile PB"

conf_and_build_uboot()
{
cd ${UBOOT_FOLDER}
JOBS=$((${CPU_CORES}*2))
#echo "---JOBS = ${JOBS}"

ShowTitle "Cleaning U-Boot ..."
make -j${JOBS} ARCH=arm CROSS_COMPILE=${CXX} clean

ShowTitle "Configuring U-Boot for ${TARGET_DESC} ..."
make ARCH=arm CROSS_COMPILE=${CXX} ${CONFIG} || {
  stat=$?
  echo "U-Boot configuration failed (status ${stat}) ! Aborting ..."
  exit ${stat}
}

ShowTitle "Building U-Boot for ${TARGET_DESC} ..."
make -j${JOBS} ARCH=arm CROSS_COMPILE=${CXX} all || {
  stat=$?
  echo "U-Boot build failed (status ${stat}) ! Aborting ..."
  exit ${stat}
}

ShowTitle "Building U-Boot successful.."
file ./u-boot
ls -lh ./u-boot
cd ${DIR}
}

run_it()
{
cd ${DIR} || exit 1
ShowTitle "Running QEMU (will emulate U-Boot image as the kernel) ... (Ctrl-A X to exit QEMU)"
echo "Doing :: qemu-system-arm -M ${TARGET} -m 128M -kernel ${UBOOT_FOLDER}/u-boot -nographic"
echo
qemu-system-arm -M ${TARGET} -m 128M -kernel ${UBOOT_FOLDER}/u-boot -nographic
}

usage()
{
 echo "Usage: ${name} c|r"
 echo " c: Configure, build and then run U-Boot (via qemu)"
 echo " r: just Run U-Boot (via qemu)"
 exit 1
}


###---------------------------------------------------------
### "main" here
###---------------------------------------------------------
#check_root_AIA

# We expect that the toolchain path is in the PATH env var
which ${CXX}gcc > /dev/null 2>&1 || {
  echo "$name: Cross toolchain does not seem to be valid! PATH issue? Aborting..."
  exit 1
}

check_folder_AIA ${UBOOT_FOLDER}
[ $# -ne 1 ] && usage

if [ "$1" = "c" ] ; then
  export CPU_CORES=$(getconf -a|grep "_NPROCESSORS_ONLN"|awk '{print $2}')
  [ -z ${CPU_CORES} ] && CPU_CORES=2
  conf_and_build_uboot
elif [ "$1" = "r" ] ; then
  run_it
else
  usage
fi

ShowTitle "Done."
