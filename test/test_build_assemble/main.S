#include "main.h"

        .global main
        .text
main:
        push    %rdi
        push    %rax
        mov     $str, %rdi
        xor     %rax, %rax
        call    printf
        pop     %rax
        pop     %rdi
        ret 
str:
        .asciz  HELLO
