#!/bin/sh
#
# Download the latest AS3 API Reference

cd "$(dirname "$0")/.."
. ./.config.sh

wget $wget_opts --no-host-directories --cut-dirs=5 -P "$src_dir" "$src_url"
