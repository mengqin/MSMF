###################################################################################
#	
#	M-Simple Makefile Framework
#	
#	rule.mk: Core rule file.
#	
#	M-Simple Makefile Framework is easy makefile for developer who build product 
#	with fixed compiler and system. This framework didn't consider any problem about 
#	migrating code from different platform, you need fix your tool-chain. This tool
#	only valid for GNU tool-chain and run under bash shell.
#
#	Feature:
#	1.No implicit rule.
#	2.Support head file dependance.
#	3.Support lex file (.l) auto compile and dependance.
#	4.Support yacc file (.y) auto compile and dependance.
#	5.Support quiet mode.
#	6.Support debug and non-debug mode.
#	7.Support library depend auto compile.
#	8.Support 4 different targets (bin, obj, static-lib, dyn-lib).
#	9.Support multi-type target build (you can build static-lib and dyn-lib at same 
#	  directory and use same code).
#	10.Support static and dynmatic library link mode.
#	11.Support use custom link script.
#	12.Support custom pre-build and post-build shell script
#	13.Support custom auto genrate code shell script and auto clean for it (generate 
#	file also has dependance with input file and script).
#	14.Support sperated strip option for bin and lib.
#	15.Support parallel compile.
#	16.Support custom makefile.
#
#	See Makefile and common.mk to get more information about how to use.
#	This file should always be put in the top directory of the project.
#
#	License:
#		There is no license here, you can use this as your wish, but you must keep 
#	this line(the author's information) below not be removed or modified.
#
#	Author: h_f22@163.com		Data:2014/12/10
#
###################################################################################


# Don't modify this file unless you know what you are doing.

# We will auto get files in current directory for different compile if there is no 
# file specific in compile list.
#
# *.c for C compile
# *.cc and *.cpp for C++ compile
# *.l for lex
# *.y for yacc
ifeq (_$(CFILE)_,__)
CFILE := $(wildcard *.c)
endif

ifeq (_$(CXXFILE)_,__)
CXXFILE := $(wildcard *.cc *.cpp)
endif

ifeq (_$(LFILE)_,__)
LFILE := $(wildcard *.l)
CFILE += $(foreach cfile,$(LFILE),$(cfile).c)
endif

ifeq (_$(YFILE)_,__)
YFILE := $(wildcard *.y)
CFILE += $(foreach cfile,$(YFILE),$(cfile).c)
endif

ifeq (_$(ASFILE)_,__)
ASFILE := $(wildcard *.s *.S)
endif

# DEP_TEMP_DIR is directory for storage dependance file generate by gcc -M (.d suffix file).
# OBJ_TEMP_DIR is directory for storage obj file generate by gcc (,o suffix file).
# If there is no specific in these variables currnet directory will use by default.
ifeq (_$(DEP_TEMP_DIR)_,__)
DEP_TEMP_DIR := .
endif

ifeq (_$(OBJ_TEMP_DIR)_,__)
OBJ_TEMP_DIR := .
endif

# BIN_INSTALL_DIR and LIB_INSTALL_DIR is the install directory for bin and lib file to
# install. After run make install, these files will copy to it. If you don't specific 
# them default value will be use. All of them will only create on the top directory 
# of the project
#
# default:
# 	$(TOPDIR)/bin for bin file directory
# 	$(TOPDIR)/lib for library file directory
ifeq (_$(BIN_INSTALL_DIR)_,__)
BIN_INSTALL_DIR := $(shell cd $(TOPDIR);pwd)/bin
else
BIN_INSTALL_DIR := $(shell cd $(TOPDIR);pwd)/$(BIN_INSTALL_DIR)
endif

ifeq (_$(LIB_INSTALL_DIR)_,__)
LIB_INSTALL_DIR := $(shell cd $(TOPDIR);pwd)/lib
else
LIB_INSTALL_DIR := $(shell cd $(TOPDIR);pwd)/$(LIB_INSTALL_DIR)
endif

# If your target is depend some library out of current directory (usually not system but yourself)
# you should specific the library position use DEP_LIBS variable, and this will lead the library 
# auto complie before it link to the target.
#
# These things you must metion:
#
# 1. Your must specific this use relative path, and the path should be the source code directory
#    Yhich generate the library.
# 2. your must specific the lib file's name same as the library target file name exactly.
# 3. Here we add the source code directory of the library into linking lib search path list (LIBPATH)
#
# About LIB_DEPEND_SOURCE
# This variable is a global variable in the whole build makefile tree, all makefile record it's absolution
# path if it has DEP_LIBS to be build. This variable will transfer to every sub makefile, and the some one 
# has a loop dependance in the tree it will cut it's own SUBDIR or DEP_DIR accord this variable. This method 
# will avoid sub directory loop dependance. 
ifneq (_$(DEP_LIBS)_,__)
LIBPATH += $(addprefix -L ,$(dir $(DEP_LIBS)))
LIB_DEPEND_SOURCE += $(shell pwd)
endif

# Here you can specific your library's link type (static or dynamic) in these 2 variable.
# STATIC_LINK_LIBS specific static link libs and DYN_LIBK_LIBS for dynamic link.
ifneq (_$(DYN_LINK_LIBS)_,__)
LIBS += -Wl,-Bdynamic $(DYN_LINK_LIBS)
endif

