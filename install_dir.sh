#!/bin/bash
#
# This script creates directories required by a container.

prefix=${HOST:-/host}
src="$1"
dest="${prefix}/$1"

if [[ -z "${src}" ]]; then
  echo "Usage: install_dir.sh <src>" && exit 1
fi

if [[ ! -e "${src}" ]]; then
  echo "Error: source directory ${src} not found" 1>&2
  exit 1
fi

if [[ -d "${dest}" ]]; then
  exit 0
fi

set -e

echo "Creating directory at ${dest}" 1>&2
mkdir -p "${dest}"

echo "Changing permissions for ${dest}" 1>&2
chmod --reference="${src}" "${dest}"
chown --reference="${src}" "${dest}"
