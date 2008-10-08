#!/bin/sh

###
# = nvidia.sh(3)
# Michel Hermier <hermier@frugalware.org>
#
# == NAME
# nvidia.sh - for Frugalware
#
# == SYNOPSIS
# Common schema for nVidia packages.
#
# == EXAMPLE
# --------------------------------------------------
# pkgname=nvidia
# pkgver=173.14.12
# pkgrel=3
# archs=('i686' 'x86_64')
# Finclude nvidia
# case "$_F_nvidia_arch" in
# x86)    sha1sums=('01d297c477b95593e9fbf5c73e501a4f5617b497');;
# x86_64) sha1sums=('78d3034314df7f9c95526707d7fcf4543f5993ed');;
# esac
# --------------------------------------------------
#
# == OPTIONS
# * _F_nvidia_name (defaults to NVIDIA-Linux-$_F_nvidia_arch-$pkgver-pkg$F_nvidia_pkgnum): the nvidia package name
# * _F_nvidia_arch (defaults guessed using CARCH): the nvidia package arch
# * _F_nvidia_pkgnum (defaults guessed using _F_nvidia_arch): the nvidia package number
# * _F_nvidia_linkver (defaults to pkgver): the link number used by the nvidia shared libraries
# * _F_nvidia_install (defaults to nvidia.install): Install file
# * _F_nvidia_legacyver (optionnal): version string has found at http://www.nvidia.com/object/unix.html 
# * _F_nvidia_up2date (defaults depends of _F_nvidia_legacyver): an up2date grep string that will be followed
###
# General variables
if [ -z "$_F_nvidia_arch" ]; then
	if echo "$CARCH" | grep -q 'i.86'; then
		_F_nvidia_arch=x86
	elif [ "$CARCH" == "x86_64" ]; then
		_F_nvidia_arch=x86_64
	fi
fi
if [ -z "$_F_nvidia_pkgnum" ]; then
	case "$_F_nvidia_arch" in
	x86)	_F_nvidia_pkgnum=1;;
	x86_64)	_F_nvidia_pkgnum=2;;
	esac
fi
if [ -z "$_F_nvidia_name" ]; then
	_F_nvidia_name=NVIDIA-Linux-$_F_nvidia_arch-$pkgver-pkg$_F_nvidia_pkgnum
fi
if [ -z "$_F_nvidia_linkver" ]; then
	_F_nvidia_linkver=$pkgver
fi
if [ -z "$_F_nvidia_install" ]; then
	_F_nvidia_install="nvidia.install"
fi
if [ -z "$_F_nvidia_up2date" ]; then
	if [ -z "$_F_nvidia_legacyver" ]; then
		_F_nvidia_up2date="Latest Version:"
	else
		_F_nvidia_up2date="Latest Legacy GPU Version ($_F_nvidia_legacyver series):"
	fi
fi

###
# == OVERWRITTEN VARIABLES
# * groups
# * pkgdesc
# * source
# * up2date
# * url
# * _F_cd_path
# * _F_kernelmod_scriptlet
###
groups=('x11-extra')
pkgdesc="3D accelerated display driver for Nvidia cards"
url="http://www.nvidia.com/object/unix.html"
source=(http://us.download.nvidia.com/XFree86/Linux-$_F_nvidia_arch/$pkgver/$_F_nvidia_name.run)
up2date="lynx -dump http://www.nvidia.com/object/unix.html|grep -m1 '"$_F_nvidia_up2date"'|sed 's/.*]//;s/-/_/'"

_F_cd_path=$_F_nvidia_name
_F_kernelmod_scriptlet=$_F_nvidia_install

###
# == APPENDED VARIABLES
# * depends: add xorg-server and pkgconfig to depends
# * conflicts: add libgl and libglx to conflicts
# * provides: add ligl and libglx to provides
# * options: add nostrip to options
###
depends=(${depends[@]} 'xorg-server>=1.1.0' 'pkgconfig')
conflicts=(${conflicts[@]} 'libgl' 'libglx')
provides=(${provides[@]} 'libgl' 'libglx')
options=(${options[@]} 'nostrip')

if [ "$pkgname" != "nvidia" ]; then
	conflicts=(${conflicts[@]} 'nvidia')
	provides=(${provides[@]} 'nvidia')
fi

###
# == INCLUDES DEPENDANCES
# * kernel-module
###

Finclude kernel-module

###
# == PROVIDED FUNCTIONS
# * Fbuild_nvidia_scriptlet: Build the nvidia scriplet
# * Fbuild_nvidia: Builds the software
# * build(): just calls Fbuild_nvidia
###

Fbuild_nvidia_scriptlet()
{
	cp $Fincdir/nvidia.install ${Fsrcdir%/src}
	Fsed '$pkgname' "$pkgname" ${Fsrcdir%/src}/$_F_kernelmod_scriptlet
	Fsed '$pkgver' "$pkgver" ${Fsrcdir%/src}/$_F_kernelmod_scriptlet
	Fbuild_kernelmod_scriptlet
}

Fbuild_nvidia() {
	cd $Fsrcdir
	sh $_F_nvidia_name.run --extract-only
	Fcd
	Fpatchall

	# Install the binaries
	Fexerel usr/bin/nvidia-* /usr/bin/

	# Xorg modules
	Fmkdir usr/lib/xorg/
	Fcp $_F_cd_path/usr/X11R6/lib/modules /usr/lib/xorg/modules

	# Libraries
	Fexerel usr/lib/*.so* /usr/lib/
	Fexerel usr/lib/libGL.la /usr/lib/libGL.la
	Fsed "__LIBGL_PATH__" "/usr/lib" $Fdestdir/usr/lib/libGL.la

	# Weird TLS stuff
	Fmkdir usr/lib/tls
	Fexerel usr/lib/tls/*.so* /usr/lib/tls/
	Fexerel usr/X11R6/lib/libXv* /usr/lib/

	# Data
	Fmkdir usr/share
	Fcp $_F_cd_path/usr/share/pixmaps /usr/share/
	Fcp $_F_cd_path/usr/share/applications /usr/share/
	Fcp $_F_cd_path/usr/share/man /usr/
	Frm usr/man/man1/nvidia-installer.1.gz
	Fsed "__UTILS_PATH__" "/usr/bin" $Fdestdir/usr/share/applications/nvidia-settings.desktop
	Fsed "__PIXMAP_PATH__" "/usr/share/pixmaps" $Fdestdir/usr/share/applications/nvidia-settings.desktop

	# Library links
	Fln "libGL.so.$_F_nvidia_linkver" "/usr/lib/libGL.so"
	Fln "libGL.so.$_F_nvidia_linkver" "/usr/lib/libGL.so.1"
	Fln "libGL.so.$_F_nvidia_linkver" "/usr/lib/libGL.so.1.2"
	Fln "libGLcore.so.$_F_nvidia_linkver" "/usr/lib/libGLcore.so.1"
	Fln "libnvidia-cfg.so.$_F_nvidia_linkver" "/usr/lib/libnvidia-cfg.so.1"
	Fln "libnvidia-cfg.so.$_F_nvidia_linkver" "/usr/lib/libnvidia-cfg.so"
	Fln "libnvidia-tls.so.$_F_nvidia_linkver" "/usr/lib/libnvidia-tls.so.1"
	Fln "libnvidia-tls.so.$_F_nvidia_linkver" "/usr/lib/tls/libnvidia-tls.so.1"
	Fln "libglx.so.$_F_nvidia_linkver" "/usr/lib/xorg/modules/extensions/libglx.so"
	Fln "libXvMCNVIDIA.so.$_F_nvidia_linkver" "/usr/lib/libXvMCNVIDIA.so"
	Fln "libXvMCNVIDIA.so.$_F_nvidia_linkver" "/usr/lib/libXvMCNVIDIA.so.1"
	Fln "libXvMCNVIDIA.so.$_F_nvidia_linkver" "/usr/lib/libXvMCNVIDIA_dynamic.so.1"
	if [ -e "/usr/lib/xorg/modules/libnvidia-wfb.so.$_F_nvidia_linkver" ]; then
		Fln "libnvidia-wfb.so.$_F_nvidia_linkver" "/usr/lib/xorg/modules/libnvidia-wfb.so"
		Fln "libnvidia-wfb.so.$_F_nvidia_linkver" "/usr/lib/xorg/modules/libnvidia-wfb.so.1"
		Fln "libnvidia-wfb.so.$_F_nvidia_linkver" "/usr/lib/xorg/modules/libwfb.so"
	fi

	# Kernel module
	cd usr/src/nv || Fdie
	ln -s Makefile.kbuild Makefile || Fdie
	make SYSSRC=$_F_kernelmod_dir/build module || Fdie
	cd ../../.. || Fdie
	Ffilerel usr/src/nv/nvidia.ko $_F_kernelmod_dir/kernel/drivers/video/nvidia.ko
	Fbuild_nvidia_scriptlet

	# Documentation
	Fdoc $_F_cd_path/LICENSE
	Fcp $_F_cd_path/usr/share/doc/* /usr/share/doc/$pkgname-$pkgver/
	Fln "$pkgname-$pkgver" "/usr/share/doc/$pkgname"
}

build() {
	Fbuild_nvidia
}
