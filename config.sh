# Common options
# ==============
# AS3 API Reference original files directory.
src_dir=src
# Generated AS3 API Reference processed files directory.
dest_dir=doc
# Extra files directory. Files from here are copied to dest_dir before starting processing (making backups of existing destination files).
extra_dir=extra
# Temporary files directory.
tmp_dir=$TMP

# Options for `scripts/fetch_src.sh`
# ==================================
# AS3 API Reference download URL.
src_url='http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/'
# Options for wget.
wget_opts='--mirror --convert-links --adjust-extension --no-parent --retry-connrefused'

# Options for `scripts/clean_src.sh`
# ==================================
# Unwanted original files directory.
trash_dir=trash

# Options for `scripts/make_doc.sh`
# =================================
# Stop processing after this number of files failed to be processed. Unset to disable.    
stop_fail_count=25

# Options for `scripts/verify_doc.sh`
# ==================================
# Whether to list file paths or just display a dot for each one.
verbose=false

# Options for `scripts/prune_doc.sh`
# ==================================
# List of top-level AS3 packages to remove from the processed files directory. 
#prune_packages='adobe coldfusion com fl ga lc org xd' # Remove most extra packages, but keep Flex (doc_base+flex).
#prune_packages='adobe coldfusion com fl ga lc mx org spark xd' # Remove most extra packages and Flex (doc_base).
prune_packages='adobe air coldfusion com fl flash flashx ga lc org xd' # Remove everything but Flex (doc_flex).
# FlashDevelop OpenTheDoc plug-in help TOC file (Flex help TOC file).
prune_toc_file='otd_toc.xml'

# Include local config file
# ==========================
test -f ./config.local.sh && . ./config.local.sh
