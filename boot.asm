; 1. tell assembler to originate from this address
ORG 0x7c00

; 2. use 16 bit architescture
BITS 16

start: 
    ; reference: http://www.ctyme.com/intr/rb-0106.htm
    mov ah, 0eh ; ah is just eax move the value 0eh. 0eh is the command to print to terminal
    mov al, 'A' ;  the character we are printing
    int 0x10 ; calling the bios routine , to output the character A to the terminal
    

    jmp $ ; keep jumping to not execute our signature

; 3. we need to fill 510 bytes of data, pad the rest with 0s

; -> times is a directive for repeating an instruction a certain number of times.

; -> 510-($-$$) is calculating the number of bytes left in the 512-byte boot sector.
; 510 is the total number of bytes needed for the bootloader to work.
; The bootloader should be exactly 512 bytes,
; but the last two bytes are reserved for the boot signature (0xAA55),
; so we only have 510 bytes for our code and data.

; -> $ refers to the memory address at that point in the code, after all the preceding code has been processed.

; -> $$ represents the memory address where the section began.
; So $-$$ gives you the number of bytes from the start of this code section to the current position,
; and 510-($-$$) gives you the number of bytes left to reach 510 bytes.
; db 0 is defining a byte of value 0. db stands for "define byte",
; it's a directive used to declare one or more bytes and initialize them with the provided values.
times 510-($-$$) db 0 


; -> dw (define word) will put 0xAA55 straight into our files
dw 0xAA55 ; little endian actually 55AA

; 4. now install qemu, and nasm
; NASM, or the Netwide Assembler, is an assembler and disassembler
; for the Intel x86 architecture. It can be used to write bootloaders, 
; create executables, or even to write operating systems.
; sudo apt install nasm
; sudo apt install qemu-system-x86

; 5. test run qemu:
; qemu-system-x86_64


; 6. then assemble to raw binary output:
; nasm -f bin ./boot.asm -o ./boot.bin


; 7. run the bootloader in our emulator
; hda means hard drive
; qemu-system-x86_64 -hda ./boot.bin