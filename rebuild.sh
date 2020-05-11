#!/bin/sh
osascript -e 'quit app "XCODE"'
xcodegen
pod install
open $(find . -name *.xcworkspace -print -quit)