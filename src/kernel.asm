; F) PROTECTED MODE
[BITS 32] ; from now onwards its 32 bits code (protected mode)

; kernel code and data segment
CODE_SEG equ 0x08
DATA_SEG equ 0x10
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