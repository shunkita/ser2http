#!/bin/bash -f
DISK=httpcli.po
LIBDIR=../lib/apple2
INCLUDEDIR=$LIBDIR/include
PROGS=(
	"httpbin"
	"ipapi"
	)
for PROG in "${PROGS[@]}" ; do

	echo  "building " $PROG
	cl65 -I $INCLUDEDIR -L $LIBDIR -t apple2 -o $PROG $PROG.c ser2http.lib -m $PROG.map
	java -jar $AC -d $DISK $PROG
	java -jar $AC -as $DISK $PROG BIN < $PROG
done
