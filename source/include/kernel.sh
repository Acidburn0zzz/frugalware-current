#!/bin/sh

# (c) 2006 Miklos Vajna <vmiklos@frugalware.org>
# kernel.sh for Frugalware
# distributed under GPL License

# common scheme for kernel FrugalBuilds

# polite request for people who spin their own kernel fpms:
# please _do_ use the _F_kernel_name directive to identify
# that the kernel isn't the stock distribution kernel

# usage:
# _F_kernel_vmlinuz (defaults to arch/$arch/boot/bzImage)
# _F_kernel_verbose (if length of it isn't zero, then use make with V=1)
# _F_kernel_name (defaults to "", example: "-grsec")
# _F_kernel_ver (defaults to $pkgver)
# _F_kernel_stable (defaults to 0, example: "16")
# _F_kernel_rc (defaults to 0, example: "6")
# _F_kernel_mm (defaults to 0, example: "2")
# _F_kernel_git (defaults to 0, example: "3")

if [ -z "$_F_kernel_ver" ]; then
	_F_kernel_ver=$pkgver
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

_F_kernel_rcver=${_F_kernel_ver%.*}.$((${_F_kernel_ver#*.*.}+1))-rc$_F_kernel_rc
if [ $_F_kernel_rc -gt 0 ]; then
	_F_kernel_mmver=$_F_kernel_rcver-mm$_F_kernel_mm
else
	_F_kernel_mmver=${_F_kernel_ver%.*}.$((${_F_kernel_ver#*.*.}+1))-mm$_F_kernel_mm
fi
if [ $_F_kernel_rc -gt 0 ]; then
	_F_kernel_gitver=$_F_kernel_rcver-git$_F_kernel_git
else
	_F_kernel_gitver=${_F_kernel_ver%.*}.$((${_F_kernel_ver#*.*.}+1))-git$_F_kernel_git
fi
if [ -z "$pkgname" ]; then
	if [ -z "$_F_kernel_name" ]; then
		pkgname=kernel
	else
		pkgname=kernel$_F_kernel_name
	fi
fi
pkgdesc="The Linux Kernel and modules"
url="http://www.kernel.org"
rodepends=('module-init-tools' 'sed')
groups=('base')
archs=('i686' 'x86_64')
options=('nodocs')
up2date="lynx -dump $url/kdist/finger_banner |sed -n 's/.* \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/;1 p'"
source=(ftp://ftp.kernel.org/pub/linux/kernel/v2.6/linux-$_F_kernel_ver.tar.bz2 config)
signatures=("${source[0]}.sign" '')
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

[ "$CARCH" == "x86_64" ] && MARCH=K8
echo "$CARCH" |grep -q 'i.86' && KARCH=i386

subpkgs=("kernel$_F_kernel_name-source" "kernel$_F_kernel_name-docs")
subdescs=('Linux kernel source' 'Linux kernel documentation')
subdepends=("make gcc kernel-headers kernel$_F_kernel_name-docs" 'kernel')
if [ -z "$_F_kernel_name" ]; then
	subgroups=('devel' 'apps')
else
	subgroups=('devel-extra' 'apps-extra')
fi
subarchs=('i686 x86_64' 'i686 x86_64')
subinstall=('src/kernel-source.install' '')
suboptions=('nodocs' '')

Fbuildkernel()
{
	Fcd linux-$_F_kernel_ver
	cp $Fsrcdir/config .config
	Fsed "486" "`echo ${MARCH:-$CARCH}|sed 's/^i//'`" .config
	[ $_F_kernel_stable -gt 0 ] && Fpatch patch-$_F_kernel_ver.$_F_kernel_stable
	[ $_F_kernel_rc -gt 0 ] && Fpatch patch-$_F_kernel_rcver
	[ $_F_kernel_mm -gt 0 ] && Fpatch $_F_kernel_mmver
	[ $_F_kernel_git -gt 0 ] && Fpatch patch-$_F_kernel_gitver
	Fpatchall
	yes "" | make config
	Fsed "SUBLEVEL =.*" "SUBLEVEL = ${_F_kernel_ver#*.*.}" Makefile
	Fsed "EXTRAVERSION =.*" "EXTRAVERSION = $_F_kernel_name-fw$pkgrel" Makefile
	
	## let we do kernel$_F_kernel_name-source before make
	Fmkdir /usr/src
	cp -Ra $Fsrcdir/linux-$_F_kernel_ver $Fdestdir/usr/src/linux-$_F_kernel_ver$_F_kernel_name-fw$pkgrel
	rm -rf $Fdestdir/usr/src/linux-$_F_kernel_ver$_F_kernel_name-fw$pkgrel/{Documentation,COPYING,CREDITS,MAINTAINERS,README,REPORTING-BUGS}
	Fln linux-$_F_kernel_ver$_F_kernel_name-fw$pkgrel /usr/src/linux
	Fsplit kernel$_F_kernel_name-source usr/src

	## now the kernel$_F_kernel_name-docs
	Fmkdir /usr/src/linux-$_F_kernel_ver$_F_kernel_name-fw$pkgrel
	cp -Ra $Fsrcdir/linux-$_F_kernel_ver/{Documentation,COPYING,CREDITS,MAINTAINERS,README,REPORTING-BUGS} \
	                 $Fdestdir/usr/src/linux-$_F_kernel_ver$_F_kernel_name-fw$pkgrel
        ## do we need to ln /usr/share/doc ?!
	Fsplit kernel$_F_kernel_name-docs usr/src

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
	Ffilerel .config /boot/config-$_F_kernel_ver$_F_kernel_name-fw$pkgrel
	if [ ! -z "$_F_kernel_vmlinuz" ]; then
		Ffilerel $_F_kernel_vmlinuz /boot/vmlinuz-$_F_kernel_ver$_F_kernel_name-fw$pkgrel
	else
		Ffilerel arch/${KARCH:-$CARCH}/boot/bzImage \
			/boot/vmlinuz-$_F_kernel_ver$_F_kernel_name-fw$pkgrel
	fi
	Fmkdir /lib/modules
	make INSTALL_MOD_PATH=$Fdestdir modules_install
	# dump symol versions so that later builds will have dependencies and
	# modversions
	Ffilerel System.map /boot/System.map-$_F_kernel_ver$_F_kernel_name-fw$pkgrel
	Ffilerel /usr/src/linux-$_F_kernel_ver$_F_kernel_name-fw$pkgrel/Module.symvers
	Frm /lib/modules/$_F_kernel_ver$_F_kernel_name-fw$pkgrel/build
	Frm /lib/modules/$_F_kernel_ver$_F_kernel_name-fw$pkgrel/source
	Fln /usr/src/linux-$_F_kernel_ver$_F_kernel_name-fw$pkgrel \
		/lib/modules/$_F_kernel_ver$_F_kernel_name-fw$pkgrel/build
	Fln /usr/src/linux-$_F_kernel_ver$_F_kernel_name-fw$pkgrel \
		/lib/modules/$_F_kernel_ver$_F_kernel_name-fw$pkgrel/source

	# scriptlets
	cp $Fincdir/kernel.install $Fsrcdir
	Fsed '$_F_kernel_name' "$_F_kernel_name" $Fsrcdir/kernel.install
	cp $Fincdir/kernel-source.install $Fsrcdir
	Fsed '$_F_kernel_name' "$_F_kernel_name" $Fsrcdir/kernel-source.install
}

build()
{
	Fbuildkernel
}
