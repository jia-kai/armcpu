#!/bin/bash -e
# $File: compile_userapp.sh
# $Date: Thu Dec 19 22:24:57 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

GCCPREFIX=mips-sde-elf-

LD=${GCCPREFIX}ld
CC=${GCCPREFIX}gcc
CFLAGS="-mips1 -O2 -fno-builtin -nostdlib  -nostdinc -G0 -Wformat -EL -Wall -Werror"

src=$1
out=$2
obj=${out}.o


if [ -z "$out" ]
then
	echo "usage: $0 <.c source file> <output file>"
	exit
fi

$CC -c $src -DUSER_PROG -Iuser/libs -Ikern/include $CFLAGS -o $obj
$LD -S -T user/libs/user.ld $obj obj/user/libuser.a -o $out
rm -f $obj
