# microkernel
Microkernel, 16bit real mode ASM based bootloader/shell.
# how to compile
```
nasm -f bin kernel.asm -o kernel.bin
qemu-system-x86_64 -drive format=raw,file=bootshell.bin
```
You NEED qemu for emulating it.
