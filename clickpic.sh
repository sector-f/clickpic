#!/usr/bin/env bash

declare -a info
declare counter=0
declare argument
declare viewer
declare grepclass
declare greppicture
declare class
declare picture
declare directory

usage() {
	echo "Usage: $(basename $0) mv|cp directory"
	exit 1
}

case "$1" in
	cp|copy)
		argument="cp"
		;;
	mv|move)
		argument="mv"
		;;
	*)
		usage
		;;
esac

if [[ -d "$2" ]]; then
	directory="$2"
else
	usage
fi

# Get the output of xprop into an array1
while IFS= read -r line; do
	info[$counter]=$line
	((counter++))
done < <(xprop)

# Get the window class line from xprop
while IFS= read -r line; do
	grepclass=$(grep 'WM_CLASS(STRING)')
done < <(printf '%s\n' "${info[@]}")

# Get the window title line from xprop
while IFS= read -r line; do
	greppicture=$(grep 'WM_ICON_NAME(STRING)')
done < <(printf '%s\n' "${info[@]}")

# Use awk to get the window class
class=$(awk {'gsub(/"|,/,"",$3);print $3'} <<< $grepclass)

case "$class" in
	shotwell)
		viewer="shotwell"
		;;
	*)
		echo "Please click a shotwell window"
		exit 1
esac

# Should be easy enough to add other image viewers here...
# Assuming the image info is in the window title, that is
# TODO: Add feh support
case "$viewer" in
	shotwell)
		picture=$(awk '{gsub(/\(|\)/,"",$4);gsub(/"/,"",$3);print $4 "/" $3}' <<< "$greppicture")
		;;
esac

case "$argument" in
	mv)
		eval $(echo "mv "$picture" "$directory"")
		;;
	cp)
		eval $(echo "cp "$picture" "$directory"")
		;;
esac
