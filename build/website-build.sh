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

mkdir -p target/
donefile=target/.www.tstamp

if [ -e $donefile ]
then
	newer=`find doc/www -newer $donefile`
	if [ "z$newer" = "z" ]
	then
		exit 0
	fi
fi

if ! grep -q "Version $version" doc/www/bte/index.bte
then
	echo "Change log does not have information about $version in doc/www/bte/index.bte"
fi

rm -rf target/www
mkdir -p target/www

cp doc/www/bte/*.bte target/www
cd target/www
bte *.bte
rm *.bte
sed -i "s/FILEVERSION/$fileversion/g;s/VERSION/$version/g" *.html
cd ../..
cp doc/www/img/* target/www

for conf in doc/www/form/*.xml
do
	cp $conf target/www
	confname=${conf##*/}
	basename=${confname%.xml}
	sed -r "s/(settings.*configuration_file.* = ).*/\1'$confname';/g" src/contact.pl > target/www/$basename.pl
done

echo "Website created in target/www"

touch $donefile
