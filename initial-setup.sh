#!/bin/sh

mkdir ${OE_ENV_TOP}/bitbake
mkdir ${OE_ENV_TOP}/sources
mkdir ${OE_ENV_TOP}/tmp
mkdir ${OE_METADATA}
mkdir ${OE_METADATA}/user.collection
mkdir ${OE_METADATA}/openembedded-core
mkdir ${OE_METADATA}/meta-openembedded
mkdir ${OE_METADATA}/meta-angstrom
mkdir ${OE_METADATA}/meta-openpandora

cd ${OE_ENV_TOP}/bitbake
git clone git://git.openembedded.net/bitbake .
git checkout --track -b 1.12 origin/1.12

cd ${OE_METADATA}/openembedded-core
git clone git://git.openembedded.org/openembedded-core .
git checkout master

cd ${OE_METADATA}/meta-openembedded
git clone git://git.openembedded.org/meta-openembedded .
git checkout master

cd ${OE_METADATA}/meta-angstrom
git clone git://git.angstrom-distribution.org/meta-angstrom .
git checkout master

# Use my GIThub tree for the overlay for now.
cd ${OE_METADATA}/meta-openpandora
git clone git://github.com/djwillis/meta-openpandora.git .
git checkout master
