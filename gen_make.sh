#!/bin/bash


# This script will generate Makefile by template in current directory and 
# all its sub directory. TOPDIR in Makefile will be corrent, but other thing
# need to do by yourself.
# Notice that current dir will be the top dir (.)

level=0

function releative_path ()
{
	if [[ $1 == 0 ]]; then
		echo .
	else
		for (( i = 0; i < $1; i ++ )); do
			if [[ $2 == normal ]]; then
				result=../$result
			else
				result=..\\/$result
			fi
		done
		echo ${result%\\*}
	fi
}

function gen_make ()
{
	cd $1
	if [[ -f Makefile ]]; then
		path=`releative_path $level normal`
		cp $path/$2 Makefile
		path=`releative_path $level`
		sed -i "s/^TOPDIR.*=.*$/TOPDIR := $path/g" Makefile
	fi
	level=$level+1
	subdir=`ls -F | grep /`
	if [[ ! -z $subdir ]]; then
		for d in $subdir; do
			gen_make $d $2
			cd ..
			level=$level-1
		done
	fi
}

if [[ $# < 1 ]]; then
	echo "usage: $0 <Makefile template>"
	exit 0
fi

gen_make ./ $1
