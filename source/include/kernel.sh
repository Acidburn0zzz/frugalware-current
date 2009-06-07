#!/bin/sh

Finclude kernel-version

###
# = kernel.sh(3)
# Miklos Vajna <vmiklos@frugalware.org>
#
# == NAME
# kernel.sh - for Frugalware
#
# == SYNOPSIS
# Common schema for kernel packages.
#
# == EXAMPLE
# * To build a vanilla upstream kernel with a custom version and config:
# --------------------------------------------------
# pkgver=2.6.20
# pkgrel=1
# _F_kernel_name="-custom"
# Finclude kernel
# --------------------------------------------------
# * To use a given patchset (for example -ck):
# --------------------------------------------------
# pkgver=2.6.20
# pkgrel=1
# _F_kernel_name="-ck"
# _F_kernel_patches=(http://www.kernel.org/pub/linux/kernel/people/ck/patches/\
# 2.6/2.6.20/2.6.20-ck1/patch-2.6.20-ck1.bz2)
# Finclude kernel
# --------------------------------------------------
# == OPTIONS
# You are strongly recommended to use the pkgver and pkgrel variables, however
# all the variables are optional. Here is a list of them:
#
# * _F_kernel_vmlinuz (defaults to arch/$arch/boot/bzImage): path to the kernel
# binary
# * _F_kernel_verbose: if set, then the V=1 parameter will be passed to make
# * _F_kernel_name (defaults to ""): include a string in the kernel version
# string (example: "-mygrsec")
# * _F_kernel_ver (defaults to $pkgver): the version of the kernel
# * _F_kernel_rel (defaults to $pkgrel): the release of the kernel (used in the
# kernel version string)
# * _F_kernel_stable: if set, the version of the stable patch to use (example:
# "16", it will be set to _F_kernelver_stable if pkgrel is not specified)
# * _F_kernel_rc: if set, the version of the rc patch to use (example: "6")
# * _F_kernel_mm: if set, the version of the mm patch to use (example: "2")
# * _F_kernel_git if set, the version of the git patch to use (example: "3")
# * _F_kernel_dontfakeversion if set, don't replace the kernel version string
# with a generated one (from _F_kernel_ver, _F_kernel_name and _F_kernel_rel)
# * _F_kernel_uname: specify the kernel version manually (defaults to
# $_F_kernel_name-fw$_F_kernel_rel)
# * _F_kernel_path: vmlinuz on x86, vmlinux on ppc
#
# == OVERWRITTEN VARIABLES
# * pkgver (if not set)
# * pkgrel (if not set)
###
if [ -z "$pkgver" ]; then
	pkgver=$_F_kernelver_ver
fi

if [ -z "$pkgrel" ]; then
	pkgrel=$_F_kernelver_rel
	_F_kernel_stable=$_F_kernelver_stable
fi

if [ -z "$_F_kernel_ver" ]; then
	_F_kernel_ver=$pkgver
fi

if [ -z "$_F_kernel_rel" ]; then
	_F_kernel_rel=$pkgrel
fi

if [ -z "$_F_kernel_stable" ]; then
	_F_kernel_stable=0
fi

if [ -z "$_F_kernel_rc" ]; then
	_F_kernel_rc=0
fi

if [ -z "$_F_kernel_mm" ]; then
	_F_kernel_mm=0
fi

if [ -z "$_F_kernel_git" ]; then
	_F_kernel_git=0
fi

if [ -z "$_F_kernel_dontfakeversion" ]; then
	_F_kernel_dontfakeversion=0
fi
if [ -z "$_F_kernel_uname" ]; then
	_F_kernel_uname="$_F_kernel_name-fw$_F_kernel_rel"
fi

if [ -n "$_F_kernel_dontsedarch" ]; then
	Fmessage "Option _F_kernel_dontsedarch was removed and does nothing at the moment, please update your FrugalBuild!."
fi

if [ -n "$_F_kernel_manualamd64" ]; then
	Fmessage "Option _F_kernel_manualamd64 was removed and does nothing at the moment, please update your FrugalBuild!."
fi

