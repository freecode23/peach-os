; boot loader program. load messages.txt to qemu memory and print it to terminal
; 1. to make into binary: nasm -f bin ./boot.asm -o ./boot.bin
; 2. to run in qemu: qemu-system-x86_64 -hda ./boot.bin
; A) set offset and bits
ORG 0x7c00
BITS 16 ; From here onwards is realmode

; Define code segment and data segment
; to give offset for each descriptor entry
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; B) fake BIOS Parameter block
_start:
    jmp short start ; jumps to start label
    nop

; directives 33 bytes after, so if BIOS starts overriding values, it will override these 0 values
times 33 db 0 


; C) 
start:
    ; jumps to segment 0 then find step2 address
    ; set cs register from 0x7c00 + step2
    jmp 0:step2  

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
    ; 1. lgdt instruction loads the address (and size) of the GDT from memory into the GDTR, so the processor knows where to find the GDT in memory.
    lgdt[gdt_descriptor]

    ; 2. move value in cr0 to eax so we can modify the cr0 values
    mov eax, cr0 

    ; 3. This sets the least significant bit of EAX (which now holds the value of CR0) to 1.
    ;This bit is the Protection Enable (PE) bit. When set to 1, it enables Protected Mode.
    or eax, 0x1 
    
    ; 4. move back value in eax to cr0
    ; now we are in Protected mode
    mov cr0, eax

    ; 5. jump to load32, which is a part of code segment
    jmp CODE_SEG: load32 
    


; E) Init 5 GDT entry (a descriptor)
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
gdt_data: ;ds should point to this
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

; F) PROTECTED MODE
[BITS 32] ; from now onwards its 32 bits code (protected mode)
load32:
    mov ax, DATA_SEG ;set data registers
    mov ds, ax ; put 0x10 to ds, es, fs, gs and ss
    mov es, ax ; so they all point to 0x10 now
    mov fs, ax
    mov gs, ax 
    mov ss, ax 
    mov ebp, 0x00200000
    mov esp, ebp 

    ; enable A20 lines 
    in al, 0x92
    or al, 2
    out 0x92, al
    jmp $

; G) pad 0 if we dont use all the 510
times 510-($-$$) db 0 

dw 0xAA55
