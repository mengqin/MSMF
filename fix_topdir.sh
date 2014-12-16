#!/bin/bash


# This script will fix TOPDIR of Makefile in current directory and 
# all its sub directory. Notice that current dir will be the top dir (.)

level=0

function releative_path ()
{
	if [[ $1 == 0 ]]; then
		echo .
	else
		for (( i = 0; i < $1; i ++ )); do
			result=..\\/$result
		done
		echo ${result%\\*}
	fi
}

function fix_topdir ()
{
	cd $1
	if [[ -f Makefile ]]; then
		path=`releative_path $level`
		sed -i "s/^TOPDIR.*=.*$/TOPDIR := $path/g" Makefile
	fi
	level=$level+1
	subdir=`ls -F | grep /`
	if [[ ! -z $subdir ]]; then
		for d in $subdir; do
			fix_topdir $d
			cd ..
			level=$level-1
		done
	fi
}

fix_topdir ./
