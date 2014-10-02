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
.PHONY: all
all: dist website

.PHONY: dist
dist: tgz

.PHONY: tgz
tgz: www
	@build/tgz-build.sh

.PHONY: src
src: copyright neaten

.PHONY: copyright
copyright:
	@build/src-copyright-check.sh

.PHONY: neaten
neaten:
	@build/src-neaten.sh

.PHONY: website
website: src
	@build/website-build.sh

.PHONY: release
release: src
	@build/release.sh

.PHONY: clean
clean:
	rm -rf target/

# Target aliases

.PHONY: www
www: website
