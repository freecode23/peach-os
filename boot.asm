ORG 0x7c00 ;offset , actually should be 0x0
BITS 16

; 1. the start function
start: 
    ; move message to si reg
    mov si, message
    call print
    jmp $

; 2. the print function
print: 
    mov bx, 0
; keep loading a byte from mem location pointed to by 
; the si register (starts at 'H') into the al register
; it will increment the si pointer
.loop:
    ; 2.1 load string byte from si to al (load the argument)
    lodsb

    ; 2.2 if al is 0, jump to done
    cmp al, 0
    je .done

    ; 2.3 else: call the print_char (which just setting up command)
    call print_char
    jmp .loop
.done:
    ret

; 3. the print_char function
print_char:
    ; set up command
    mov ah, 0eh
    int 0x10
    ret

; 4. variable we want to print
message: db 'Hello', 0

; 5. pad 0 if we dont use all the 510
times 510-($-$$) db 0 

dw 0xAA55