src_dir=src
dest_dir=doc
tmp_dir=$TMP

src_url='http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/'
wget_opts='--mirror --convert-links --adjust-extension --no-parent --retry-connrefused'

max_fail_count=30

test -f ./.config.local.sh && . ./.config.local.sh
