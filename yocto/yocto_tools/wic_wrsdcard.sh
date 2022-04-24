#!/bin/bash
# wic_wrsdcard.sh
# Generate and dd wic image for the BBB - BeagleBone Black ! - onto an uSD card
name=$(basename $0)

#-------------- r u n c m d -------------------------------------------
# Display and run the provided command.
# Parameter 1 : the command to run
runcmd()
{
SEP="------------------------------"
[ $# -eq 0 ] && return
echo "${SEP}
$*"
eval "$*"
}

#-------------- r u n c m d _ f a i l c h k ---------------------------
# Display and run the provided command; check for failure case
#  Parameter 1 : 0 => non-fatal, +ve => fatal exit with this error val
#  Parameter 2... : the command to run
runcmd_failchk()
{
SEP="------------------------------"
[ $# -eq 0 ] && return
local errcode=$1
shift
echo "${SEP}
$*"
eval "$*" || {
  echo -n " *WARNING* execution failure"
  if [ ${errcode} -ne 0 ] ; then
    echo " : FATAL error (${errcode}), aborting now"
    exit ${errcode}
  fi
}
}

MACH=beaglebone-yocto
REF_IMAGE_TARGET=core-image-base   # core-image-minimal
# Parameters:
#  $1 : the (temp) folder to write the image into
gen_wic_img()
{
# If another target dir's soecified w/ --outdir , then it fails with
#  fstab not present? aborting...
runcmd_failchk 1 "wic create ${MACH} -e ${REF_IMAGE_TARGET}"  # --outdir $1"
echo "---------------------------------------------------"
ls -lht ${MACH}-*-mmcblk0.direct*
echo "---------------------------------------------------"
}

SDDEV=mmcblk0
# Parameters:
#  $1 : the wic image file to write onto the SDcard $SDDEV
write_wic_img()
{
[ ! -f "$1" ] && {
  echo "${name}:gen_wic_img(): wic image file $1 not present? aborting..." ; exit 1
}
echo "
Ensure the uSD card's inserted... press [Enter] to continue, ^C to abort..."
read
echo
ls -lh "$1"

echo
runcmd_failchk 1 "lsblk |grep -w ${SDDEV}"
mount | grep -q "${SDDEV}" && {
  echo "${name}: device ${SDDEV} currently mounted, unmounting partitions now ..."
  sudo umount /dev/${SDDEV}p[12] || exit 2
  sync
}

echo
echo -n "${name}:write_wic_img(): pl CONFIRM write:
 ${1} --> /dev/${SDDEV}
[y/n]: "
local re
read -r re
[ "${re}" != "y" ] && exit 0
echo

runcmd_failchk 1 "sudo dd bs=1M if=$1 of=/dev/${SDDEV} ; sync"
echo "--- write done ---
 can eject the uSD card"
}

rm_older()
{
local re
local num=$(ls -t ${MACH}-*-mmcblk0.direct* |col|wc -l)
[ ${num} -le 3 ] && return  # the newest 3 images are the ones we just generated!
local numdel=$((num-3))
local olderfiles=$(ls -t ${MACH}-*-mmcblk0.direct* |col|tail -n${numdel})
echo "Detected older wic image files in the workspace:
${olderfiles}

Delete them? (y/n) "
read -r re
[ "${re}" != "y" ] && return
rm -f ${olderfiles}
}


### 'main' here

which wic >/dev/null 2>&1 || {
  echo "${name}: must run this from a sourced bitbake env
(must cd to the Yocto workspace and run 'source oe-init-build-env <build-dir>' first"
  exit 1
}
 
gen_wic_img
imgfile=$(ls -t ${MACH}-*-mmcblk0.direct |col|head -n1)
write_wic_img "${imgfile}"
# Get rid of the older wic images
rm_older

exit 0
