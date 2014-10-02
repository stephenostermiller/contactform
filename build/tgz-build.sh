#!/bin/sh
set -e

version=`build/version.sh`
fileversion=${version//./_}
archive="contactform_$fileversion.tar.gz"

mkdir -p target/www

include="src/contact.pl src/contactform.xml doc/copying.txt target/www/index.html"

if [ -e target/$archive ]
then
	newer=`find $include -newer target/$archive`
	if [ "z$newer" = "z" ]
	then
		exit 0
	fi
fi

rm -rf target/tgz
mkdir -p target/tgz
cp $include target/tgz
cd target/tgz
tar cfz ../$archive *
cd ../..
cp target/$archive target/www

echo "target/$archive"