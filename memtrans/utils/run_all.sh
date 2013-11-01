#!/bin/bash -e
# $File: run_all.sh
# $Date: Fri Nov 01 22:31:22 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

DATA_SIZE=88800
WORKDIR=/tmp/thuco-ram-flash-test
rm -rf $WORKDIR
mkdir -pv $WORKDIR
echo 'generating random data file'
dd if=/dev/urandom of=$WORKDIR/f1 bs=1 count=$DATA_SIZE
dd if=/dev/urandom of=$WORKDIR/f2 bs=1 count=$DATA_SIZE

cnt=1
for start_addr in 128k 5M
do
	echo "test ram write $start_addr ..."
	./controller.py ram write $start_addr $WORKDIR/f$cnt
	let cnt=$cnt+1
done

cnt=1
for start_addr in 128k 5M
do
	echo "test ram read $start_addr ..."
	./controller.py ram read $start_addr $DATA_SIZE $WORKDIR/fout
	diff $WORKDIR/{f$cnt,fout}
	let cnt=$cnt+1
done

cat $WORKDIR/{f1,f2} > $WORKDIR/fin
echo 'erase flash'
./controller.py flash erase 0 $((DATA_SIZE * 2))

echo 'write flash'
./controller.py flash write 2 $WORKDIR/fin

echo 'read flash'
./controller.py flash read 2 $((DATA_SIZE * 2)) $WORKDIR/fout
diff $WORKDIR/{fin,fout}

echo 'all tests done'

