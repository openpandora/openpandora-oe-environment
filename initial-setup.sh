#!/bin/sh

mkdir ${OE_ENV_TOP}/bitbake
mkdir ${OE_ENV_TOP}/sources
mkdir ${OE_ENV_TOP}/tmp
mkdir ${OE_METADATA}
mkdir ${OE_METADATA}/user.collection
mkdir ${OE_METADATA}/openembedded.git
mkdir ${OE_METADATA}/openpandora.oe.git

cd ${OE_ENV_TOP}/bitbake
git clone git://git.openembedded.net/bitbake .
git checkout --track -b 1.10 origin/1.10
# Use 1.8.18 for now for users as 1.10 is not final yet.
#git checkout -b 1.8.18

cd ${OE_METADATA}/openembedded.git
git clone git://git.openpandora.org/openembedded.git .
git checkout op.openembedded.dev

cd ${OE_METADATA}/openpandora.oe.git
git clone git://git.openpandora.org/openpandora.oe.git .
git checkout master