ifneq (_$(STATIC_LINK_LIBS)_,__)
LIBS += -Wl,-Bstatic $(STATIC_LINK_LIBS) -Wl,-Bdynamic
endif


# If we have multi type in one build top type will be ignore
ifneq (_$(words $(BUILD_TYPE))_,_1_)
BUILD_TYPE := $(filter-out top,$(BUILD_TYPE))
endif

# If you want specific your library's runtime path your can use LIB_RPATH to specific it.
# This is only valid for dyn-lib build type.
# Here dyn lib use independent LDFLAGS because other type needn't rpath
ifneq (_$(LIB_RPATH)_,__)
ifeq (_$(filter dyn-lib, $(BUILD_TYPE))_,_dyn-lib_)
LDFLAGS_DYNLIB := $(LDFLAGS) $(foreach rpath,$(LIB_RPATH),-Wl,-rpath=$(rpath)) 
endif
endif

# If you want link your target by your custom link script you can write it in LINK_SCRIPT
# One target only support one link script.
ifneq (_$(LINK_SCRIPT)_,__)
LDFLAGS += -Wl,-T,$(LINK_SCRIPT)
endif

TARGET := $(strip $(TARGET))
BUILD_TYPE := $(strip $(BUILD_TYPE))

ifeq (_$(PARENT_BUILD_TYPE)_,__)
PARENT_BUILD_TYPE := $(BUILD_TYPE)
endif

ifeq (_$(filter dyn-lib, $(PARENT_BUILD_TYPE))_,_dyn-lib_)
ifeq (_$(filter obj, $(BUILD_TYPE))_,_obj_)
CFLAGS += -fPIC
CXXFLAGS += -fPIC
endif
endif

ifeq (_$(filter dyn-lib, $(BUILD_TYPE))_,_dyn-lib_)
CFLAGS += -fPIC
CXXFLAGS += -fPIC
endif

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
# 	TARGET := test
# 	BUILD_TYPE := bin
#
# 	TARGET_FILENAME will be test
# 2.
# 	TARGET := libtest
# 	BUILD_TYPE := dyn-lib
# 	SO_VER := 1.1.1
#
# 	TARGET_FILENAME will be libtest.so.1.1.1
# 3.
# 	TARGET := test
# 	BUILD_TYPE := obj
# 	
# 	Suppose current directory is /home/src/myproject/aaa TARGET_FILENAME will be _aaa.o
# 4.
# 	TARGET := test
# 	BUILD_TYPE := static-lib
#
#	TARGET_FILENAME will be test.a
ifeq (_$(filter top bin obj static-lib dyn-lib,$(BUILD_TYPE))_,__)
$(error Unkown build type: $(BUILD_TYPE))
endif
ifeq (_$(BUILD_TYPE)_,_top_)
TARGET := $(notdir $(shell pwd))
TARGET_FILENAME_TOP := $(TARGET)
TARGET_FILENAME := $(TARGET_FILENAME_TOP)
endif 
ifeq (_$(filter bin,$(BUILD_TYPE))_,_bin_)
TARGET_FILENAME_BIN := $(TARGET)
endif 
ifeq (_$(filter obj,$(BUILD_TYPE))_,_obj_)
TARGET_FILENAME_OBJ := _$(notdir $(shell pwd)).o
ifeq (_$(TARGET)_,__)
TARGET := $(notdir $(shell pwd))
endif
endif
ifeq (_$(filter static-lib,$(BUILD_TYPE))_,_static-lib_)
TARGET_FILENAME_SLIB := $(TARGET).a
endif 
ifeq (_$(filter dyn-lib,$(BUILD_TYPE))_,_dyn-lib_)
ifneq (_$(strip $(SO_VER))_,__)
TARGET_FILENAME_DLIB := $(TARGET).so.$(SO_VER)
else
TARGET_FILENAME_DLIB := $(TARGET).so
endif
endif

ifneq (_$(words $(BUILD_TYPE)),_1_)
TARGET_FILENAME := $(TARGET_FILENAME_BIN) $(TARGET_FILENAME_OBJ) $(TARGET_FILENAME_SLIB) $(TARGET_FILENAME_DLIB)
TARGET_FILENAME := $(strip $(TARGET_FILENAME))
endif

# You can specific the debug mode in variable DBEUG, 1 is on and other is off.
# When debug mode on, we will switch off all the optimization of compiler
# and add -g switch for debug information.
ifeq (_$(DEBUG)_, _1_)
CXXFLAGS := $(filter-out -O,$(CFLAGS))
CXXFLAGS := $(filter-out -O0,$(CFLAGS))
CXXFLAGS := $(filter-out -O2,$(CFLAGS))
CXXFLAGS := $(filter-out -O3,$(CFLAGS))
CXXFLAGS := $(filter-out -Os,$(CFLAGS))
CXXFLAGS := $(filter-out -Ofast,$(CFLAGS))
CXXFLAGS := $(filter-out -Og,$(CFLAGS))
CXXFLAGS += -g
CFLAGS := $(filter-out -O,$(CFLAGS))
CFLAGS := $(filter-out -O0,$(CFLAGS))
CFLAGS := $(filter-out -O2,$(CFLAGS))
CFLAGS := $(filter-out -O3,$(CFLAGS))
CFLAGS := $(filter-out -Os,$(CFLAGS))
CFLAGS := $(filter-out -Ofast,$(CFLAGS))
CFLAGS := $(filter-out -Og,$(CFLAGS))
CFLAGS += -g
endif

