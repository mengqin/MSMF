#!/bin/bash

script=`ld --verbose`
IFS=$'\n'
begin=0
meet_fini=0
for l in $script; do
	if [[ $l == "===="* ]] && [ $begin -eq 0 ]; then
		begin=1
		continue
	elif [[ $l == "===="* ]] && [ $begin -eq 1 ]; then
		begin=0
	fi
	if [ $begin -eq 1 ]; then
		if [[ $l =~ \ \.fini\ *: ]]; then
			meet_fini=1
		elif [[ $meet_fini -eq 1 ]] && [[ $l =~ \ }$ ]]; then
			meet_fini=0
			echo $l
			echo "  . = ALIGN (0x200000);"
			echo "  __test_seg_begin = .;"
			echo "  .test_seg : {"
			echo "  *(.test_seg .test_seg.linkonce.*);"
			echo "  *(.test_seg.all);"
			echo "  }"
			echo "  .test_seg_bss : { *(.test_seg_bss .test_seg_bss.linkonce.*) }"
			echo "  . = ALIGN (0x200000);"
			echo "  __test_seg_end = .;"
			continue;
		fi
		echo $l
	fi
done > test.ld

#sed -i 's/^}$/\ .test_seg\ :\ {\ KEEP\ (*(SORT_NONE(.init)))\ }\n}/g' test.ld
