#!/bin/sh

###
# = qt5.sh(3)
# Marius Cirsta <mcirsta@frugalware.org>
#
# == NAME
# qt5.sh - for Frugalware
#
# == SYNOPSIS
# Common schema for qt5 packages
###

###
# == PROVIDED FUNCTIONS
# * build_qt5(): function to build qt5 source packages
###

pkgver=5.6.0
qtpkgname=${pkgname/5-/}
qtpkgfilename=${qtpkgname}-opensource-src-${pkgver}
pkgdesc="The Qt5 toolkit, ${qtpkgname}"
url="http://www.qt.io"
groups=('xlib')
archs=('i686' 'x86_64')
options+=('nodocs')
source=(http://download.qt.io/archive/qt/${pkgver%.*}/${pkgver}/submodules/${qtpkgfilename}.tar.xz)
_F_archive_name=qt-everywhere-opensource-src
up2date="Flasttar $url/download-open-source/"
_F_cd_path=${qtpkgfilename}
makedepends+=('x11-protos' 'gperf')

build_qt5()
{
	Fcd
	qmake-qt5 || Fdie
	Fmake
	make  INSTALL_ROOT=$Fdestdir install || Fdie
	if [ -d "${Fdestdir}/usr/lib/qt5/bin" ]; then
		local i
		for i in ${Fdestdir}/usr/lib/qt5/bin/*; do
			q5=`basename ${i}`
			Fln /usr/lib/qt5/bin/${q5} /usr/bin/${q5}-qt5
		done
        fi
}

build()
{
	build_qt5
}
