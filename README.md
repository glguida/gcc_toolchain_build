# GCC Toolchain Cross Compilation Helper

This repository allows to build `binutils+gcc` for a any architecture.

At the moment no libc is compiled, so only `unknown` (i.e., no OS) are
supported.

## Usage

1. Run `make populate` to download the required sources.
2. Run `make <triplet>-gcc` to compile a gcc for the required platform..

Compiled binaries will be installed in INSTALLDIR, which defaults to 
`<source-dir>/install/`

## Examples

```
   $ make populate
   $ make riscv64-unknown-elf-gcc
   $ make i686-unknown-elf-gcc
```
