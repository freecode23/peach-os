; boot loader program final
; 1. to make into binary: nasm -f bin ./boot.asm -o ./boot.bin
; 2. to run in qemu: qemu-system-x86_64 -hda ./boot.bin
; A) set offset and bits
ORG 0
BITS 16

; B) fake BIOS Parameter block
_start:
    jmp short start ; jumps to start label
    nop

times 33 db 0 ; create 33 bytes after, so if BIOS starts overriding values, it will override these 0 values


; C) Set code segment to be 0x7c00
; The boot sector of a floppy disk or hard drive, where this bootloader is intended to reside,
; is loaded into memory at address 0x7C00 by the BIOS during the boot process.
; This address is chosen as a standard location that doesn't interfere with the operation of the BIOS or other hardware.
; Both the code and data segments are located at
; 0x7C00 because that is where the bootloader's code and data reside in memory.
start:
    jmp 0x7c0:step2 ; jumps to step2

; D) the start function
step2: 
    ; 1. we need to clear interrupts so that no interrupt will happen during bootloading
    ; we will be changing segment registers so we dont want any hardware interreupt now
    cli ; clear interrupts

    ; 2. set data segment and extra segment register to 0x7c0
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax

    ; 3.set stack segment to 0x00
    mov ax, 0x00 
    mov ss, ax

    mov sp, 0x7c0 ;stack pointer
    sti ; enable interrupts

    ; 4. set message to read
    ; when you move 20 to SI, the processor will calculate the actual physical address it 
    ; refers to as (ds << 4) + si, or (0x7c0 << 4) + 20 in your case.
    ; 20 from 0x7c00 is probably where our message is in memory
    mov si, message
    call print
    jmp $

; E) the print function
print: 
    mov bx, 0
; keep loading a byte from mem location pointed to by 
; the si register (starts at 'H') into the al register
; it will increment the si pointer
.loop:
    ; 2.1 load string byte from memory pointed by si to al (load the argument)
    lodsb

    ; 2.2 if al is 0, jump to done
    cmp al, 0
    je .done

    ; 2.3 else: call the print_char (which just setting up command)
    call print_char
    jmp .loop
.done:
    ret

; F) the print_char function
print_char:
    ; set up command
    mov ah, 0eh
    int 0x10
    ret

; G) variable we want to print
message: db 'Hello', 0

; H) pad 0 if we dont use all the 510
times 510-($-$$) db 0 

dw 0xAA55