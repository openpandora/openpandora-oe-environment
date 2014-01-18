#!/bin/bash

# Shamelesly 'borrowed' from the mainline Angstrom setup-scripts
#   http://gitorious.org/angstrom/angstrom-setup-scripts/
# and modified to just support the needs for the OpenPandora stock
# firmware and build setup. If you want a more generic Angstrom
# setup please use the mainline scripts.

# Original script done by Don Darling
# Later changes by Koen Kooi and Brijesh Singh
# Hacked about for the OpenPandora by John Willis

###############################################################################
# User specific vars like proxy servers
###############################################################################

#PROXYHOST=proxy.myproxy.com
#PROXYPORT=80
PROXYHOST=""

###############################################################################
# OE_BASE    - The root directory for all OE sources and development.
###############################################################################
OE_BASE=${PWD}

###############################################################################
# SET_ENVIRONMENT() - Setup environment variables for OE development
###############################################################################
function set_environment()
{

# Workaround for differences between yocto bitbake and vanilla bitbake
export BBFETCH2=True

#--------------------------------------------------------------------------
# If an env already exists, use it, otherwise generate it
#--------------------------------------------------------------------------
if [ -e ~/.oe/environment-openpandora ] ; then
    source ~/.oe/environment-openpandora
    echo ~/.oe/environment-openpandora found, using it.
    echo Delete this file to regenerate settings.
else
    echo Creating new environment file.
    mkdir -p ~/.oe/

    #--------------------------------------------------------------------------
    # Specify distribution information
    #--------------------------------------------------------------------------
    DISTRO="angstrom-v2013.06"
    DISTRO_DIRNAME=`echo ${DISTRO} | sed s#[.-]#_#g`

    echo "export BBFETCH2=True" > ~/.oe/environment-openpandora

    echo "export DISTRO=\"${DISTRO}\"" >> ~/.oe/environment-openpandora
    echo "export DISTRO_DIRNAME=\"${DISTRO_DIRNAME}\"" >> ~/.oe/environment-openpandora

    #--------------------------------------------------------------------------
    # Specify the root directory for your OpenEmbedded development
    #--------------------------------------------------------------------------
    OE_BUILD_DIR=${OE_BASE}/build
    OE_BUILD_TMPDIR="${OE_BUILD_DIR}/tmp-${DISTRO_DIRNAME}"
    OE_SOURCE_DIR=${OE_BASE}/sources
    OE_META_DIR=${OE_BASE}/metadata

    export BUILDDIR=${OE_BUILD_DIR}

    mkdir -p ${OE_BUILD_DIR}
    mkdir -p ${OE_SOURCE_DIR}
    mkdir -p ${OE_META_DIR}
    export OE_BASE

    echo "export OE_BUILD_DIR=\"${OE_BUILD_DIR}\"" >> ~/.oe/environment-openpandora
    echo "export BUILDDIR=\"${OE_BUILD_DIR}\"" >> ~/.oe/environment-openpandora
    echo "export OE_BUILD_TMPDIR=\"${OE_BUILD_TMPDIR}\"" >> ~/.oe/environment-openpandora
    echo "export OE_SOURCE_DIR=\"${OE_SOURCE_DIR}\"" >> ~/.oe/environment-openpandora
    echo "export OE_META_DIR=\"${OE_META_DIR}\"" >> ~/.oe/environment-openpandora

    echo "export OE_BASE=\"${OE_BASE}\"" >> ~/.oe/environment-openpandora

    #--------------------------------------------------------------------------
    # Include up-to-date bitbake in our PATH.
    #--------------------------------------------------------------------------
    export PATH=${OE_META_DIR}/openembedded-core/scripts:${OE_META_DIR}/bitbake/bin:${PATH}

    echo "export PATH=\"${PATH}\"" >> ~/.oe/environment-openpandora

    #--------------------------------------------------------------------------
    # Make sure Bitbake doesn't filter out the following variables from our
    # environment.
    #--------------------------------------------------------------------------
    export BB_ENV_EXTRAWHITE="MACHINE DISTRO GIT_PROXY_COMMAND ANGSTROMLIBC http_proxy ftp_proxy https_proxy all_proxy ALL_PROXY no_proxy SSH_AGENT_PID SSH_AUTH_SOCK BB_SRCREV_POLICY SDKMACHINE BB_NUMBER_THREADS"

    echo "export BB_ENV_EXTRAWHITE=\"${BB_ENV_EXTRAWHITE}\"" >> ~/.oe/environment-openpandora

    #--------------------------------------------------------------------------
    # Specify proxy information
    #--------------------------------------------------------------------------
    if [ "x$PROXYHOST" != "x"  ] ; then
        export http_proxy=http://${PROXYHOST}:${PROXYPORT}/
        export ftp_proxy=http://${PROXYHOST}:${PROXYPORT}/

        export SVN_CONFIG_DIR=${OE_BUILD_DIR}/subversion_config
        export GIT_CONFIG_DIR=${OE_BUILD_DIR}/git_config

        echo "export http_proxy=\"${http_proxy}\"" >> ~/.oe/environment-openpandora
        echo "export ftp_proxy=\"${ftp_proxy}\"" >> ~/.oe/environment-openpandora
        echo "export SVN_CONFIG_DIR=\"${SVN_CONFIG_DIR}\"" >> ~/.oe/environment-openpandora
        echo "export GIT_CONFIG_DIR=\"${GIT_CONFIG_DIR}\"" >> ~/.oe/environment-openpandora

        config_svn_proxy
        config_git_proxy
    fi

    #--------------------------------------------------------------------------
    # Set up the bitbake path to find the OpenEmbedded recipes.
    #--------------------------------------------------------------------------
    export BBPATH=${OE_BUILD_DIR}:${OE_META_DIR}/openembedded-core/meta${BBPATH_EXTRA}

    echo "export BBPATH=\"${BBPATH}\"" >> ~/.oe/environment-openpandora

    #--------------------------------------------------------------------------
    # Reconfigure dash
    #--------------------------------------------------------------------------
    if [ "$(readlink /bin/sh)" = "dash" ] ; then
        sudo aptitude install expect -y
        expect -c 'spawn sudo dpkg-reconfigure -freadline dash; send "n\n"; interact;'
    fi

    echo "There now is a sourceable script in ~/.oe/. You can run 'source ~/.oe/environment-openpandora' and run 'bitbake something' without using $0 as wrapper"
fi # if -e ~/.oe/environment-openpandora
}


