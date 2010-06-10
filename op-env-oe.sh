#!/bin/sh

# OpenPandora OpenEmbedded Enviroment Script
# By John Willis (mostly borrowed from Poky) 
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

if test x"$0" = x"./op-env-oe.sh"; then
	echo "Error: Please run via '. ./op-env-oe.sh'"
fi

OE_ENV_TOP=${PWD}
export OE_ENV_TOP

OE_METADATA=${OE_ENV_TOP}/metadata
export OE_METADATA

PATH=${OE_ENV_TOP}/bitbake/bin:$PATH
export PATH

BBPATH=${OE_ENV_TOP}/build:${OE_METADATA}/openembedded.git:${OE_METADATA}/openpandora.oe.git:${OE_METADATA}/user.collection
export BBPATH

OEBRANCH=${OE_METADATA}/openembedded.git
export OEBRANCH

PANDORAOVERLAY=${OE_METADATA}/openpandora.oe.git
export PANDORAOVERLAY

USEROVERLAY=${OE_METADATA}/user.collection
export USEROVERLAY

export BB_ENV_EXTRAWHITE="MACHINE DISTRO ANGSTROM_MODE OE_ENV_TOP OE_METADATA OEBRANCH PANDORAOVERLAY USEROVERLAY"
