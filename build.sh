#!/bin/sh

xcodebuild -quiet -configuration Release -target mouselock

rm -rf dist && mkdir dist

hdiutil create -fs HFS+ -srcfolder build/Release/mouselock.app -volname mouselock dist/mouselock.dmg

rm -r build