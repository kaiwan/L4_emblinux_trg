#!/bin/bash
#
# Loop mount the Yocto-generated rootfs in order to easily view it's content.
# Pl ENSURE that the VM is Not running when you use this script!!
#  -the image will/might get corrupted!
#
# Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# (c) kaiwanTECH
MNTPT=/mnt/tmp
name=$(basename $0)
LSOF_CHECK=0

[ $# -ne 1 ] && {
 echo "Usage: ${name} <rootfs-image-file>"
 exit 1
}
[ ! -f $1 ] && {
 echo "${name}: root filesystem image file \"${1}\" unavailable, aborting..."
 exit 1
}
IMG=$(realpath $1)
TOP=$(pwd)

file ${IMG} | egrep -i "compress|tar" && {
  echo "File passed is compressed/tarball..."
  #exit 1
  # TODO / RELOOK :: Here we ASSUME it's an XZ compressed file
  echo "Uncompressing it now in a temp dir ..."
  TMPDIR=$(mktemp -d)
  cp ${IMG} ${TMPDIR}
  cd ${TMPDIR}
  rm -f $(basename ${IMG})
  unxz ${IMG}
  ls -lh ${IMG}
}

echo "${name}: Rootfs image file: ${IMG}"

[ ${LSOF_CHECK} -eq 1 ] && {
 echo "${name}: Please wait... checking if rootfs image file above is currently in use ..."
 sudo lsof 2>/dev/null |grep ${IMG} && {
  echo "${name}: Rootfs image file \"${IMG}\" currently in use, aborting..." 
  cd ${TOP}
  exit 1
 }
}

sudo mkdir -p ${MNTPT} 2>/dev/null
echo "${name}: Okay, loop mounting rootfs image file now ..."
# already mounted? if so, first unmount it
mount |grep -iq ${MNTPT} && {
  sync
  sudo umount ${MNTPT}
}

sudo mount -o loop ${IMG} ${MNTPT} && {
 echo "${IMG} loop mounted at ${MNTPT}"
 mount |grep "${IMG}"
 echo
 echo "ls ${MNTPT} :"
 sudo ls ${MNTPT}
} || {
 echo "${name}: ${IMG} loop mounting failed! aborting..."
  rm -rf ${TMPDIR}
  cd ${TOP}
  exit 1
}

rm -rf ${TMPDIR}
cd ${TOP}
exit 0