# If you don't want noise you can specific quiet mode in variable QUIET.
# 1 is on and other is off.
ifeq (_$(QUIET)_,_1_)
Q:=@
else
Q:=
endif



# SUBDIR is used to specific the sub directory which you want build but not link to 
# the current target, if you want some sub directory generate middle obj file and need 
# link them to target you should specific it in DEP_DIR. 
#
# These variables can support keyword 'all', use this keyword specific all sub directory
# which includes Makefile in current directory.
#
# If there are same directorys in SUBDIR and DEP_DIR, DEP_DIR will exclude these same
# directorys, so make sure all SUBDIR is build to bin file but not obj.
#
# Build type top will clear DEP_DIR and it will only build sub directory but not link them 
# together. We suppose this is fact:
# 		Top directory won't generate any binary file and all its sub directory sould be
# single executable file, library or their collection.
ifeq (_$(strip $(SUBDIR))_,_all_)
SUBDIR := $(sort $(shell for f in `ls`; do if [ -d $$f ] && [ -e $$f/Makefile ]; then echo $$f; fi; done))
endif
ifeq (_$(strip $(DEP_DIR))_,_all_)
DEP_DIR := $(sort $(shell for f in `ls`; do if [ -d $$f ] && [ -e $$f/Makefile ]; then echo $$f; fi; done))
endif
ifneq (_$(filter $(DEP_DIR), $(SUBDIR))_,__)
DEP_DIR := $(filter-out $(DEP_DIR), $(SUBDIR))
$(warning DEP_DIR have same dirs in SUBDIR, ignore them, DEP_DIR = $(DEP_DIR))
endif
ifeq (_$(BUILD_TYPE)_,_top_)
DEP_DIR := 
endif

# See Above About LIB_DEPEND_SOURCE variable, Don't modify this unless you know what you do.
ifneq (_$(LIB_DEPEND_SOURCE)_,__)
SUBDIR:=$(notdir $(filter-out $(LIB_DEPEND_SOURCE), $(addprefix $(shell pwd)/,$(SUBDIR))))
DEP_DIR:=$(notdir $(filter-out $(LIB_DEPEND_SOURCE), $(addprefix $(shell pwd)/,$(DEP_DIR))))
endif

# Here we sort file sequence and generate OBJS_LIST for compile.
# C obj file is end with .o and C++ obj file is end with .oo all of them should be in 
# the obj's directory if you specific in OBJ_TEMP_DIR
CFILE := $(sort $(CFILE))

CXXFILE := $(sort $(CXXFILE))

DEP_DIR := $(filter-out $(NON_DEP_DIR),$(DEP_DIR))

DEP_DIR_OBJS := $(foreach obj,$(DEP_DIR),$(obj)/_$(obj).o)

CFILE_OBJS := $(addprefix $(OBJ_TEMP_DIR)/,$(addsuffix .o, $(basename $(CFILE))))

CXXFILE_OBJS := $(addprefix $(OBJ_TEMP_DIR)/,$(addsuffix .oo, $(basename $(CXXFILE))))

ASFILE_OBJS := $(addprefix $(OBJ_TEMP_DIR)/,$(addsuffix .os, $(basename $(ASFILE))))

OBJS_LIST := $(ASFILE_OBJS) $(CFILE_OBJS) $(CXXFILE_OBJS) $(DEP_DIR_OBJS)

# This is main procedure for all, here we support pre-process shell script and post-process
# shell script, if you specific them use PRE_SCRIPT and POST_SCRIPT they will be called
# before and after the build procedure.
#
# We also support you own method to generate source code, gen_code procedure is made for this
# and it will be called before build procedure .
# You can see it for more detail.
.PHONY: all
all: 
ifneq (_$(PRE_SCRIPT)_,__)
	$(Q)$(PRE_SCRIPT)
endif
ifeq (_$(Q)_,_@_)
ifeq (_$(BUILD_TYPE)_,_top_)
	$(Q)echo -e "Building $(shell pwd)"
else
	$(Q)echo -e "Building $(shell pwd)/$(TARGET_FILENAME)"
endif
endif
ifeq (_$(Q)_,_@_)
	$(Q)${MAKE} -s gen_code
else
	$(Q)${MAKE} gen_code
endif
ifeq (_$(Q)_,_@_)
	$(Q)${MAKE} -s depend
else
	$(Q)${MAKE} depend
endif
ifeq (_$(Q)_,_@_)
	$(Q)${MAKE} -s build
else
	$(Q)${MAKE} build
endif
ifneq (_$(POST_SCRIPT)_,__)
	$(Q)$(POST_SCRIPT)
