#!/bin/sh

# (c) 2006 Miklos Vajna <vmiklos@frugalware.org>
# kde.sh for Frugalware
# distributed under GPL License

# common url, up2date, and source(), and build() for kde packages
url="http://www.kde.org"
kdever=3.5.4
#pkgurl="ftp://ftp.solnet.ch/mirror/KDE/stable/$kdever/src"
#pkgurl="ftp://ftp.tu-chemnitz.de/pub/X11/kde/stable/$kdever/src"
pkgurl="ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/ftp.kde.org/pub/kde/stable/$kdever/src"

# strip down the -docs suffix
kdename=`echo $pkgname|sed 's/-docs$//'`
up2date="lynx -dump http://www.kde.org/download/|grep $kdename|sed -n '1 p'|sed 's/.*-\([^ ]*\) .*/\1/'"
source=($pkgurl/$kdename-$pkgver.tar.bz2)
unset kdename
# qt's post_install is essential for kde pkgs
options=(${options[@]} 'scriptlet')

if [ "`cat /proc/meminfo |grep MemTotal|sed 's/.* \(.*\) kB/\1/'`" -ge 500000 ]; then
	Fconfopts="$Fconfopts --enable-final"
fi

build() 
{
     Fbuild CXXFLAGS="$CXXFLAGS -Wno-deprecated" \
		--disable-dependency-tracking \
		--disable-debug --without-debug \
		--with-gnu-ld --enable-new-ld-flags \
		--enable-gcc-hidden-visibility
}

