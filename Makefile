###################################################################################
#   
#   M-Simple Makefile Framework
#   
#   Makefile: Main makefile for frame work
#   
#   M-Simple Makefile Framework is easy makefile for developer who build product 
#   with fixed compiler and system. This framework didn't consider any problem about 
#   migrating code from different platform, you need fix your tool-chain. This tool
#   only valid for GNU tool-chain and run under bash shell.
#
#   See rules.mk and common.mk to get more detail.
#   This file should put in the every directory you want to build.
#
#   License:
#       There is no license here, you can use this as your wish, but you must keep 
#   this line(the author's information) below not to be removed or modified.
#
#   Author: h_f22@163.com       Data:2014/12/10
#
###################################################################################

# TOPDIR is a very important variable in our Makefile. You should specific the relatity
# path to the top directory of the project.
TOPDIR := .

# This file contain global configure for makefile
include $(TOPDIR)/common.mk

# Configure below can override the value in common.mk so after this is the private 
# variable

# SUBDIR is directories which you want to compile, but it won't link to target unless DEP_DIR 
# is non if you want you dir moudule link to target, write it in DEP_DIR. This won't lead 
# to double compile. 
# The SUBDIR variable can support keyword 'all', use this keyword specific all sub directory
# which include Makefile in current directory.
# Notice: If you leave DEP_DIR blank, its value will inhert from SUBDIR, that mean's all subdir
# will link to target
SUBDIR := 
DEP_DIR := 
# if you don't want some directories link to target write here and they will filter out from DEP_DIR
NON_DEP_DIR :=

# If your target is depend some library out of current directory (usually not system but yourself)
# you should specific the library position use DEP_LIBS variable, and this will lead the library 
# complie automatic before it link to the target.
#
# These things you must metion:
#
# 1. Your must specific this use relative path, and the path should be the source code directory
#    Yhich generate the library.
# 2. your must specific the lib file's name same as the library target file name exactly.
# 3. Here we add the source code directory of the library into linking lib search path list (LIBPATH)
#
# example:
#    DEP_LIBS := $(TOPDIR)/lib/libtest/libtest.so
#
#    The libtest directory contain the source code of the library and after make libtest.so file 
#    will generated in the directory
DEP_LIBS := 

# We will auto get files in current directory for different compile if there is no 
# file specific here.
#
# *.c for C compile
# *.cc and *.cpp for C++ compile
# *.l for lex
# *.y for yacc
# *.s and *.S for assemble
CFILE :=  
CXXFILE :=
LFILE := 
YFILE :=
ASFILE :=

# Here we specific the target file name, you should specific your target name without suffix
# in variable TARGET and here we will explain the target file name automatic. 
# We directly use TARGET for bin target file name and add suffix .so for dyn-lib type, if you
# specific the so version in SO_VER this will add after it too. We use .o suffix for obj type 
# and .a suffix for static-lib.
#
# When type is obj, directory will use to name the basename of obj file and add underline (_)
# before it, TARGET variable will be ignore.
#
# When type is top TARGET varibale will be ignore, and there is no target file name need(Top build
# type won't generate binary file in current directory).
#
# example:
# 1.
#   TARGET := test
#   BUILD_TYPE := bin
#
#   TARGET_FILENAME will be test
# 2.
#   TARGET := libtest
#   BUILD_TYPE := dyn-lib
#   SO_VER := 1.1.1
#
#   TARGET_FILENAME will be libtest.so.1.1.1
# 3.
#   TARGET := test
#   BUILD_TYPE := obj
#   
#   Suppose current directory is /home/src/myproject/aaa TARGET_FILENAME will be _aaa.o
# 4.
#   TARGET := test
#   BUILD_TYPE := static-lib
#
#   TARGET_FILENAME will be test.a
TARGET := 