###############################################################################
# UPDATE_ALL() - Make sure everything is up to date
###############################################################################
function update_all()
{
    set_environment
    update_oe
}

###############################################################################
# CLEAN_OE() - Delete TMPDIR
###############################################################################
function clean_oe()
{
    set_environment
    echo "Cleaning ${OE_BUILD_TMPDIR}"
    rm -rf ${OE_BUILD_TMPDIR}
}

###############################################################################
# OE_CONFIG() - Configure OE for a target
###############################################################################
function oe_config()
{
    set_environment
    config_oe
    update_all

    echo ""
    echo "Setup for ${CL_MACHINE} completed"
    echo ""
    echo "To use you MUST run 'source ~/.oe/environment-openpandora'"
    echo "and run 'bitbake something' INSIDE ${BUILDDIR} to build packages"
    echo ""
}

###############################################################################
# UPDATE_OE() - Update OpenEmbedded distribution.
###############################################################################
function update_oe()
{
    if [ "x$PROXYHOST" != "x" ] ; then
        config_git_proxy
    fi

    #manage meta-openembedded and meta-angstrom with layerman
    awk -f ${OE_BASE}/scripts/layers.awk ${OE_BASE}/scripts/included-layers.txt
}


###############################################################################
# CONFIG_OE() - Configure OpenEmbedded
###############################################################################
function config_oe()
{
    #--------------------------------------------------------------------------
    # Determine the proper machine name
    #--------------------------------------------------------------------------
    case ${CL_MACHINE} in
        pandora|openpandora|omap3pandora|omap3-pandora)
            MACHINE="openpandora"
            ;;
        *)
            echo "Unknown machine ${CL_MACHINE}, passing it to OE directly"
            MACHINE="${CL_MACHINE}"
            ;;
    esac

    #--------------------------------------------------------------------------
    # Write out the OE bitbake configuration file.
    #--------------------------------------------------------------------------
    mkdir -p ${OE_BUILD_DIR}/conf

    if [ ! -e ${OE_BUILD_DIR}/conf/bblayers.conf ]; then
	cat > ${OE_BUILD_DIR}/conf/bblayers.conf <<_EOF