endif

# Here is the defination of template for compile procedure. Every middle file include 
# obj file, lex and yacc generate C file and custom code generate input file will have their
# own single procedure, and then every procedure will have its own dependance-ship.
# These define will expand by the foreach function by make and that are the real compile rule.

# Define for yacc complie file.
# This rule generate .y.c file and depend .y file
define COMPILE_Y_template =
$(2): $(1)
ifeq (_$(Q)_,_@_)
	@echo -e "	[YACC]	$(dir $(shell pwd))$(1)"
endif
	$(Q)$(YACC) $(YFLAGS) -o $(2) $(1)
endef

# Define for lex complie file.
# This rule generate .l.c file and depend .l file
define COMPILE_L_template =
$(2): $(1)
ifeq (_$(Q)_,_@_)
	@echo -e "	[LEX]	$(dir $(shell pwd))$(1)"
endif
	$(Q)$(LEX) $(LFLAGS) -o $(2) $(1)
endef

# Define for assemble file.
# This rule generate .os file and depend .s or .S file
# This rule also prepare directory for depend file and obj file.
define COMPILE_AS_template =
-include $(DEP_TEMP_DIR)/$(notdir $(2:%.os=%.ds))
$(2): $(1)
ifneq (_$(BUILD_TYPE)_,_top_)
	$(Q)$(shell if [ ! -d $(DEP_TEMP_DIR) ]; then \
		mkdir -p $(DEP_TEMP_DIR); \
	fi)
	$(Q)$(shell if [ ! -d $(OBJ_TEMP_DIR) ]; then \
		mkdir -p $(OBJ_TEMP_DIR); \
	fi)
endif
ifeq (_$(Q)_,_@_)
	@echo -e "	[AS]	$(dir $(shell pwd))$(1)"
endif
	$(Q)$(CC) $(CFLAGS) $(INCLUDE) $$< -MM -MF $(DEP_TEMP_DIR)/$(notdir $(2:%.os=%.ds)) -MT '$(2)'
	$(Q)$(CC) $(CFLAGS) $(INCLUDE) -c $$< -o $$@
endef

# Define for C complie file.
# This rule generate .o file and depend .c file
# This rule also prepare directory for depend file and obj file.
define COMPILE_C_template =
-include $(DEP_TEMP_DIR)/$(notdir $(2:%.o=%.d))
$(2): $(1)
ifneq (_$(BUILD_TYPE)_,_top_)
	$(Q)$(shell if [ ! -d $(DEP_TEMP_DIR) ]; then \
		mkdir -p $(DEP_TEMP_DIR); \
	fi)
	$(Q)$(shell if [ ! -d $(OBJ_TEMP_DIR) ]; then \
		mkdir -p $(OBJ_TEMP_DIR); \
	fi)
endif
ifeq (_$(Q)_,_@_)
	@echo -e "	[CC]	$(dir $(shell pwd))$(1)"
endif
	$(Q)$(CC) $(CFLAGS) $(INCLUDE) $$< -MM -MF $(DEP_TEMP_DIR)/$(notdir $(2:%.o=%.d)) -MT '$(2)'
	$(Q)$(CC) $(CFLAGS) $(INCLUDE) -c $$< -o $$@
endef

# Define for C++ complie file.
# This rule generate .oo file and depend .cc or .cpp file
# This rule also prepare directory for depend file and obj file.
define COMPILE_CXX_template =
-include $(DEP_TEMP_DIR)/$(notdir $(2:%.oo=%.dxx))
$(2): $(1)
ifneq (_$(BUILD_TYPE)_,_top_)
	$(Q)$(shell if [ ! -d $(DEP_TEMP_DIR) ]; then \
		mkdir -p $(DEP_TEMP_DIR); \
	fi)
	$(Q)$(shell if [ ! -d $(OBJ_TEMP_DIR) ]; then \
		mkdir -p $(OBJ_TEMP_DIR); \
	fi)
endif
ifeq (_$(Q)_,_@_)
	@echo -e "	[CXX]	$(dir $(shell pwd))$(1)"
endif
	$(Q)$(CXX) $(CXXFLAGS) $(CXXINCLUDE) $$< -MM -MF $(DEP_TEMP_DIR)/$(notdir $(2:%.oo=%.dxx)) -MT '$(2)'
	$(Q)$(CXX) $(CXXFLAGS) $(CXXINCLUDE) -c $$< -o $$@
endef

# Define for DEP_DIR directory.
# This rule will make sub directory in DEP_DIR
# This rule generate $(SUBDIR)/$(OBJ_TEMP_DIR)/_$(SUBDIR).o file and depend in sub directory's file
define COMPILE_DEP_DIR_template =
$(2):
ifeq (_$(Q)_,_@_)
	$(Q)export PARENT_BUILD_TYPE="$(PARENT_BUILD_TYPE)"; \
	export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
	${MAKE} -s -C $(1)
else
	$(Q)export PARENT_BUILD_TYPE="$(PARENT_BUILD_TYPE)"; \
	export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
	${MAKE} -C $(1)
endif
endef

