# vim: set syn=sh et ai sw=2 st=2 ts=2 tw=0:
#Packager: JRD <jrd@enialis.net>

pkgname=
pkgver=
pkgrel=1cp
#arch=noarch
source=()
sourcetemplate=http://people.salixos.org/jrd/salix/$pkgname/$pkgver-\$arch-$pkgrel/
docs=("readme" "install" "copying" "changelog" "authors" "news" "todo")
#url=
#dotnew=()
#CFLAGS=
#CXXFLAGS=
#options=('noextract')

#doinst() {
#
#}

slackdesc=\
(
#|-----handy-ruler------------------------------------------------------|
"$pkgname ()"
)


build() {
  cd $SRC/$pkgname-$pkgver || exit 1
  perl Makefile.PL || exit 1
  make OPTIMIZE="$CFLAGS" || exit 1
  make install INSTALLDIRS=vendor DESTDIR=$PKG || exit 1
  # Remove perllocal.pod and .packlist if present in the package
  ( for i in perllocal.pod .packlist; do
      find $PKG -name "$i" -exec rm -rf {} \;
    done
  ) || exit 1
}