# LAYER_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
LCONF_VERSION = "5"

BBFILES ?= ""

OE_META_DIR = "${OE_META_DIR}"

# These layers hold recipe metadata not found in OE-core, but lack any machine or distro content
BASELAYERS ?= " \\
  \${OE_META_DIR}/meta-openembedded/meta-oe \\
  \${OE_META_DIR}/meta-openembedded/meta-efl \\
  \${OE_META_DIR}/meta-openembedded/meta-gpe \\
  \${OE_META_DIR}/meta-openembedded/meta-gnome \\
  \${OE_META_DIR}/meta-openembedded/meta-xfce \\
  \${OE_META_DIR}/meta-openembedded/meta-initramfs \\
  \${OE_META_DIR}/meta-openembedded/toolchain-layer \\
  \${OE_META_DIR}/meta-openembedded/meta-multimedia \\
  \${OE_META_DIR}/meta-openembedded/meta-networking \\
  \${OE_META_DIR}/meta-openembedded/meta-webserver \\
  \${OE_META_DIR}/meta-openembedded/meta-ruby \\
  \${OE_META_DIR}/meta-openembedded/meta-systemd \\
  \${OE_META_DIR}/meta-kde \\
  \${OE_META_DIR}/meta-opie \\
  \${OE_META_DIR}/meta-java \\
  \${OE_META_DIR}/meta-browser \\
  \${OE_META_DIR}/meta-mono \\
  \${OE_META_DIR}/meta-ros \\
"

# These layers hold machine specific content, aka Board Support Packages
BSPLAYERS ?= " \\
  \${OE_META_DIR}/meta-ti \\
  \${OE_META_DIR}/meta-openpandora \\
"

# Add your overlay location to EXTRALAYERS
# Make sure to have a conf/layers.conf in there
EXTRALAYERS ?= " \\
  \${OE_META_DIR}/meta-openpandora-vendor \\
"

BBLAYERS = " \\
  \${OE_META_DIR}/meta-angstrom \\
  \${BASELAYERS} \\
  \${BSPLAYERS} \\
  \${EXTRALAYERS} \\
  \${OE_META_DIR}/openembedded-core/meta \\
"
_EOF
    fi

    # There's no need to rewrite local.conf when changing MACHINE
    if [ ! -e ${OE_BUILD_DIR}/conf/local.conf ]; then
        cat > ${OE_BUILD_DIR}/conf/local.conf <<_EOF

#
# OpenEmbedded local configuration file for the OpenPandora
#
# Please visit the Wiki at http://openembedded.org/ for more info.
#
# NOTE: Do NOT use $HOME in your paths, BitBake does NOT expand ~ for you.  If you
# must have paths relative to your homedir use ${HOME} (note the {}'s there
# you MUST have them for the variable expansion to be done by BitBake).  Your
# paths should all be absolute paths (They should all start with a / after
# expansion.  Stuff like starting with ${HOME} or ${TOPDIR} is ok).

# CONF_VERSION is increased each time build/conf/ changes incompatibly
CONF_VERSION = "1"

# Where to store sources
DL_DIR = "${OE_SOURCE_DIR}/downloads"

INHERIT += "rm_work"

# Specifies that BitBake should emit the log if a build fails
BBINCLUDELOGS = "yes"

# Which files do we want to parse:
BBFILES ?= "${OE_META_DIR}/openembedded-core/meta/recipes-*/*.bb"

# Use the BBMASK below to instruct BitBake to _NOT_ consider some .bb files
# This is a regulary expression, so be sure to get your parenthesis balanced.
BBMASK = ""

# Qemu 0.12.x is giving too much problems recently (2010.05), so disable it for users
ENABLE_BINARY_LOCALE_GENERATION = "0"

