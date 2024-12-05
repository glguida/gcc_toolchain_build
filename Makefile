PWD:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SRCROOT=$(PWD)
MKDIR=$(SRCROOT)/mk
include $(MKDIR)/mk.conf
TOOLDIR= $(SRCROOT)

do_help: help

MAKEOPT?=-j4
FTP?= curl -O


TOOLBUILDDIR?= $(TOOLDIR)/build
INSTALLDIR?= $(SRCROOT)/install

BINUTILS= binutils-2.43.1
GMP= gmp-6.2.1
MPC= mpc-1.2.1
MPFR= mpfr-4.2.1
GCC= gcc-14.2.0

GCC_CONFIGURE_OPTS=					\
			--prefix $(INSTALLDIR) 	\
			--target=$(BUILD_TARGET)	\
			--enable-languages=c		\
			--disable-nls			\
			--disable-libs			\
			--disable-libssp		\
			--disable-libquadmath		\
			--without-headers		\
			--with-build-sysroot=$(TOOLBUILDDIR) \
			--enable-targets=all		\
			--disable-libctf 		\
			--disable-install-libbfd




EXTS += $(BINUTILS) $(GMP) $(MPFR) $(MPC) $(GCC) $(NEWLIB)

.PHONY: help gmp mpfr mpc binutils gcc install compile populate
ALL_TARGET+= help

help:
	@echo
	@echo "This is the GCC Toolchain Compiler."
	@echo
	@echo "Run 'make populate' to download the required sources."
	@echo "Run 'make <triplet>-gcc' to compile a gcc for the required platform.."
	@echo
	@echo "Compiled binaries will be installed in INSTALLDIR, which defaults to"
	@echo
	@echo "     $(INSTALLDIR)"
	@echo
	@echo "Examples:"
	@echo
	@echo "   $$ make populate"
	@echo "   $$ make riscv64-unknown-elf-gcc"
	@echo "   $$ make i686-unknown-elf-gcc"
	@echo

$(EXTSDIR)/$(GMP).tar.bz2:
	(cd $(EXTSDIR); $(FTP) ftp://ftp.gnu.org/pub/gnu/gmp/$(GMP).tar.bz2 )

$(EXTSDIR)/$(MPFR).tar.bz2:
	(cd $(EXTSDIR); $(FTP) ftp://ftp.gnu.org/pub/gnu/mpfr/$(MPFR).tar.bz2 )

$(EXTSDIR)/$(MPC).tar.gz:
	(cd $(EXTSDIR); $(FTP) ftp://ftp.gnu.org/pub/gnu/mpc/$(MPC).tar.gz )

$(EXTSDIR)/$(BINUTILS).tar.bz2:
	(cd $(EXTSDIR); $(FTP) ftp://ftp.gnu.org/pub/gnu/binutils/$(BINUTILS).tar.bz2)

$(EXTSDIR)/$(GCC).tar.gz:
	(cd $(EXTSDIR); $(FTP) ftp://ftp.gnu.org/pub/gnu/gcc/$(GCC)/$(GCC).tar.gz)

.PHONY: populate
populate: $(EXTSDIR)/$(GMP).tar.bz2 \
          $(EXTSDIR)/$(MPFR).tar.bz2 \
          $(EXTSDIR)/$(MPC).tar.gz \
          $(EXTSDIR)/$(BINUTILS).tar.bz2 \
          $(EXTSDIR)/$(GCC).tar.gz \
	  | externals prepare_gcc
	@echo "All good."

.PHONY: prepare_gcc
prepare_gcc:
	-ln -s $(EXTSDIR)/$(MPFR) $(EXTSDIR)/$(GCC)/mpfr
	-ln -s $(EXTSDIR)/$(MPC) $(EXTSDIR)/$(GCC)/mpc
	-ln -s $(EXTSDIR)/$(GMP) $(EXTSDIR)/$(GCC)/gmp
	-for i in $(EXTSDIR)/$(BINUTILS)/*/; do \
		(cd $(EXTSDIR)/$(GCC); ln -s $$i); \
	done

riscv64-%-gcc: ARCH_CONFIGURE=CFLAGS_FOR_TARGET="-g -O2 -mcmodel=medany"
%-gcc: BUILD_TARGET = $(subst -gcc,,$@)
%-gcc: populate
	mkdir -p $(TOOLBUILDDIR)/$(BUILD_TARGET)/gcc;
	(cd $(TOOLBUILDDIR)/$(BUILD_TARGET)/gcc; $(EXTSDIR)/$(GCC)/configure $(GCC_CONFIGURE_OPTS) $(ARCH_CONFIGURE))
	$(MAKE) $(MAKEOPT) -C $(TOOLBUILDDIR)/$(BUILD_TARGET)/gcc
	$(MAKE) $(MAKEOPT) -C $(TOOLBUILDDIR)/$(BUILD_TARGET)/gcc install

.PHONY: toolchains toolchain_amd64 toolchain_i686 toolchain_riscv64 toolchain_riscv32

clean_build:
	-rm -rf build

CLEAN_TARGET+= clean_build

include $(MKDIR)/exts.mk
include $(MKDIR)/def.mk
