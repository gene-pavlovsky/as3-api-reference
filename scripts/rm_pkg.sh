#!/bin/sh
#
# Removes undesired documentation packages to reduce size and clutter. 

# TODO: Improve this script. Keep list of packages to remove in `.config.sh`. Allow removing sub-packages.

PKG_REMOVE="adobe coldfusion com fl ga lc org xd"
TOC_FILE="otd_toc.xml"

echo "Removing packages:"
for pkg in $PKG_REMOVE; do
	echo $pkg
	rm -rf $pkg 2>/dev/null
	test "$grep_list" && grep_list+="|$pkg" || grep_list="$pkg"
done
echo
grep_list="href=\"($grep_list)/"
if test ! -f "$TOC_FILE".orig; then
	echo -n "Backup up TOC: "
	cp "$TOC_FILE" "$TOC_FILE".orig
fi
echo -n "Cleaning TOC: "
grep -E -v "$grep_list" "$TOC_FILE" >"$TOC_FILE".new && mv -f "$TOC_FILE".new "$TOC_FILE"
echo done