# Add the required image file system types below. Valid are 
# jffs2, tar(.gz|bz2), cpio(.gz), cramfs, ext2(.gz), ext3(.gz)
# squashfs, squashfs-lzma, ubi
IMAGE_FSTYPES += "tar.bz2"

# Make use of SMP:
#   PARALLEL_MAKE specifies how many concurrent compiler threads are spawned per bitbake process
#   BB_NUMBER_THREADS specifies how many concurrent bitbake tasks will be run
PARALLEL_MAKE     = "-j5"
BB_NUMBER_THREADS = "5"

DISTRO   = "${DISTRO}"
MACHINE ?= "${MACHINE}"

# Comment out *one* of the two lines below
#DISTRO_TYPE = "debug"
DISTRO_TYPE = "release"

# Set TMPDIR instead of defaulting it to $pwd/tmp
TMPDIR = "${OE_BUILD_TMPDIR}"

# Don't generate the mirror tarball for SCM repos, the snapshot is enough
BB_GENERATE_MIRROR_TARBALLS = "0"

# Go through the Firewall
#HTTP_PROXY        = "http://${PROXYHOST}:${PROXYPORT}/"

# Uncomment this if you want to install shared libraries directly under their SONAME,
# rather than installing as the full version and symlinking to the SONAME.
# PACKAGE_SNAP_LIB_SYMLINKS = "1"

# Uncomment this to bypass MD5/SHA checking of downloads (ok, so it's bad to do that).
# OE_ALLOW_INSECURE_DOWNLOADS = "1" 

_EOF
fi
}

###############################################################################
# CONFIG_SVN_PROXY() - Configure subversion proxy information
###############################################################################
function config_svn_proxy()
{
    if [ ! -f ${SVN_CONFIG_DIR}/servers ]
    then
        mkdir -p ${SVN_CONFIG_DIR}
        cat >> ${SVN_CONFIG_DIR}/servers <<_EOF
[global]
http-proxy-host = ${PROXYHOST}
http-proxy-port = ${PROXYPORT}
_EOF
    fi
}


###############################################################################
# CONFIG_GIT_PROXY() - Configure GIT proxy information
###############################################################################
function config_git_proxy()
{
    if [ ! -f ${GIT_CONFIG_DIR}/git-proxy.sh ]
    then
        mkdir -p ${GIT_CONFIG_DIR}
        cat > ${GIT_CONFIG_DIR}/git-proxy.sh <<_EOF
if [ -x /bin/env ] ; then
    exec /bin/env corkscrew ${PROXYHOST} ${PROXYPORT} \$*
else
    exec /usr/bin/env corkscrew ${PROXYHOST} ${PROXYPORT} \$*
fi
_EOF
        chmod +x ${GIT_CONFIG_DIR}/git-proxy.sh
        export GIT_PROXY_COMMAND=${GIT_CONFIG_DIR}/git-proxy.sh
        echo "export GIT_PROXY_COMMAND=\"\${GIT_CONFIG_DIR}/git-proxy.sh\"" >> ~/.oe/environment-openpandora
    fi
}


###############################################################################
# Build the specified OE packages or images.
###############################################################################

# FIXME: convert to case/esac

if [ $# -gt 0 ]
then
    if [ $1 = "update" ]
    then
        shift
        if [ ! -r $1 ]; then
            if [  $1 == "commit" ]
            then
                shift
                OE_COMMIT_ID=$1
            fi
        fi
        update_all
        exit 0
    fi

    if [ $1 = "config" ]
    then
        shift
        CL_MACHINE=openpandora
        shift
        oe_config $*
        exit 0
    fi

    if [ $1 = "clean" ]
    then
        clean_oe
        exit 0
    fi
fi

# Help Screen
echo ""
echo "Usage: $0 config"
echo "       $0 update"
echo ""
echo "You must invoke \"$0 config\" AND \"$0 update\" "
echo "prior to your first bitbake command"
echo ""
echo "To use you MUST do '. ~/.oe/environment-openpandora'"
echo "and run 'bitbake something' INSIDE ${BUILDDIR} to build packages"
echo ""
