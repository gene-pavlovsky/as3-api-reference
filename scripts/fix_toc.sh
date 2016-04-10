#!/bin/sh
#
# Fix the TOC file.

cd "$(dirname "$0")/.."
. ./config.sh

cd "$dest_dir"

if test "$prune_toc_file" -a ! -f "$prune_toc_file"; then
	echo 'TOC file is missing. Use `bin/TocGen.exe` to generate it.'
	exit 1
fi

test "$prune_toc_file" || exit
if test ! -f "$prune_toc_file"~; then
	echo -n "Backing up TOC file: "
	cp "$prune_toc_file" "$prune_toc_file"~
	echo done
fi

echo -n "Checking if TOC file needs fixing: "
grep 'Array\.htmlArray\.html' "$prune_toc_file" &>/dev/null
if test $? -eq 0; then
	echo yes
	echo -n "Fixing TOC file... "
	sed -i -E 's,([_a-zA-Z0-9]+\.html)[_a-zA-Z0-9]+\.html,\1,' "$prune_toc_file"
	echo done
else
	echo no
fi
