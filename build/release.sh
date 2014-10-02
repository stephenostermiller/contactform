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
major=`echo $version | cut -f1 -d.`
let "nextmajor=major+1"
minor=`echo $version | cut -f2 -d.`
let "nextminor=minor+1"
printf -v nextminor "%02d" $nextminor
bugfix=`echo $version | cut -f3 -d.`
let "nextbugfix=bugfix+1"
printf -v nextbugfix "%02d" $nextbugfix

nextversion="0"
while [ $nextversion == "0" ]
do
	echo "Current version: $version"
	echo "Release type: "
	echo "1) Major ($nextmajor.00.00)"
	echo "2) Minor ($major.$nextminor.00)"
	echo "3) Bugfix ($major.$minor.$nextbugfix)"
	read release_type
	case $release_type in
		"1" )
			nextversion="$nextmajor.00.00"
			;;
		"2" )
			nextversion="$major.$nextminor.00"
			;;
		"3" )
			nextversion="$major.$minor.$nextbugfix"
			;;
	esac
done

sed -i s/$version/$nextversion/g src/contact.pl

make clean
make

git commit -a
git tag -a "v$nextversion" -m "Release version $nextversion"

echo "Changed to next version: $nextversion"
echo "Push to origin and github now:"
echo "  git push origin master && git push origin --tags"
echo "  git push github master && git push github --tags"
