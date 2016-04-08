#!/bin/awk -f
#
# Removes specific parts from a single AS3 API Reference html file to enable offline usage, improve rendering speed and reduce clutter.
# Probably would have to be updated every now and then to match the current format of the AS3 API Reference.
# Checks several assertions (which regular expression is supposed to match on which line number) to detect if the format has changed.

# Disable printing lines.
function mute() {
	#print "  NR=" NR " mute" >"/dev/stderr"
	skipNextCount = -1
}

# Enable printing lines.
function unmute() {
	#print "  NR=" NR " unmute" >"/dev/stderr"
	skipNextCount = 0
}

# Disable printing lines for the specified number of lines.
function skip(numLines) {
	#print "  NR=" NR " skip " numLines >"/dev/stderr"
	skipNextCount = numLines
}

# If current line number is equal to the specified value, increment the number of succeeded assertions.
function assertNR(value) {
	#print "  NR=" NR " assertNR " value >"/dev/stderr"
	if (NR == value)
		++numSucceeded
	return NR == value
}

BEGIN {
	# Number of assertions (assertNR() calls).
	numAsserts = 6
	numSucceeded = 0
	# Controls printing lines: 0 - print, negative - don't print, positive - don't print but decrement by 1 per line.
	skipNextCount = 0
}

NR == 46                                            { mute(); }
/<!-- START: ForeSee/                               { assertNR(48); }
/<!-- END: ForeSee/                                 { assertNR(73); }
NR == 77                                            { unmute(); }
/<table class="titleTable"/                         { if (assertNR(81)) mute(); }
NR == 161                                           { unmute(); }
/<td class="titleTableSubTitle"/                    { assertNR(163); }
NR == 205                                           { skip(3); }
/<div class="maincontainer"/                        { assertNR(208); }
/id="cls_name" href="(package|index|all-index)/     { assertNR(215); } # Package and index files.
/<div id="badgeAnchorSupport"/                      { if (assertNR(230)) sub(/<div id="badgeAnchorSupport".*/, "", $0); } # Regular files.
NR == 231                                           { skip(1); }
/<div class="contentfooter"/                        { mute(); }
/<div class="footer"/                               { skip(2); }
/help\/badge(\/v3)?\/ion/                           { skip(1); }

{
	if (skipNextCount == 0)
		print
	else if (skipNextCount > 0)
		--skipNextCount
}

END {
	if (numSucceeded < numAsserts) {
		print FILENAME "\n  Failed assertions: " (numAsserts - numSucceeded) "/" numAsserts "\n" >"/dev/stderr"
		exit 1
	}
}
