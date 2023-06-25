; boot loader program. load messages.txt to qemu memory and print it to terminal
; 1. to make into binary: nasm -f bin ./boot.asm -o ./boot.bin
; 2. to run in qemu: qemu-system-x86_64 -hda ./boot.bin
; A) set offset and bits
ORG 0x7c00
BITS 16

; to give offset for each descriptor entry
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; B) fake BIOS Parameter block
_start:
    jmp short start ; jumps to start label
    nop

times 33 db 0 ; directives 33 bytes after, so if BIOS starts overriding values, it will override these 0 values


; C) Set code segment to be 0x7c00
start:
    jmp 0:step2 ; jumps to step2

; D) the start function
step2: 
    ; 1. we need to clear interrupts so that no interrupt will happen during bootloading
    ; we will be changing segment registers so we dont want any hardware interreupt now
    cli ; clear interrupts

    ; 2. set data segment and extra segment register to 0x7c0
    mov ax, 0x00
    mov ds, ax
    mov es, ax

    ; 3.set stack segment to 0x00
    mov ss, ax
    mov sp, 0x7c00 ;stack pointer
    sti ; enable interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor] ; load gdt descriptor table and load the descriptors for code and data we wrote
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG: load32 ; replace CODE_SEG with offset 0x8, got to load32 and jump infiniete
    


; E) Create 5 GDT entry ( a descriptor)
gdt_start:

; E1. null segment
gdt_null:
    dd 0x0
    dd 0x0

; E2. descriptor for code segment (offset 0x8)
gdt_code: ;cs register should point to this
    dw 0xffff ; segment limit (first 0-15 bits)
    dw 0 ; base 0-15 bits
    db 0 ; base 16-23 bits
    db 0x9a ;access bytes
    db 11001111b ; high 4 bit flafgs and low 4 bit flags
    db 0 ; base 24-31 bits


; E3. descriptor for data segment (offset 0x10)
gdt_data:
    dw 0xffff ; segment limit (first 0-15 bits)
    dw 0 ; base 0-15 bits
    db 0 ; base 16-23 bits
    db 0x92 ;access bytes
    db 11001111b ; high 4 bit flafgs and low 4 bit flags
    db 0 ; base 24-31 bits

; E4. data segment (offset 0x10)
gdt_end:

gdt_descriptor:
    dw gdt_start - gdt_end -1 ; size of descriptr
    dd gdt_start ; offset

[BITS 32] ; from now onwards its 32 bits code
load32:
    mov ax, DATA_SEG ;set data registers
    mov ds, ax ; put 0x10 to ds, es, fs, gs and ss
    mov es, ax ; so they all point to 0x10 now
    mov fs, ax
    mov gs, ax 
    mov ss, ax 
    mov ebp, 0x00200000
    mov esp, ebp 
    jmp $

; I) pad 0 if we dont use all the 510
times 510-($-$$) db 0 

dw 0xAA55
