## PREREQUIISTES:  

gdb  
qemu
make  
nasm  

## 1. assemble the bootloader
make

## 2. load the bootloader as hard drive to qemu
qemu-system-x86_64 -hda ./boot.bin  

## 3. to check if we are in protected mode debug remotely using qemu
gdb-multiarch
target remote | qemu-system-x86_64 -hda ./boot.bin -S -gdb stdio  
press c to continue  
press ctrl + c 
layout asm
info registers


## 4. to kill qemu process after gdb session 
ps aux | grep qemu
kill <process number like 168938>

## 5. to clearn the binary files  
make clean