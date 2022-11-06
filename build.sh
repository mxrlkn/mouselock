#!/bin/sh
set -e

# get latest tag starting with v
VERSION=$(git tag -l 'v*' --sort=-v:refname | head -1)

# set app version
agvtool new-version ${VERSION:1}

# build
xcodebuild -quiet -configuration Release -target Mouselock

# clean dist
rm -rf dist && mkdir dist

# make dmg from app
hdiutil create -fs HFS+ -srcfolder build/Release/Mouselock.app -volname Mouselock dist/Mouselock.dmg

# clean build
rm -r build