# Define for SUBDIR directory.
# This rule will make sub directory in SUBDIR
# This rule generate $(SUBDIR)/$(SUB_TARGET_FILENAME) file and depend in sub directory's file
# Before build subdir this will make its depend lib by call make depend
define COMPILE_SUBDIR_template =
$(1)_dir:
ifeq (_$$(filter $(1),$(DEP_DIR))_,__)
ifeq (_$(Q)_,_@_)
	$(Q)export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
	${MAKE} -s -C $(1)
else
	$(Q)export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
	${MAKE} -C $(1)
endif
endif
endef

# Define for main target procedure.
# This rule will make depend lib it's generate $(DEP_LIBS) file by call make -C
# Notice here:
# Before build main target its depend libs will be build by call make depend in 
# current directory, and then make will use this function to build all of its 
# depend lib.
define COMPILE_CHECK_DEP_LIBS_template =
depcheck_$(1):
ifeq (_$(Q)_,_@_)
	$(Q)export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
	${MAKE} -s -C $(dir $(1))
else
	$(Q)export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
	${MAKE} -C $(dir $(1))
endif
endef

# Define for custom generate code script.
# This rule will generate a virtual hidden file copy from the generate code input file
# named .$(GEN_CODE_INPUT).last. Every time this procedure run gnu make will check the 
# depend-ship by the original file, if original new than this file we should know the 
# input file is updated and the script should recall to generate new file to build.
#
# You can specfic AUTO_CLEAN_GEN_CODE to enable automatic clean for auto generate code.
# This will lead to run a extra script command to compare the file list before and after 
# the script executing and record new generate files use a file call .$(GEN_CODE_INPUT).genfile.
define COMPILE_GEN_CODE_template =
.$(1).last: $(1)
ifeq (_$(Q)_,_@_)
	$(Q)echo -e "	[GEN_CODE $(GEN_CODE_SCRIPT)]	$(shell pwd)/$(1)"
endif
ifeq (_$(AUTO_CLEAN_GEN_CODE)_,_1_)
	$(Q)ls > .$(1).genfile1.$$$$$$$$; \
	$(GEN_CODE_SCRIPT) $(GEN_CODE_SCRIPT_ARGS) $(1); \
	cp --preserve=timestamp $(1) .$(1).last; \
	ls > .$(1).genfile2.$$$$$$$$; \
	cat .$(1).genfile2.$$$$$$$$ | grep -v "`cat .$(1).genfile1.$$$$$$$$`" >> .$(1).genfile; \
	rm -rf .$(1).genfile1.$$$$$$$$ .$(1).genfile2.$$$$$$$$
else
	$(Q)$(GEN_CODE_SCRIPT) $(GEN_CODE_SCRIPT_ARGS) $(1); \
	cp --preserve=timestamp $(1) .$(1).last
endif
endef

# This procedure is for GEN_CODE_SCRIPT self, if script modified we need regenerate all
# code, here we use last file to record the scripts file time and make depend from old
# one to new one. Once script change, it will touch all input file and call gen_code_input
# to regenerate all code.
define COMPILE_GEN_CODE_SCRIPT_template =
.$(1).last: $(1)
ifneq (_$(2)_,__)
	$(Q)touch $(2)
ifeq (_$(Q)_,_@_)
	$(Q)${MAKE} gen_code_input -s
else
	$(Q)${MAKE} gen_code_input
endif
else
ifeq (_$(Q)_,_@_)
	$(Q)echo -e "	[GEN_CODE $(GEN_CODE_SCRIPT)]	$(shell pwd)/$(GEN_CODE_SCRIPT)"
endif
ifeq (_$(AUTO_CLEAN_GEN_CODE)_,_1_)
	$(Q)ls > .$(1).genfile1.$$$$$$$$; \
	$(GEN_CODE_SCRIPT) $(GEN_CODE_SCRIPT_ARGS); \
	ls > .$(1).genfile2.$$$$$$$$; \
	cat .$(1).genfile2.$$$$$$$$ | grep -v "`cat .$(1).genfile1.$$$$$$$$`" >> .$(1).genfile; \
	rm -rf .$(1).genfile1.$$$$$$$$ .$(1).genfile2.$$$$$$$$
else
	$(Q)$(GEN_CODE_SCRIPT) $(GEN_CODE_SCRIPT_ARGS)
endif
endif
	$(Q)cp --preserve=timestamp $(1) .$(1).last
endef

# All define expend use foreach function and these is the real rule in makefile (That's why we have no implicit rule)

$(foreach file,$(LFILE),$(eval $(call COMPILE_L_template,$(file),$(file).c)))

$(foreach file,$(YFILE),$(eval $(call COMPILE_Y_template,$(file),$(file).c)))

$(foreach file,$(ASFILE),$(eval $(call COMPILE_AS_template,$(file),$(addprefix $(OBJ_TEMP_DIR)/,$(basename $(file)).os))))

$(foreach file,$(CFILE),$(eval $(call COMPILE_C_template,$(file),$(addprefix $(OBJ_TEMP_DIR)/,$(basename $(file)).o))))

$(foreach file,$(CXXFILE),$(eval $(call COMPILE_CXX_template,$(file),$(addprefix $(OBJ_TEMP_DIR)/,$(basename $(file)).oo))))

