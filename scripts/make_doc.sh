#!/bin/sh
#
# Strips specific parts from all AS3 API Reference html files to enable offline usage, improve rendering speed and reduce clutter.
# @see `scripts/make_doc.awk`.

cd "$(dirname "$0")/.."
. ./config.sh

while test $# -gt 0; do
  case $1 in
    --clean)
      clean=true
    ;;
    --resume)
      resume=true
    ;;
    --help)
			echo "Usage: $(basename "$0") [options]"
			echo "Options:"
			echo "  --resume                    Resume processing files from the existing file list."
			echo "  --clean                     Delete existing destination directory and file list."
			exit 0
    ;;
    *)
			echo "Unknown option: $1"
			exit 1
    ;;
  esac

  shift
done

if test ! -d "$src_dir"; then
	echo -e 'Source directory doesn'\''t exist: `'"$src_dir"'`.'
	exit 1
fi

make_doc='scripts/make_doc.awk'
tmp_dir="$tmp_dir/as3_api_make_doc"
list_file="$tmp_dir/list"
out_file="$tmp_dir/out.html"
pending_file="$tmp_dir/list.pending"
log_file="$tmp_dir/log"

if test "$clean"; then
	echo -n 'Deleting tmp dir: `'"$tmp_dir"'`... '
	rm -rf "$tmp_dir"
	echo done
fi
test -d "$tmp_dir" || mkdir "$tmp_dir"

echo_resume_options() {
	test -s "$list_file" &&
		echo -n 'Use `--resume` to resume or `--clean` to delete it and destination directory, and restart.' ||
		echo -n 'Use `--clean` to delete it and destination directory, and restart.'
}

test -f "$list_file" -a ! -s "$list_file" && rm -f "$list_file"
if test -f "$list_file"; then
	if test "$resume"; then
		echo -e 'File list exists, resuming.\n'
	else
		echo -e "File list exists.\n\n$(echo_resume_options)"
		exit 1
	fi
else
	if test -d "$dest_dir" -a -z "$clean"; then
		echo -e 'Destination directory exists: `'"$dest_dir"'`\n\nUse `--clean` to restart (deletes destination directory).'
		exit 1
	fi
	echo -n 'Deleting destination directory: `'"$dest_dir"'`... '
	rm -rf "$dest_dir"
	echo done
	echo -e 'Creating destination directory structure:\n\n'"mkdir $dest_dir"
	mkdir "$dest_dir"
	find "$src_dir" -mindepth 1 -type d | while read dir; do
		target="$dest_dir/$(realpath "$dir" --relative-to="$src_dir")"
		echo "mkdir $target"
		mkdir "$target" 2>/dev/null
	done
	echo -ne '\nCopying non-html files... '
	cp -a "$src_dir"/{images,*css,*js} "$dest_dir" 2>/dev/null
	echo done
	if test -d "$extra_dir"; then
		echo -ne 'Copying files from extra directory... '
		cp -ab "$extra_dir"/* "$dest_dir"
		echo done
	fi
	
	echo -n 'Building file list... '
	find "$src_dir" -type f -name '*.html' >"$list_file"
	echo -e 'done\n'
fi

fail_count=0
trap 'stop_fail_count=0; sigint=1' int # Stop processing on receiving a SIGINT (Ctrl+C).
rm -f "$log_file"
echo -e "Processing $(wc -l "$list_file" | cut -d' ' -f1) files:\n"

while read file; do
	if test -z "$stop_fail_count" -o $fail_count -lt 0$stop_fail_count; then
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
		test $status -eq 130 && { stop_fail_count=0; sigint=2; } # Stop processing on make_doc.awk process receiving a SIGINT (Ctrl+C).
		echo "$file" >>"$pending_file"
		let ++fail_count
	fi
done <"$list_file"

if test $fail_count -eq 0; then
	rm -rf "$tmp_dir"
	echo -e '\nFinished.'
else
	rm -f "$out_file"
	mv -f "$pending_file" "$list_file"
	test "$sigint" &&
		echo -e "\nInterrupted.\n\nFile list exists.\n\n$(echo_resume_options)" ||
		echo -e "\nFinished with $(wc -l "$list_file" | cut -d' ' -f1) failures."
	if test -s "$log_file"; then
		echo 'Error log: `'"$log_file"'`'
		less "$log_file"
	fi
fi
