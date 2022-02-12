#!/bin/bash
export name=$(basename "$0")
PFX=$(dirname "$(which "$0")")    # dir in which the common code and tools reside
source "${PFX}"/common || {
  echo "${name}: could not source 'common' script, aborting..." ; exit 1
}
setup_env #-q

PKG_MANIFEST=tmp/deploy/licenses/${IMAGE}-${MACH}/package.manifest
[ ! -f ${PKG_MANIFEST} ] && {
  echo "Oops, the package manifest file \"${PKG_MANIFEST}\" isn't found"
  exit 1
}

numpkg=$(wc -l ${PKG_MANIFEST} |cut -d" " -f1)
[ ${numpkg} -le 0 ] && {
  echo "Oops, you have 0 packages generated"
  exit 1
}
echo "Looking up recipes for the ${numpkg} packages currently generated:
pkg-name: recipe-to-generate-it
"
for pkg in $(cat ${PKG_MANIFEST})
do
  recp=$(oe-pkgdata-util lookup-recipe ${pkg})
  printf "%-40s: %s\n" ${pkg} ${recp}
done
