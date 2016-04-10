#!/bin/sh
#
# Verifies that all directories and files from the source directory are also present in the destination directory. Files must be non-empty.

cd "$(dirname "$0")/.."
. ./config.sh

if test ! -d "$src_dir"; then
	echo -e 'Source directory doesn'\''t exist: `'"$src_dir"'`.'
	exit 1
fi
if test ! -d "$dest_dir"; then
	echo -e 'Destination directory doesn'\''t exist: `'"$dest_dir"'`.'
	exit 1
fi

log_file="$tmp_dir/as3_api_verify_log"
rm -f "$log_file"

test "$verbose" = true || verbose=

echo -e 'Verifying destination directory structure:\n'
find "$src_dir" -mindepth 1 -type d | while read dir; do
	target="$dest_dir/$(realpath "$dir" --relative-to="$src_dir")"
	test -d "$target"
	result=$?
	test "$verbose" && echo "$target" || { test $result -eq 0 && echo -n '.' || echo -n '!'; }
	test $result -ne 0 && echo "! dir $target" >>"$log_file"
done
test -z "$verbose" && echo

echo -e '\nVerifying files:\n'
find "$src_dir" -mindepth 1 -type f | while read file; do
	target="$dest_dir/$(realpath "$file" --relative-to="$src_dir")"
	if test -f "$target"; then
		test -s "$target"
		result=$?
		test "$verbose" && echo "$target" || { test $result -eq 0 && echo -n '.' || echo -n '0'; }
		test $result -ne 0 && echo "0 file $target" >>"$log_file"
	else
		test "$verbose" && echo "$target" || echo -n '!'
		echo "! file $target" >>"$log_file"
	fi
done
test -z "$verbose" && echo

if test ! -s "$log_file"; then
	rm -f "$log_file"
	echo -e '\nFinished.'
else
	echo -e "\nFinished with $(wc -l "$log_file" | cut -d' ' -f1) failures."
	echo 'Error log: `'"$log_file"'`'
	less "$log_file"
fi
