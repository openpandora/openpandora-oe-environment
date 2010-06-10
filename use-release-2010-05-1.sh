#!/bin/sh
cd ${OE_METADATA}/openembedded.git
git stash
git checkout Release-2010-05/1

cd ${OE_METADATA}/openpandora.oe.git
git stash
git checkout Release-2010-05/1