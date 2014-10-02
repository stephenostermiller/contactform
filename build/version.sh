#!/bin/sh
set -e

grep "VERSION *=" src/contact.pl | sed 's/[^0-9\.]//g'
