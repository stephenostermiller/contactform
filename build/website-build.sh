#!/bin/sh
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