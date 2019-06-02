#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
##
## From the current directory, recursively convert to lower case all file and directory names, creating symlinks to their original names
## Should ask for verification before overwriting an existing file.
## !BROKEN! Should also decapitalize Cyrillic, Greek, and other mixed-case scripts.
##
## -----------------------------------------------------------------------------------------------------------

## Have script handle spaces better by usig a different delimiter
export IFS='
'

## Setting an important early variable
export strStartDir=$(pwd)

## Write in a function the loop that we'll use for to edit the files
function editingloop {
    cd "$strDir"
    ## Check to make sure current directory isn't empty
#    if [[ $(ls -a) != {. ..} ]]; then  ## Not sure how to do this without a loop, and don't want to use a loop for it.
	echo '
_______________________________________________________________________
Entering current directory:  '"$strDir"
	echo '
Current directory before edit:  ' && ls -a --color=auto  ## Would be nice to hide . and ..
	## Dimensioning variables like a responsible person
	local strItem
	local strLowerCasedItem
	## Start the editing loop
	for strItem in $(ls); do
	    ## Save the computer some breath on . and ..
	    if [[ "$strItem" != '.' || '..' ]]; then
		## Set a variable equal to the lowercased vesion of the original filename
		export strLowerCasedItem=$(echo "$strItem" | tr '[A-Z]' '[a-z]')
		## If this variable is the same as the original, then the original was already lowercased, so we skip it;  otherwise, we rename it to the lowercased vesion, and create a symlink to the new location at the old one.
		if [[ "$strLowerCasedItem" != "$strItem" ]]; then
		    mv -i $(echo "$strDir"'/'"$strItem") $(echo "$strDir"'/'"$strLowerCasedItem")  ## '-i' makes sure that we check with the user before clobbering
		    ln -sT $(echo "$strDir"'/'"$strLowerCasedItem") $(echo "$strDir"'/'"$strItem")
		fi
	    fi
	done
	echo '
Current directory after edit:  ' && ls -a --color=auto  ## Would be nice to hide . and ..
#    fi
}

## This loops the main loop through each subdirectory of the starting directory
for strDir in $(find -type d); do
    export strDir=$(echo "$strStartDir"$(echo "$strDir" | sed 's/^.//'))
    echo "$strDir"
    editingloop
done

exit 0
