#!/bin/sh
#
# Removes specific parts from all AS3 API Reference html files to enable offline usage, improve rendering speed and reduce clutter.
# @see `scripts/make_doc.awk`.

cd "$(dirname "$0")/.."
. ./.config.sh

while test $# -gt 0; do
  case $1 in
    --clean)
      clean=true
    ;;
    *)
			echo "Unknown option: $1"
			exit 1
    ;;
  esac

  shift
done

make_doc='scripts/make_doc.awk'
tmp_dir="$tmp_dir/as3_api_make_doc"

if test "$clean"; then
	rm -f "$pending_file" "$list_file" "$log_file"
	echo -e 'Removing tmp dir: '"$tmp_dir"'\n'
	rm -rf "$tmp_dir" 2>/dev/null
fi
test -d "$tmp_dir" || mkdir "$tmp_dir"

list_file="$tmp_dir/list"
if test -f "$list_file"; then
	echo -e 'File list exists, reusing.\n'
else
	echo -e 'Removing dest dir: '"$dest_dir"'\n'
	rm -rf "$dest_dir" 2>/dev/null
	echo -e 'Creating and populating dest dir:\n\n'"$dest_dir"
	mkdir "$dest_dir" 2>/dev/null
	find "$src_dir" -mindepth 1 -type d | while read dir; do
		target="$dest_dir/$(realpath "$dir" --relative-to="$src_dir")"
		echo "mkdir $target"
		mkdir "$target" 2>/dev/null
	done
	cp -a "$src_dir"/{images,*css,*js} "$dest_dir" 2>/dev/null
	
	echo -en '\nBuilding file list... '
	find "$src_dir" -type f -name '*.html' >"$list_file"
	echo -e 'done\n'
fi
echo -e "$(wc -l "$list_file" | cut -d' ' -f1) files to process.\n"

out_file="$tmp_dir/out.html"
pending_file="$tmp_dir/list.pending"
log_file="$tmp_dir/log"
fail_count=0

echo -e 'Processing files:\n'
while read file; do
	if test $fail_count -lt $max_fail_count; then
		echo "$file"
		"$make_doc" "$file" >"$out_file" 2>>"$log_file"
		status=$?
	else
		status=1
	fi
	
	if test $status -eq 0; then
		target="$dest_dir/$(realpath "$file" --relative-to="$src_dir")"
		mv -f "$out_file" "$target"
	else
		echo "$file" >>"$pending_file"
		let ++fail_count
	fi
done <"$list_file"

if test $fail_count -eq 0; then
	rm -f "$pending_file" "$list_file" "$log_file"
	echo -e '\nAll done.'
else
	rm -f "$out_file"
	mv -f "$pending_file" "$list_file"
	echo -e '\nThere were some failures.'
	echo -e "$(wc -l "$list_file" | cut -d' ' -f1) files left to process.\n"
	echo "Check the log file: $log_file"
	less "$log_file"
fi
