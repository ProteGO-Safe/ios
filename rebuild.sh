#!/bin/sh
xcproj=$(find . -name *.xcodeproj -print -quit)
rm -Rf $xcproj
osascript -e 'quit app "XCODE"'
xcodegen
pod install

xcworkspace=$(find . -name *.xcworkspace -print -quit)
locations=$(ls -d /Applications/Xcode*)
declare -a options

while IFS=' ' read -ra XCODES; do
  for i in "${XCODES[@]}"; do
      options+=($i)	
  done
done  <<< $locations

echo
echo "-----------------------------------------------"
echo "Please select Xcode app to open: ${xcworkspace}"
echo
PS3='your choice: '
select opt in "${options[@]}"
do
    case $opt in
        *) open $xcworkspace -a $opt 
		break
		;;
    esac
done