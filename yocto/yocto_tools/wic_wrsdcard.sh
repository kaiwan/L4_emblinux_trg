#!/bin/bash
# wic_wrsdcard.sh
# Generate and dd wic image for the BBB - BeagleBone Black ! - onto an uSD card
name=$(basename $0)
# Turn on unofficial Bash 'strict mode'! V useful
# "Convert many kinds of hidden, intermittent, or subtle bugs into immediate, glaringly obvious errors"
# ref: http://redsymbol.net/articles/unofficial-bash-strict-mode/ 
set -euo pipefail

PFX=$(dirname "$(which "$0")")    # dir in which the common code and tools reside
source "${PFX}"/common || {
  echo "${name}: could not source 'common' script, aborting..." ; exit 1
}


# Parameters:
#  $1 : machine name
gen_wic_img()
{
# If another target dir's soecified w/ --outdir , then it fails with
#  fstab not present? aborting...
runcmd_failchk 1 "wic create ${1} -e ${IMAGE_BASENAME}"  # --outdir $1"
echo "---------------------------------------------------"
ls -lht ${1}-*-mmcblk0.direct*
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
setup_env #-q

IMAGE_BASENAME=$(${PFX}/showvars2 |grep "^IMAGE_BASENAME" |cut -d: -f2)
[[ -z "${IMAGE_BASENAME}" ]] && failit "couldn't fetch value of IMAGE_BASENAME"
MACHINE=$(${PFX}/showvars2 MACHINE |grep "^MACHINE" |cut -d: -f2|tail -n1)
[[ -z "${MACHINE}" ]] && failit "couldn't fetch value of MACHINE"
 
gen_wic_img ${MACHINE}
imgfile=$(ls -t ${MACHINE}-*-mmcblk0.direct |col|head -n1)
[[ -z "${imgfile}" ]] && failit "couldn't get machine image filename"
write_wic_img "${imgfile}"
# Get rid of the older wic images
rm_older

exit 0
