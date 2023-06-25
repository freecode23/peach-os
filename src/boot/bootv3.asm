; boot loader program. load messages.txt to qemu memory and print it to terminal
; 1. to make into binary: nasm -f bin ./boot.asm -o ./boot.bin
; 2. to run in qemu: qemu-system-x86_64 -hda ./boot.bin
; A) set offset and bits
ORG 0
BITS 16

; B) fake BIOS Parameter block
_start:
    jmp short start ; jumps to start label
    nop

times 33 db 0 ; directives 33 bytes after, so if BIOS starts overriding values, it will override these 0 values


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

    ; AH = 02h
    ; AL = number of sectors to read (must be nonzero)
    ; CH = low eight bits of cylinder number
    ; CL = sector number 1-63 (bits 0-5)
    ; high two bits of cylinder (bits 6-7, hard disk only)
    ; DH = head number
    ; DL = drive number (bit 7 set for hard disk)
    ; ES:BX -> data buffer

    ; Return:
    ; CF set on error
    ; if AH = 11h (corrected ECC error), AL = burst length
    ; CF clear if successful
    ; AH = status (see #00234)
    ; AL = number of sectors transferred (only valid if CF set for some
    ; BIOSes)


    ; 4. Do interrupt 13 to read sectors (message.txt) into memory
    mov ah, 2 ; read sector command
    mov al, 1 ; reading 1 sector
    mov ch, 0 ; cylinder low 8 bits
    mov cl, 2 ; read sector 2 (the first sector is our code)
    mov dh, 0 ; head
    ; load the address of buffer into the bx register. so we can refer to this when we want to print
    mov bx, buffer; the memory offset from es. where the data will be writted in qemu memory interrupt will read this bx register

    ; 5. 
    ; dont need to set dl, its already set for it
    ; we already set es (extra segment to 0x7c0)
    int 0x13 ;invoke interrupt, move data into the buffer
    jc error ; jump carry error. if the carry flag is set.it will goto terror

    ; 5. at this point our message.txt has been loaded to the memory pointed by bx
    ; now point si also to the address of buffer
    mov si, buffer 
    call print
    
    jmp $ ;infinit jump
error:
    mov si, error_message
    call print
    jmp $

; E) the print function
print: 
    mov bx, 0

; the loop below keep loading a byte from mem location pointed to by 
; the si register (starts at 'H') into the al register
; it will increment the si pointer
.loop:
    ; 2.1 load string byte from memory pointed by si to al (load the actual argument argument)
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

; G) 
error_message: db 'Failed to load sector'

; H) pad 0 if we dont use all the 510
times 510-($-$$) db 0 

dw 0xAA55

buffer: