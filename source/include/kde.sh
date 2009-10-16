#!/bin/sh

Finclude cmake

###
# = kde.sh(3)
# Gabriel Craciunescu <crazy@frugalware.org>
#
# == NAME
# kde.sh - for Frugalware
#
# == SYNOPSIS
# Common schema for KDE packages.
#
# == EXAMPLE
# --------------------------------------------------
# pkgname=kdegames
# pkgver=3.95.2
# pkgrel=1
# pkgdesc="Games for KDE."
# groups=('kde')
# archs=('i686' 'x86_64')
# depends=('kdebase')
# Finclude kde
# sha1sums=('1848b81f890180b130000dd6004009d4acc98f48')
# --------------------------------------------------
#
# == OPTIONS
# * _F_kde_ver (default: 4.3.1): The current KDE version.
# * _F_kde_name (defaults to $pkgname): if you want to use a custom package
# name (for example the upstream name contains uppercase letters) then use this
# to declare the real name
# * _F_kde_pkgver (defaults to $pkgver or to $_F_kde_ver if empty): the version of the package
# used to construct the source.
# * _F_kde_subpkgs (no defaults): Special array for splitting packages automatically.
# * _F_cmakekde_final (default: TRUE): Enable finalisation of binaries (Optimize more)
###

if [ -n "$_F_cmake_type" ] && [ "$_F_cmake_type" = "None" ]; then
	_F_KDE_CXX_FLAGS="$_F_KDE_CXX_FLAGS -DNDEBUG -DQT_NO_DEBUG"
fi

if [ -n "$_F_cmake_type" ] && [ "$_F_cmake_type" = "Debug" ]; then
        _F_KDE_CXX_FLAGS="$_F_KDE_CXX_FLAGS -ggdb3"
	options=("${options[@]}" "nostrip")
fi

if [ -z "$_F_cmakekde_final" ]; then
        _F_cmakekde_final="TRUE"
fi

if [ -z "$_F_kde_ver" ]; then
	_F_kde_ver=4.3.2
fi

if [ -z "$_F_kde_name" ]; then
        _F_kde_name=$pkgname
fi

if [ -z "$_F_kde_pkgver" ]; then
	if [ -z "$pkgver" ]; then
		_F_kde_pkgver="$_F_kde_ver"
	else
		_F_kde_pkgver="$pkgver"
	fi
fi

if [ -z "$_F_kde_mirror" ]; then
	# set our preferred mirror
	#_F_kde_mirror="http://kde-mirror.freenux.org"
	_F_kde_mirror="ftp://ftp.kde.org/pub/kde"
fi

if [ -z "$_F_kde_dirname" ]; then
	_F_kde_dirname="stable/$_F_kde_ver/src"
fi

###
# == OVERWRITTEN VARIABLES
# * pkgver (default to $_F_kde_ver if not set)
# * url (if not set)
# * up2date (if not set)
# * source (if empty)
# * _F_cd_path (if not set)
# * makedepends (if not set)
###

if [ -z "$pkgver" ]; then
	pkgver="$_F_kde_ver"
fi

if [ -z "$url" ]; then
	url="http://www.kde.org"
fi

if [ -z "$up2date" ]; then
	up2date="lynx --dump http://www.kde.org | grep -m1 released | sed 's/\(.*\)KDE \(.*\) released/\2/'"
fi

if [ ${#source[@]} -eq 0 ]; then
	source=("$_F_kde_mirror/$_F_kde_dirname/$_F_kde_name-$_F_kde_pkgver.tar.bz2")
fi

if [ -z "$_F_cd_path" ]; then
        _F_cd_path=$_F_kde_name-$_F_kde_pkgver
fi

if [ -z "$makedepends" ]; then
	makedepends=('automoc4')
fi

_F_cmake_confopts="$_F_cmake_confopts \
		-DCONFIG_INSTALL_DIR=/etc/kde/config \
		-DKCFG_INSTALL_DIR=/etc/kde/config.kcfg \
		-DICON_INSTALL_DIR=/usr/share/kde/icons \
		-DKDE4_USE_ALWAYS_FULL_RPATH=ON \
		-DKDE4_ENABLE_FINAL=$_F_cmakekde_final \
		-DKDE_DISTRIBUTION_TEXT='Frugalware Linux'"

kde_install()
{
	## What is that ?
	## - usually an 'normal' named 'project' looks like this:
	## - 'foo' , 'doc/foo' and maybe 'doc/kcontrol/foo'
	## These can be installed auto magically.

	# figure whatever it has docs
	# TODO: add 'kcontrol' check ?!
	if [ -d "doc" ]; then # does a doc folder exists ?
		if [ -d "doc/$1" ]; then #  does the package has docs ?
			Fmessage "Installing docs for $1."
			## install docs
			make -C "doc/$1" DESTDIR=$Fdestdir  install || Fdie
		fi
	fi
	## install the package
	make -C "$1" DESTDIR=$Fdestdir  install || Fdie
}

kde_split()
{
	kde_install "$1"
	## figure whatever we have /etc
	if [ -d "$startdir/pkg/etc" ]; then
		Fsplit "$2" /usr /etc
	else
		Fsplit "$2" /usr
	fi
}

CMakeKDE_split()
{
	local i
	local clean

	## let's try that way
	for i in ${_F_kde_subpkgs[@]}
	do
		## we use for weird or not logical names
		## $pkgname-<the_weird_name>
		clean=$(echo $i|sed 's/.*-//1') # foo-blah -> blah

		## check whatever that project exists
		if [ -d "$clean" ]; then
			## split it
			kde_split "$clean" "$i"
		else
			Fmessage "Aieee project $clean does NOT exists, don't know how to install and split :/ ( Typo? )"
			Fdie
		fi

	done
}

CMakeKDE_export_flags()
{
	export CFLAGS="$CFLAGS -fno-strict-aliasing $_F_KDE_CXX_FLAGS"
        export CXXFLAGS="$CXXFLAGS -fno-strict-aliasing $_F_KDE_CXX_FLAGS"
}

CMakeKDE_make()
{
	CMakeKDE_export_flags
	CMake_prepare_build
	CMake_conf
	## do _not_ use any F* stuff here , cmake does not like it
	make || Fdie
}

CMakeKDE_build()
{
	CMakeKDE_make
	make DESTDIR=$Fdestdir install || Fdie
	if [ "$_F_kde_split_docs" == 1 ]; then
	  Fsplit "$pkgname-docs" /usr/share/doc/HTML
	fi
}

build()
{
	CMakeKDE_build
}

