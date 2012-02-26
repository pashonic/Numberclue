Packages Used to Build:
nasm
gcc

Packages Used to Debug:
kdbg

Release Build Commands:
nasm -f elf64 Numberclue.asm
gcc -o Numberclue Numberclue.o

Debug Build Commands:
nasm -f elf64 -g -l Numberclue.lst Numberclue.asm
gcc -o Numberclue Numberclue.o