# Here we setup the build type for target.
#
# We support 4 types:
# 1. obj
# 	This directory will generate a middle obj file named _$(directory name).o TARGET variable will
# 	be ignore here and this file will link to upper target. Linker is specific by $(LO).
# 2. bin
# 	This directory will generate a executable binary file named $(TARGET). Linker is specific by $(LD).
# 3. dyn-lib
# 	This directory will generate a dynamic library file named $(TARGET).so.$(SO_VER) which will build
# 	with -soname $(TARGET).so when link procedure. Linker is specific by $(LD).
# 4. static-lib
#   This directory will generate a static libkrary file name $(TARGET).a. linker is specific by $(AR)
#
# The most special build type is top, top won't generate any binary files in current directory and it
# will only build the sub directory in here. TARGET and DEP_DIR variable will be ignore.
BUILD_TYPE := top
SO_VER :=

# C/C++ custom include file path
INCLUDE += 
CXXINCLUDE += 
# link library search path
LIBPATH += 

# If you want specific your library's runtime path your can use LIB_RPATH to specific it.
# This is only valid for dyn-lib build type.
LIB_RPATH +=

# Link library for target
LIBS += 
# Dynamic link library, add libs you want dynamic link.
DYN_LINK_LIBS :=
# Static link library, add libs you want static link.
STATIC_LINK_LIBS := 

LDFLAGS += 

# Pre-process script for build, this script will run before target build
PRE_SCRIPT :=
# Post-process script for build, this script will run after target build
POST_SCRIPT :=

# Custom auto generate code script
# You should specific you script here and make sure your script can 
# accept your files specific in GEN_CODE_INPUT. GEN_CODE_INPUT is the 
# input file list for generate script and every file in this list will make 
# a single call use GEN_CODE_SCRIPT.
# 
# The source code files generate by this process will depend the input file. 
# If the input file modify all source files generate by this input file will
# regenerate for updatei.
#
# So, your script no need ablity to accept multi-files and no need care about 
# how to updated the bin file after modify input file.
#
# The GEN_CODE_SCRIPT also  can contain your script's parameter or other input
# file, if its parameter contain file include in current directory this will lead
# generate file depend on it and script file too.
#
# If you want makefile help you clean your source code auto generated. You can 
# set AUTO_CLEAN_GEN_CODE to 1 in commmon.mk. Then makefile will run extra script
# to compare the file list before and after run the generate script. The generate
# files will record in a hidden file and when you make clean it will tell makefile
# which files need to be deleted.
#
# example:
#	GEN_CODE_SCRIPT := ./gen_code_from_xml.sh
#	GEN_CODE_INPUT := test1.xml test2.xml
#
#	We suppose command line ./gen_code_from_xml.sh test1.xml will generate test1.c
#	and test2.xml will generate test2.c, so after modify test1.xml and run make test1.c
#	file will regenerate and build will recompile and link.
#
#	You can also make depend script parameter file like this:
#
#	GEN_CODE_SCRIPT := ./gen_code_from_xml.sh -d template.xml
#	GEN_CODE_INPUT := test1.xml test2.xml
#
#	As then, if your script 'gen_code_from_xml.sh' or file 'template.xml' in parameter
#	modified, it will lead regenerate all file. Makefile use 'wildcard' function to check
#	parameter and script wether it's a file.
# 	
GEN_CODE_SCRIPT := 
GEN_CODE_INPUT :=

# CLEAN_SCRIPT will call after all clean work done. You can make custom clean work here.
CLEAN_SCRIPT :=

# If you want link your target by your custom link script you can write it in LINK_SCRIPT
# One target only support one link script.
LINK_SCRIPT := 

# Here if you need custom your makefile we not recommand you modify the rule.mk file 
# directly, please add the custom makefile here and we will include it. You can override 
# the main procedure by yourself. Because here is lower than any main procedure your 
# custom makefile will finally be valid.
SELF_DEF_MAKEFILE := 

include $(TOPDIR)/rules.mk
