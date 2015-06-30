#!/bin/bash
#
# This script creates filed required by a container.

prefix=${HOST:-/host}
src="$1"
dest="${prefix}/${src}"

if [[ -z "${src}" ]]; then
  echo "Usage: install_file.sh <src>" && exit 1
fi

if [ ! -e "$src" ] ; then
  echo "Error, src file ${src} not found" 1>&2
  exit 1
fi

if [ -d "$dest" ]; then
  # Work around a docker behaviour:
  # if we try to bind mount a single config file from the host
  # to the container, and the file does not exist, then docker
  # will create it as a directory.
  # This can happen if we "atomic run" the image before "atomic
  # install", so detect that and fix it up here.
  rmdir --ignore-fail-on-non-empty "$dest" || exit 1
  if [ -d "$dest" ]; then
    echo "Failed to install file at ${dest}, directory in the way" 1>&2
    exit 1
  fi
  echo "Installing file at ${dest} in place of existing empty directory" 1>&2
else
  if [ -e "${dest}" ]; then
    cmp --silent "${src}" "${dest}"  && exit 0
    # Attempting to install over an existing file with new contents?
    # Copy to a predictable alternative instead, similar to ".rpmnew"
    echo "Installing over file ${dest}, new file placed in ${dest}.atomicnew" 1>&2
    cp -af "${src}" "${dest}".atomicnew || exit 1
    exit
  fi
fi

echo "Installing file at '${dest}'" 1>&2
cp -a "${src}" "${dest}" || exit $?
exit $?
