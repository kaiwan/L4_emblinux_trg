#!/bin/bash
# build_uboot_vexpress.sh
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
# MIT License 
name=$(basename $0)

##################### UPDATE as required
export CXX=arm-linux-gnueabi-  #hf-  # toolchain prefix ; tc to use; expect that the PATH is setup..
#export CXX=arm-none-eabi-  # toolchain prefix ; tc to use; expect that the PATH is setup..
#export CXX=arm-none-linux-gnueabi-  # toolchain prefix ; tc to use; expect that the PATH is setup..
###------###

export DIR=$(pwd)
#export UBOOT_FOLDER=../src-u-boot/u-boot-2019.07
#export UBOOT_FOLDER=${DIR}/u-boot-2013.10

source ./common.sh || {
	echo "$name: source failed! ./common.sh missing or invalid?"
	exit 1
}

# Target name: how do we get it?
# If boards.cfg is not present, generate it with:
#  tools/genboardscfg.py
#
# boards.cfg:
# List of boards
#   Automatically generated by tools/genboardscfg.py: don't edit
#
# Status, Arch, CPU, SoC, Vendor, Board, Target, Options, Maintainers
# 
# $ grep -i vexpress_ca boards.cfg 
# Active  arm  armv7  -  armltd  vexpress  vexpress_ca15_tc2 -   -
# Orphan  arm  armv7  -  armltd  vexpress  vexpress_ca5x2  -  Matt Waddel <matt.waddel@linaro.org>
# Orphan  arm  armv7  -  armltd  vexpress  vexpress_ca9x4  -  Matt Waddel <matt.waddel@linaro.org>
# $ 
TARGET=vexpress_ca9x4
CONFIG=${TARGET}_defconfig
TARGET_DESC="Versatile Express CA-9"

conf_and_build_uboot()
{
cd ${UBOOT_FOLDER}
local jobs=$((${CPU_CORES}*2))
local stat=0

[ ! -f configs/${CONFIG} ] && {
  echo "U-Boot configuration file \"configs/${CONFIG}\" not found? aborting ..."
  exit 1
}
echo "Config file: ${CONFIG}"

ShowTitle "Cleaning U-Boot ..."
runcmd "make -j${jobs} ARCH=arm CROSS_COMPILE=${CXX} clean"

ShowTitle "Configuring U-Boot for ${TARGET_DESC} ..."
runcmd "make ARCH=arm CROSS_COMPILE=${CXX} ${CONFIG}"
[ $? -ne 0 ] && {
  stat=$?
  echo "U-Boot configuration failed (status ${stat}) ! Aborting ..."
  exit ${stat}
}

ShowTitle "Attempting 'menuconfig' target now ..."
runcmd "make ARCH=arm CROSS_COMPILE=${CXX} menuconfig"
[ $? -ne 0 ] && {
  stat=$?
  echo "U-Boot menuconfig failed (status ${stat}) ! Aborting ..."
  exit ${stat}
}

ShowTitle "Building U-Boot for ${TARGET_DESC} ..."
runcmd "make -j${jobs} ARCH=arm CROSS_COMPILE=${CXX} all"
[ $? -ne 0 ] && {
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
which qemu-system-arm >/dev/null || {
  echo "${name}: qmeu-system-arm missing? Pl install aand retry ..."
  exit 1
}

ShowTitle "Running QEMU (will emulate U-Boot image as the kernel) ... (Ctrl-a x to exit QEMU)"
echo
runcmd "qemu-system-arm -M vexpress-a9 -m 128M -kernel ${UBOOT_FOLDER}/u-boot -nographic"
}

usage()
{
 echo "Usage: ${name} path-to-uboot-src-dir -c|-r"
 echo " -c: Configure and build U-Boot"
 echo " -r: just Run U-Boot (via qemu)"
 exit 1
}


###---------------------------------------------------------
### "main" here
###---------------------------------------------------------

# We expect that the toolchain path is in the PATH env var
which ${CXX}gcc > /dev/null 2>&1 || {
  echo "$name: Cross compiler ${CXX}gcc does not seem to be valid! PATH issue? Aborting..."
  exit 1
}
echo "Cross compiler:
$(${CXX}gcc --version)
[OK]
"

[ $# -lt 2 ] && {
  usage
  exit 1
}
UBOOT_FOLDER=$1
[ ! -d ${UBOOT_FOLDER} ] && {
  echo "$name: U-Boot source dir \"${UBOOT_FOLDER}\" invalid? aborting..."
  exit 1
}
echo "U-Boot dir :: ${UBOOT_FOLDER}"
if [ "$2" = "-c" ] ; then
  export CPU_CORES=$(nproc)
  #export CPU_CORES=$(getconf -a|grep "_NPROCESSORS_ONLN"|awk '{print $2}')
  [ -z "${CPU_CORES}" ] && CPU_CORES=2
  conf_and_build_uboot
elif [ "$2" = "-r" ] ; then
  run_it
else
  usage
fi

ShowTitle "Done."