_F_kernel_rcver=${_F_kernel_ver%.*}.$((${_F_kernel_ver#*.*.}+1))-rc$_F_kernel_rc
if [ $_F_kernel_rc -gt 0 ]; then
	_F_kernel_mmver=$_F_kernel_rcver-mm$_F_kernel_mm
else
	_F_kernel_mmver=$_F_kernel_ver-mm$_F_kernel_mm
fi
if [ $_F_kernel_rc -gt 0 ]; then
	_F_kernel_gitver=$_F_kernel_rcver-git$_F_kernel_git
else
	_F_kernel_gitver=$_F_kernel_ver-git$_F_kernel_git
fi
if [ -z "$_F_kernel_path" ]; then
	if [ "$CARCH" != "ppc" ]; then
		_F_kernel_path=vmlinuz
	else
		_F_kernel_path=vmlinux
	fi
fi
[ "$CARCH" = "ppc" ] && export LDFLAGS="${LDFLAGS/-Wl,/}"

###
# * pkgname
# * pkgdesc
###
if [ -z "$pkgname" ]; then
	if [ -z "$_F_kernel_name" ]; then
		pkgname=kernel
	else
		pkgname=kernel$_F_kernel_name
	fi
fi
if [ -z "$_F_kernel_name" ]; then
	pkgdesc="The Linux Kernel and modules"
else
	pkgdesc="The Linux Kernel and modules (${_F_kernel_name/-} version)"
fi
###
# * url
# * rodepends
# * makedepends
# * groups
# * replaces
# * archs
# * options()
# * up2date
# * source()
# * signatures()
# * install
###
url="http://www.kernel.org"
rodepends=('module-init-tools' 'sed')
if [ "`vercmp 2.6.21 $_F_kernel_ver`" -le 0 ]; then
	rodepends=(${rodepends[@]} 'alsa-firmware')
fi
if [ "`vercmp 2.6.23 $_F_kernel_ver`" -le 0 ]; then
	rodepends=(${rodepends[@]} 'irqbalance')
fi
if [ -z "$_F_kernel_name" ]; then
	makedepends=('unifdef')
fi
groups=('base')
archs=('i686' 'x86_64' 'ppc')
options=('nodocs' 'genscriptlet')
up2date="lynx -dump $url/kdist/finger_banner |sed -n 's/.* \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/;1 p'"
if [ "`vercmp 2.6.24 $_F_kernel_ver`" -le 0 ]; then
	source=(ftp://ftp.kernel.org/pub/linux/kernel/v2.6/linux-$_F_kernel_ver.tar.bz2 \
		config.i686 config.x86_64 config.ppc)
	# this can be removed after Frualware 1.0 is out
	replaces=('gspcav1' 'atl2')
else
	source=(ftp://ftp.kernel.org/pub/linux/kernel/v2.6/linux-$_F_kernel_ver.tar.bz2 config)
fi
signatures=("${source[0]}.sign" '' '' '')
install="src/kernel.install"

for i in ${_F_kernel_patches[@]}
do
	source=(${source[@]} $i)
	signatures=("${signatures[@]}" '')
done

[ "$_F_kernel_stable" -gt 0 ] && \
	source=(${source[@]} ftp://ftp.kernel.org/pub/linux/kernel/v2.6/patch-$_F_kernel_ver.$_F_kernel_stable.bz2) && \
	signatures=("${signatures[@]}" ${source[$((${#source[@]}-1))]}.sign)

[ $_F_kernel_rc -gt 0 ] && \
	source=(${source[@]} ftp://ftp.kernel.org/pub/linux/kernel/v2.6/testing/patch-$_F_kernel_rcver.bz2) && \
	signatures=("${signatures[@]}" ${source[$((${#source[@]}-1))]}.sign)

if [ $_F_kernel_mm -gt 0 ]; then
	if [ $_F_kernel_rc -gt 0 ]; then
		source=(${source[@]} http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/$_F_kernel_rcver/$_F_kernel_mmver/$_F_kernel_mmver.bz2)
	else
		source=(${source[@]} http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/$_F_kernel_ver/$_F_kernel_mmver/$_F_kernel_mmver.bz2)
	fi
	signatures=("${signatures[@]}" ${source[$((${#source[@]}-1))]}.sign)
fi

if [ $_F_kernel_git -gt 0 ]; then
	source=(${source[@]} http://www.kernel.org/pub/linux/kernel/v2.6/snapshots/patch-$_F_kernel_gitver.bz2)
	signatures=("${signatures[@]}" ${source[$((${#source[@]}-1))]}.sign)
fi

###
# * subpkg()
# * subdepends()
# * subarchs()
# * subinstall()
# * suboptions()
# * subgroups()
# * subdescs()
###
subpkgs=("kernel$_F_kernel_name-source" "kernel$_F_kernel_name-docs")
subdepends=("make gcc kernel-headers kernel$_F_kernel_name-docs" "kernel$_F_kernel_name")
subarchs=('i686 x86_64 ppc' 'i686 x86_64 ppc')
subinstall=('src/kernel-source.install' '')
suboptions=('nodocs' '')
if [ -z "$_F_kernel_name" ]; then
	subpkgs=("${subpkgs[@]}" 'kernel-headers')
	subdepends=("${subdepends[@]}" '')
	subgroups=('devel' 'apps' 'devel devel-core')
	subdescs=('Linux kernel source' 'Linux kernel documentation' 'Linux kernel include files')
	subarchs=("${subarchs[@]}" 'i686 x86_64 ppc')
	subinstall=("${subinstall[@]}" '')
	suboptions=("${suboptions[@]}" '')
else
	subgroups=('devel-extra' 'apps-extra')
	subdescs=("Linux kernel source (${_F_kernel_name/-} version)" \
		"Linux kernel documentation (${_F_kernel_name/-} version)")
fi

###
# == PROVIDED FUNCTIONS
# * Fbuildkernel()
###
Fbuildkernel()
{
	Fcd linux-$_F_kernel_ver
	make clean || Fdie
	if [ -e "$Fsrcdir/config.$CARCH" ]; then
		cp $Fsrcdir/config.$CARCH .config || Fdie
	else
		cp $Fsrcdir/config .config || Fdie
	fi

	if [ -n "$_F_kernel_stable" ]; then
		sed -i "/Linux kernel version:/s/: .*/: $_F_kernel_ver.$_F_kernel_stable/" .config
	fi

	[ $_F_kernel_stable -gt 0 ] && Fpatch patch-$_F_kernel_ver.$_F_kernel_stable
	[ $_F_kernel_rc -gt 0 ] && Fpatch patch-$_F_kernel_rcver
	[ $_F_kernel_mm -gt 0 ] && Fpatch $_F_kernel_mmver
	[ $_F_kernel_git -gt 0 ] && Fpatch patch-$_F_kernel_gitver
	# not using Fpatchall here since not applying the patches from
	# _F_kernel_patches() having the wrong extension would be stange :)
	for i in ${_F_kernel_patches[@]}
	do
		Fpatch `strip_url $i`
	done
	# remove unneded localversions
	rm -f localversion-*
	make silentoldconfig || Fdie

	## FIXME: remove or do it right -- crazy --
	if [ $_F_kernel_dontfakeversion -eq 0 ]; then
		Fsed "SUBLEVEL =.*" "SUBLEVEL = ${_F_kernel_ver#*.*.}" Makefile
		Fsed "EXTRAVERSION =.*" "EXTRAVERSION = $_F_kernel_uname" Makefile
	fi

	## let we do kernel$_F_kernel_name-source before make
	Fmkdir /usr/src
	cp -Ra $Fsrcdir/linux-$_F_kernel_ver $Fdestdir/usr/src/linux-$_F_kernel_ver$_F_kernel_uname || Fdie
	rm -rf $Fdestdir/usr/src/linux-$_F_kernel_ver$_F_kernel_uname/{Documentation,COPYING,CREDITS,MAINTAINERS,README,REPORTING-BUGS} || Fdie
	Fln linux-$_F_kernel_ver$_F_kernel_uname /usr/src/linux
	Fsplit kernel$_F_kernel_name-source usr/src

	## now the kernel$_F_kernel_name-docs
	Fmkdir /usr/src/linux-$_F_kernel_ver$_F_kernel_uname
	cp -Ra $Fsrcdir/linux-$_F_kernel_ver/{Documentation,COPYING,CREDITS,MAINTAINERS,README,REPORTING-BUGS} \
	                 $Fdestdir/usr/src/linux-$_F_kernel_ver$_F_kernel_uname || Fdie
        ## do we need to ln /usr/share/doc ?!
	Fsplit kernel$_F_kernel_name-docs usr/src

	if [ -z "$_F_kernel_name" ]; then
		make INSTALL_HDR_PATH=$Fdestdir/usr headers_install || Fdie
		[ -e $Fdestdir/usr/include/scsi ] && Frm /usr/include/scsi
		[ -e $Fdestdir/usr/include/drm ] && Frm /usr/include/drm
		Fsplit kernel-headers /usr
	fi
	## now time to eat some cookies and wait kernel got compiled :)
	if [ -z "$_F_kernel_name" ]; then
		# stock kernel, nobody interested in the buildsystem's details
		Fsed '`whoami`' 'fst' scripts/mkcompile_h
		Fsed '`hostname \| $UTS_TRUNCATE`' "`uname -m`.frugalware.org" scripts/mkcompile_h
	fi
	if [ "$_F_kernel_verbose" ]; then
		make V=1 || Fdie
	else
		make || Fdie
	fi

	Fmkdir /boot
	Ffilerel .config /boot/config-$_F_kernel_ver$_F_kernel_uname
	if [ ! -z "$_F_kernel_vmlinuz" ]; then
		Ffilerel $_F_kernel_vmlinuz /boot/$_F_kernel_path-$_F_kernel_ver$_F_kernel_uname
	else
		if [ "$CARCH" = "ppc" ]; then
			Fexerel $_F_kernel_path /boot/$_F_kernel_path-$_F_kernel_ver$_F_kernel_uname
		else
			Ffilerel arch/x86/boot/bzImage /boot/$_F_kernel_path-$_F_kernel_ver$_F_kernel_uname
		fi
	fi
	Fmkdir /lib/modules
	make INSTALL_MOD_PATH=$Fdestdir modules_install || Fdie
	# dump symol versions so that later builds will have dependencies and
	# modversions
	Ffilerel System.map /boot/System.map-$_F_kernel_ver$_F_kernel_uname
	Ffilerel /usr/src/linux-$_F_kernel_ver$_F_kernel_uname/Module.symvers
	Frm /lib/modules/$_F_kernel_ver$_F_kernel_uname/build
	Frm /lib/modules/$_F_kernel_ver$_F_kernel_uname/source
	Fln /usr/src/linux-$_F_kernel_ver$_F_kernel_uname \
		/lib/modules/$_F_kernel_ver$_F_kernel_uname/build
	Fln /usr/src/linux-$_F_kernel_ver$_F_kernel_uname \
		/lib/modules/$_F_kernel_ver$_F_kernel_uname/source

	# scriptlets
	cp $Fincdir/kernel.install $Fsrcdir || Fdie
	Fsed '$_F_kernel_ver' "$_F_kernel_ver" $Fsrcdir/kernel.install
	Fsed '$_F_kernel_uname' "$_F_kernel_uname" $Fsrcdir/kernel.install
	Fsed '$_F_kernel_path' "$_F_kernel_path" $Fsrcdir/kernel.install
	cp $Fincdir/kernel-source.install $Fsrcdir || Fdie
	Fsed '$_F_kernel_ver' "$_F_kernel_ver" $Fsrcdir/kernel-source.install
	Fsed '$_F_kernel_uname' "$_F_kernel_uname" $Fsrcdir/kernel-source.install
	Fsed '$_F_kernel_name' "$_F_kernel_name" $Fsrcdir/kernel-source.install
	Fsed '$_F_kernel_rel' "$_F_kernel_rel" $Fsrcdir/kernel-source.install
}

###
# * build() just calls Fbuildkernel()
###
build()
{
	Fbuildkernel
}
