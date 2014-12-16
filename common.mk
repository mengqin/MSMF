###################################################################################
#	
#	M-Simple Makefile Framework
#	
#	common.mk: Global configure file
#	
#	M-Simple Makefile Framework is easy makefile for developer who build product 
#	with fixed compiler and system. This framework didn't consider any problem about 
#	migrating code from different platform, you need fix your tool-chain. This tool
#	only valid for GNU tool-chain and run under bash shell.
#
#	See rules.mk to get more detail.
#	This file should always be put in the top directory of the project.
#
#	License:
#		There is no license here, you can use this as your wish, but you must keep 
#	this line(the author's information) below not to be removed or modified.
#
#	Author: h_f22@163.com		Data:2014/12/10
#
###################################################################################

# Here you can configure your own global setup for Makefile.
# This file should be always in top directory of project

CC := gcc
CXX := g++
CFLAGS := -O2 -Wall -Wno-unused-function -Wno-return-type
CXXFLAGS := $(CFLAGS)
LD := $(CC)
LO := $(CC)
INCLUDE := 
CXXINCLUDE := $(INCLUDE)
# Link library search path
LIBPATH := 

# Link library
# Notice here this is the global setup of Makefile. Any libs you add here will 
# link to all target file. Unless you mean it, else leave it blank.
# Auto link library linker will make option by default
LIBS := 
# Dynamic link library, add libs you want dynamic link.
DYN_LINK_LIBS :=
# Static link library, add libs you want static link.
STATIC_LINK_LIBS := 
# If you want specific you own runtime path for library write it here
LIB_RPATH := 
LDFLAGS := 
AR := ar
ARFLAGS := -r -c -s
LEX := flex
LFLAGS := 
YACC := bison
YFLAGS := -d
MAKE := make
STRIP := strip
STRIP_FLAGS := 

# Debug mode, this will close optimization of compiler and add -g switch for debug 
# information
DEBUG := 0
# Quiet mode, this will screen all stdout of command line and print information
# for easy reading
QUIET := 1

# Directory name for compiler generate depend file 
# If you leave it blank it will same as source code's directory.
DEP_TEMP_DIR := .deps
# Directory name for compiler generate middle object file.
# If you leave it blank it will same as source code's directory.
OBJ_TEMP_DIR := .objs

# Install directory for bin and lib file. These directory will only 
# create in top directory of project.
# If you leave them blank, the default value will use. (same as below)
BIN_INSTALL_DIR := bin
LIB_INSTALL_DIR := lib

# You can sepcific your code custom generate script and use them to output 
# source code. This switch will help you clean your source code file generated 
# automatic when you run make clean.
AUTO_CLEAN_GEN_CODE := 1

# We will do strip to binary files in install directory according these switch
# below
# If you want strip your executable file set it 1.
STRIP_BIN := 1
# If you want strip your library file set it 1.
STRIP_LIB := 0
# If you don't want strip your file when debug mode set it 1.
DEBUG_NOT_STRIP := 1

