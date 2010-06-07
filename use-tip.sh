#!/bin/sh
cd ${OE_METADATA}/openembedded.git
git pull
git stash
git checkout op.openembedded.dev

cd ${OE_METADATA}/openpandora.oe.git
git pull
git stash
git checkout master
