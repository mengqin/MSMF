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

TOPDIR := ..

include $(TOPDIR)/common.mk

SUBDIR =
DEP_DIR = 
NON_DEP_DIR =

DEP_LIBS := 

CFILE :=  
CXXFILE :=
LFILE := 
YFILE :=

TARGET := test_link_script

BUILD_TYPE := bin
SO_VER :=

INCLUDE += 
CXXINCLUDE += 
LIBPATH += 

LIB_RPATH +=

LIBS += 
DYN_LINK_LIBS :=
STATIC_LINK_LIBS := 

LDFLAGS += 

PRE_SCRIPT :=
POST_SCRIPT :=

GEN_CODE_SCRIPT := ./gen_link_script.sh 
GEN_CODE_INPUT :=

LINK_SCRIPT := test.ld

SELF_DEF_MAKEFILE := 

include $(TOPDIR)/rules.mk
