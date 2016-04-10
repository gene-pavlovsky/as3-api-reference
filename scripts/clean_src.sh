#!/bin/sh
#
# Move unwanted original files from source directory to trash directory.

cd "$(dirname "$0")/.."
. ./config.sh

if test "$1" = '--dest'; then
	src_dir="$dest_dir"
	alias mv='rm -f'
fi

test -d "$trash_dir" || mkdir "$trash_dir"
echo -e 'Moving unwanted files from source directory to trash directory:\n '

mv -v "$src_dir/jive-comments.html" "$src_dir"/index.html@* "$trash_dir" 2>/dev/null

echo -e '\nTrash directory: `'"$trash_dir"'`'
