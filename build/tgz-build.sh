#!/bin/sh
# Contact form - email form submissions from your website
# Copyright (C) 2014 Stephen Ostermiller
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
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
