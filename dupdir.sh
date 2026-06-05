#!/bin/bash

src_dir=$1
dest_dir=$2

if [ -z "$src_dir" ]
then
	echo "Source dir not supplied"
	exit 1
fi

if [ -z "$dest_dir" ]
then
	echo "Destination dir not supplied"
	exit 1
fi

if [ ! -d $src_dir ]
then
	echo "Source dir '$src_dir' does not exist"
	exit 1
fi

if [ ! -d $dest_dir ]
then
	echo "Destination dir '$dest_dir' does not exist"
	exit 1
fi

if [ ! -r $src_dir ]
then
	echo "Source dir '$src_dir' is not readable by you"
	exit 1
fi

if [ ! -w $dest_dir ]
then
	echo "Destination dir '$dest_dir' is not writeable by you"
	exit 1
fi

pushd $dest_dir >/dev/null 2>&1 || exit 1
dest_dir=$PWD
popd > /dev/null 2>&1 || exit 1

pushd $src_dir >/dev/null 2>&1 || exit 1
src_dir=$PWD
popd > /dev/null 2>&1 || exit 1

echo -n "Duplicating '$src_dir' into '$dest_dir'..."
sudo tar --atime-preserve=system --numeric-owner -C $src_dir -cf - . | sudo tar --numeric-owner --same-permissions --same-owner -C $dest_dir -xf - 
if [ ! $? -eq 0 ]
then
	echo " Failed"
	exit 1
fi

echo " Succeeded"

