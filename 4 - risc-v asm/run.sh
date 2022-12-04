# Yeah... should be a Makefile

fullfile=$1
fname=$(basename $fullfile)
fbname=${fname%.*}

TOOLCHAIN_DIR=../../toolchains/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-apple-darwin/bin
LD=$TOOLCHAIN_DIR/riscv64-unknown-elf-ld
GCC=$TOOLCHAIN_DIR/riscv64-unknown-elf-gcc
ELF_RUN=$TOOLCHAIN_DIR/riscv64-unknown-elf-run

$GCC -g -o build/$fbname.bin $1 -nostdlib -static
$ELF_RUN build/$fbname.bin