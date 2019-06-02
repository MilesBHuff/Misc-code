#!/usr/bin/env bash

## Create caches for the searches and excluded files
CACHE=".$RANDOM$RANDOM.txt"

## Find everything below the current directory
clear
echo ":: Finding all paths below the current directory..."
find | tee "$CACHE"

## Apply new perms
clear
echo ':: Applying new perms...'
while read L; do
	case
		## Ignore
		*'/.git'* )
		;;
		## Special scenarios
		*'/.ssh' )
			[ -d "$L" ] && chmod -c 700
		;;
		*'/bin' )
			chmod -c 755
		## Everything else
		* )
			if [ -d "$L" ]; then
				chmod -c 755 "$L"
			else
				chmod -c 644 "$L"
			fi
		;;
	esac
	## Executables
	case
		*'.bash')
		*'/configure')
		*'.csh')
		*'.exe')
		*'.ksh')
		*'.py')
		*'.sh')
		*'.zsh')
			chmod -c +x "$L"
		;;
	esac
done < "$CACHE"

## Cleanup
rm -f "$CACHE"
clear
echo 'Permissions fixed.'