$(foreach mod,$(DEP_DIR),$(eval $(call COMPILE_DEP_DIR_template,$(mod),$(mod)/_$(mod).o_mod)))

$(foreach d,$(SUBDIR),$(eval $(call COMPILE_SUBDIR_template,$(d))))

$(foreach lib,$(DEP_LIBS),$(eval $(call COMPILE_CHECK_DEP_LIBS_template,$(lib))))

$(foreach gen_code,$(GEN_CODE_INPUT),$(eval $(call COMPILE_GEN_CODE_template,$(gen_code))))

$(foreach gen_code_script,$(wildcard $(notdir $(GEN_CODE_SCRIPT))),$(eval $(call COMPILE_GEN_CODE_SCRIPT_template,$(gen_code_script),$(GEN_CODE_INPUT))))

# Main target link rule generate $(TARGET_FILENAME) file in current directory and depend its libs and 
# all its obj file.
$(TARGET_FILENAME): $(OBJS_LIST)
ifneq (_$(OBJS_LIST)_,__)
ifeq (_$(filter top bin obj static-lib dyn-lib,$(BUILD_TYPE))_,__)
	$(error Unkown build type: $(BUILD_TYPE))
endif
ifeq (_$(filter bin,$(BUILD_TYPE))_,_bin_)
ifeq (_$(Q)_,_@_)
	@echo -e "	[LD]	$(dir $(shell pwd))$(TARGET_FILENAME_BIN)"
endif
	$(Q)$(LD) $(OBJS_LIST) -o $(TARGET_FILENAME_BIN) $(CFLAGS) $(LDFLAGS) $(LIBS) $(LIBPATH)
endif 
ifeq (_$(filter obj,$(BUILD_TYPE))_,_obj_)
ifeq (_$(Q)_,_@_)
	@echo -e "	[LO]	$(dir $(shell pwd))$(TARGET_FILENAME_OBJ)"
endif
	$(Q)$(LO) $(OBJS_LIST) -nostdlib -r -o $(TARGET_FILENAME_OBJ) $(CFLAGS)
endif
ifeq (_$(filter static-lib,$(BUILD_TYPE))_,_static-lib_)
ifeq (_$(Q)_,_@_)
	@echo -e "	[AR]	$(dir $(shell pwd))$(TARGET_FILENAME_SLIB)"
endif
	$(Q)$(AR) $(ARFLAGS) $(TARGET_FILENAME_SLIB) $(OBJS_LIST)
endif 
ifeq (_$(filter dyn-lib,$(BUILD_TYPE))_,_dyn-lib_)
ifeq (_$(Q)_,_@_)
	@echo -e "	[LD]	$(dir $(shell pwd))$(TARGET_FILENAME_DLIB)"
endif
	$(Q)$(LD) $(OBJS_LIST) $(CFLAGS) $(LDFLAGS) $(LIBS) $(LIBPATH) -shared -Wl,-soname,$(TARGET).so -o $(TARGET_FILENAME_DLIB)
endif
endif

# Depend lib build procedure 
.PHONY: depend
depend: $(addprefix depcheck_,$(DEP_LIBS))

# generate code procedure
.PHONY: gen_code
gen_code: $(CFILE) $(addprefix .,$(addsuffix .last,$(wildcard $(notdir $(GEN_CODE_SCRIPT))))) $(addprefix .,$(addsuffix .last,$(GEN_CODE_INPUT)))

.PHONY: gen_code_input
gen_code_input: $(addprefix .,$(addsuffix .last,$(GEN_CODE_INPUT)))

# Sub directory build procedure
.PHONY: subdir
subdir: $(addsuffix _dir,$(SUBDIR))

# Depend directory build procedure
.PHONY: depdir
depdir: $(foreach mod,$(DEP_DIR),$(mod)/_$(mod).o_mod)

# Main build procedure
.PHONY: build
build: subdir depdir $(TARGET_FILENAME)

# Sub directory clean procedure 
# Include clean for SUBDIR DEP_DIR and DEP_LIBS
.PHONY: subdir_clean
subdir_clean:
ifneq (_$(SUBDIR)_,__)
ifeq (_$(Q)_,_@_)
	$(Q)for d in $(SUBDIR); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} clean -s -C $$d; \
	done
else
	$(Q)for d in $(SUBDIR); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} clean -C $$d; \
	done
endif
endif
ifneq (_$(DEP_DIR)_,__)
ifeq (_$(Q)_,_@_)
	$(Q)for d in $(DEP_DIR); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} clean -s -C $$d; \
	done
else
	$(Q)for d in $(DEP_DIR); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} clean -C $$d; \
	done
endif
endif
ifneq (_$(DEP_LIBS)_,__)
ifeq (_$(Q)_,_@_)
	$(Q)for d in $(DEP_LIBS); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} clean -s -C $$(dirname $$d); \
	done
else
	$(Q)for d in $(DEP_LIBS); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} clean -C $$(dirname $$d); \
	done
endif
endif

