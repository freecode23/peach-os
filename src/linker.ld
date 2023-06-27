/* Our kernel will be compiled with this linker script */
/* when we link our object files together, it will ensure to have the origin at 1MB*/
ENTRY(_start) 

/* output of the kernel.asm file */
OUTPUT_FORMAT(binary)

SECTIONS
{   
    /* kernel will be loaded into address 1MBth memory */
    .= 1M; 
    .text:
    {
        *(.text)
    }

    .rodata:
    {
        *(.rodata)
    }
    
    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(COMMON)
        *(.bss)
    }
}