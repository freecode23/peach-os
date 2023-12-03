## PREREQUIISTES:  

gdb  
qemu
make  
nasm  

## 1. Assemble the bootloader
make

## 2. Load the bootloader as hard drive to qemu
qemu-system-x86_64 -hda ./boot.bin  

## 3. To check if we are in protected mode debug remotely using qemu. inside the bin directory:  
gdb-multiarch
target remote | qemu-system-x86_64 -hda ./boot.bin -S -gdb stdio  
press c to continue  
press ctrl + c 
layout asm
info registers


## 4. To kill qemu process after gdb session 
ps aux | grep qemu
kill <process number like 168938>

## 5. To clean the binary files  
make clean