# Clean generate file procedure 
# Include clean generate code by lex yacc and custom code generate
.PHONY: clean_generate_file
clean_generate_file:
ifneq (_$(BUILD_TYPE)_,_top_)
ifneq (_$(LFILE)_,__)
	$(Q)-for f in $(LFILE); do \
		rm -rf $$f.c $$f.h; \
	done
endif
ifneq (_$(YFILE)_,__)
	$(Q)-for f in $(YFILE); do \
		rm -rf $$f.c $$f.h; \
	done
endif
ifneq (_$(GEN_CODE_SCRIPT)_,__)
ifeq (_$(AUTO_CLEAN_GEN_CODE)_,_1_)
	$(Q)-for f in $(GEN_CODE_INPUT); do \
		if [ -e $$f ]; then \
			if [ -e .$$f.genfile ]; then \
				rm -rf `cat .$$f.genfile`; \
				rm -rf .$$f.genfile; \
			fi; \
			rm -rf .$$f.last; \
		fi \
	done; \
	if [ -e .$(notdir $(firstword $(GEN_CODE_SCRIPT))).genfile ]; then \
		rm -rf `cat .$(notdir $(firstword $(GEN_CODE_SCRIPT))).genfile`; \
		rm -rf .$(notdir $(firstword $(GEN_CODE_SCRIPT))).genfile; \
	fi 
else
	$(Q)-for f in $(GEN_CODE_INPUT); do \
		if [ -e $$f ]; then \
			rm -rf .$$f.last; \
		fi \
	done
endif
	$(Q)-for f in $(notdir $(GEN_CODE_SCRIPT)); do \
		if [ -e $$f ]; then \
			rm -rf .$$f.last; \
		fi \
	done
endif
endif

# Main clean procedure
# Clean current directory file.
# Include target file, all middle obj files, all depend files and directorys
.PHONY: real_clean
real_clean: clean_generate_file subdir_clean
ifneq (_$(BUILD_TYPE)_,_top_)
	$(Q)-rm -rf $(TARGET_FILENAME)
ifeq (_$(OBJ_TEMP_DIR)_,_._)
	$(Q)-rm -rf $(addprefix $(OBJ_TEMP_DIR)/,*.o *.oo)
else
	$(Q)-rm -rf $(OBJ_TEMP_DIR)
endif
ifeq (_$(DEP_TEMP_DIR)_,_._)
	$(Q)-rm -rf $(addprefix $(DEP_TEMP_DIR)/,*.d *.dxx)
else
	$(Q)-rm -rf $(DEP_TEMP_DIR)
endif
endif
ifeq (_$(TOPDIR)_,_._)
	$(Q)-rm -rf $(BIN_INSTALL_DIR) $(LIB_INSTALL_DIR)
endif
ifneq (_$(CLEAN_SCRIPT)_,__)
	$(Q)$(CLEAN_SCRIPT)
endif

# Warp clean procedure for print infomation
.PHONY: clean
clean:
	$(Q)echo -e "Cleaning $(shell pwd)/"
ifeq (_$(Q)_,_@_)
	$(Q)${MAKE} real_clean -s
else
	$(Q)$(MAKE) real_clean
endif

# Copy the target file to install directory
# Prepare the install directory here.
.PHONY: copy_target
copy_target: 
ifneq (_$(BUILD_TYPE)_,_top_)
	$(Q)$(shell if [ ! -d $(BIN_INSTALL_DIR) ]; then \
		mkdir -p $(BIN_INSTALL_DIR); \
	fi)
	$(Q)$(shell if [ ! -d $(LIB_INSTALL_DIR) ]; then \
		mkdir -p $(LIB_INSTALL_DIR); \
	fi)
ifeq (_$(filter bin,$(BUILD_TYPE))_,_bin_)
ifeq (_$(Q)_,_@_)
	@echo -e "Copying $(TARGET_FILENAME_BIN) to $(BIN_INSTALL_DIR)"
endif
	$(Q)cp $(TARGET_FILENAME_BIN) $(BIN_INSTALL_DIR)
endif
ifeq (_$(filter static-lib,$(BUILD_TYPE))_,_static-lib_) 
ifeq (_$(Q)_,_@_)
	@echo -e "Copying $(TARGET_FILENAME_SLIB) to $(LIB_INSTALL_DIR)"
endif
	$(Q)cp $(TARGET_FILENAME_SLIB) $(LIB_INSTALL_DIR)
endif
ifeq (_$(filter dyn-lib,$(BUILD_TYPE))_,_dyn-lib_) 
ifeq (_$(Q)_,_@_)
	@echo -e "Copying $(TARGET_FILENAME_DLIB) to $(LIB_INSTALL_DIR)"
endif
	$(Q)cp $(TARGET_FILENAME_DLIB) $(LIB_INSTALL_DIR)
endif
endif

# Strip target file need copy target first
# Here we can choose how to strip files by set up the 
# STRIP_BIN and STRIP_LIB variablem.
# And also we can enable DEBUG_NOT_STRIP to avoid strip
# in debug mode.
.PHONY: strip
strip: copy_target
ifneq (_$(BUILD_TYPE)_,_top_)
ifneq (_$(DEBUG)_,_1_)
ifeq (_$(STRIP_BIN)_,_1_)
ifeq (_$(filter bin,$(BUILD_TYPE))_,_bin_)
ifeq (_$(Q)_,_@_)
	@echo -e "Striping $(BIN_INSTALL_DIR)/$(TARGET_FILENAME_BIN)"
