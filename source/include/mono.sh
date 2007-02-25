#!/bin/sh

###
# = mono.sh(3)
# Alex Smith <alex@alex-smith.me.uk>
#
# == NAME
# mono.sh - for Frugalware
#
# == SYNOPSIS
# Common functions for mono packages.
#
# == EXAMPLE
# --------------------------------------------------
# pkgname=galago-sharp
# pkgver=0.5.0
# pkgrel=2
# pkgdesc="Galago Desktop Presence Framework - C# Bindings"
# url="http://www.galago-project.org"
# depends=('libgalago' 'gtk2-sharp>=2.10.0' 'perl-xml-libxml' 'dbus-mono')
# groups=('gnome')
# archs=('i686' 'x86_64')
# source=($url/files/releases/source/$pkgname/$pkgname-$pkgver.tar.bz2 \
#         galago-sharp-0.5.0-fix-nunit-name.patch)
# Finclude mono
# up2date="lynx -dump http://www.galago-project.org/files/releases/source/$pkgname | Flasttar"
# sha1sums=('67ec03129e3ca55c982f0fc3c61825779f80b9f0' \
#           '3e4dcbd3fa3f7b5bb1995c3f268ac19e4c9da15f')
# --------------------------------------------------
#
# == PROVIDED FUNCTIONS
# * Fmonoexport(): creates MONO_SHARED_DIR
###
Fmonoexport() {
	Fmessage "Exporting weird MONO_SHARED_DIR..."
	export MONO_SHARED_DIR=$Fdestdir/weird
	mkdir -p $MONO_SHARED_DIR
}

###
# * Fmonocleanup(): removes MONO_SHARED_DIR
###
Fmonocleanup() {
	Fmessage "Cleaning up MONO_SHARED_DIR..."
	rm -rf $MONO_SHARED_DIR
}

###
# * Fbuild_mono(): improves build() to make use of these functions
###
Fbuild_mono() {
	Fmonoexport
	Fbuild
	Fmonocleanup
}

###
# * build() just calls Fbuild_mono()
###
build() {
	Fbuild_mono
}