endif
	$(Q)$(STRIP) $(STRIP_FLAGS) $(BIN_INSTALL_DIR)/$(TARGET_FILENAME_BIN)
endif
endif
ifeq (_$(STRIP_LIB)_,_1_)
ifeq (_$(filter static-lib,$(BUILD_TYPE))_,_static-lib_) 
ifeq (_$(Q)_,_@_)
	@echo -e "Striping $(LIB_INSTALL_DIR)/$(TARGET_FILENAME_SLIB)"
endif
	$(Q)$(STRIP) --strip-unneeded $(STRIP_FLAGS) $(LIB_INSTALL_DIR)/$(TARGET_FILENAME_SLIB)
endif
ifeq (_$(filter dyn-lib,$(BUILD_TYPE))_,_dyn-lib_) 
ifeq (_$(Q)_,_@_)
	@echo -e "Striping $(LIB_INSTALL_DIR)/$(TARGET_FILENAME_DLIB)"
endif
	$(Q)$(STRIP) $(STRIP_FLAGS) $(LIB_INSTALL_DIR)/$(TARGET_FILENAME_DLIB)
endif
endif
endif
else
ifeq (_$(STRIP_BIN)_,_1_)
ifeq (_$(filter bin,$(BUILD_TYPE))_,_bin_)
ifeq (_$(Q)_,_@_)
	@echo -e "Striping $(BIN_INSTALL_DIR)/$(TARGET_FILENAME_BIN)"
endif
	$(Q)$(STRIP) $(STRIP_FLAGS) $(BIN_INSTALL_DIR)/$(TARGET_FILENAME_BIN)
endif
endif
ifeq (_$(STRIP_LIB)_,_1_)
ifeq (_$(filter static-lib,$(BUILD_TYPE))_,_static-lib_) 
ifeq (_$(Q)_,_@_)
	@echo -e "Striping $(LIB_INSTALL_DIR)/$(TARGET_FILENAME_SLIB)"
endif
	$(Q)$(STRIP) --strip-unneeded $(STRIP_FLAGS) $(LIB_INSTALL_DIR)/$(TARGET_FILENAME_SLIB)
endif
ifeq (_$(filter dyn-lib,$(BUILD_TYPE))_,_dyn-lib_) 
ifeq (_$(Q)_,_@_)
	@echo -e "Striping $(LIB_INSTALL_DIR)/$(TARGET_FILENAME_DLIB)"
endif
	$(Q)$(STRIP) $(STRIP_FLAGS) $(LIB_INSTALL_DIR)/$(TARGET_FILENAME_DLIB)
endif
endif
endif

# Sub directory's install procedure
.PHONY: subdir_install
subdir_install:
ifneq (_$(SUBDIR)_,__)
ifeq (_$(Q)_,_@_)
	$(Q)for d in $(SUBDIR); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} install -s -C $$d; \
	done
else
	$(Q)for d in $(SUBDIR); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} install -C $$d; \
	done
endif
endif
ifneq (_$(DEP_DIR)_,__)
ifeq (_$(Q)_,_@_)
	$(Q)for d in $(DEP_DIR); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} install -s -C $$d; \
	done;
else
	$(Q)for d in $(DEP_DIR); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} install -C $$d; \
	done
endif
endif
ifneq (_$(DEP_LIBS)_,__)
ifeq (_$(Q)_,_@_)
	for d in $(DEP_LIBS); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} install -s -C $$(dirname $$d); \
	done
else
	for d in $(DEP_LIBS); do \
		export LIB_DEPEND_SOURCE="$(LIB_DEPEND_SOURCE)"; \
		${MAKE} install -C $$(dirname $$d); \
	done
endif
endif

# Main install procedure
# Obj file needn't install
.PHONY: real_install
ifneq (_$(BUILD_TYPE)_,_obj_)
real_install: subdir_install
ifeq (_$(Q)_,_@_)
	$(Q)make -s strip
else
	$(Q)make strip
endif
else
real_install: subdir_install
endif

# Warp install procedure for display information
.PHONY: install
install:
ifeq (_$(Q)_,_@_)
ifeq (_$(BUILD_TYPE)_,_top_)
	$(Q)echo -e "Installing $(shell pwd)" 
else
	$(Q)echo -e "Installing $(shell pwd)/$(TARGET_FILENAME)" 
endif
	$(Q)${MAKE} -s real_install
else
	$(Q)${MAKE} real_install
endif

# Here if you need custom your makefile we not recommand you modify the rule.mk file 
# directly, please add the custom makefile in SELF_DEF_MAKEFILE and here we will include
# it. You can override the main procedure by yourself. Because here is lower than any main
# procedure your custom makefile will finnally be valid.
ifneq (_$(SELF_DEF_MAKEFILE)_,__)
include $(SELF_DEF_MAKEFILE)
endif
