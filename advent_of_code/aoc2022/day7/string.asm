; a string library

; =============================================================================
; function to see if the string in rdi is equal to the string in rsi, both null-terminated
streq:
        push      rbx
        push      rcx
        xor       rax, rax
        xor       rbx, rbx
        xor       rcx, rcx

.cmp_loop:
        mov       al, Byte [rsi + rcx]
        mov       bl, Byte [rdi + rcx]
        inc       rcx
        cmp       rax, rbx
        jne       .false
        cmp       rax, 0
        je        .true
        jmp       .cmp_loop

.false:
        xor       rax, rax
        pop       rcx
        pop       rbx
        ret

.true:
        mov       rax, 1
        pop       rcx
        pop       rbx
        ret

; =============================================================================
; function to find if two lines, ie newline-terminated strings, are equal
; exactly identical to the above
lneq:
        push      rbx
        push      rcx
        xor       rax, rax
        xor       rbx, rbx
        xor       rcx, rcx

.cmp_loop:
        mov       al, Byte [rsi + rcx]
        mov       bl, Byte [rdi + rcx]
        inc       rcx
        cmp       rax, rbx
        jne       .false
        cmp       rax, 0xA
        je        .true
        jmp       .cmp_loop

.false:
        xor       rax, rax
        pop       rcx
        pop       rbx
        ret

.true:
        mov       rax, 1
        pop       rcx
        pop       rbx
        ret

; =============================================================================
; function to find the length of a string in rdi (including the terminator!)
strlen:
        xor       rax, rax
.len_loop:
        inc       rax                           ; should cause overflow to 0 on first iteration
        cmp       Byte [rdi+rax], 0
        jne       .len_loop

        inc       rax                           ; add one for the null terminator
        ret

; =============================================================================
; function to find the amount of bytes until the next newline
lnlen:
        xor       rax, rax
.len_loop:
        inc       rax
        cmp       Byte [rdi + rax], 0xA
        jne       .len_loop

        inc       rax
        ret

; =============================================================================
; function to copy the string in rsi to rdi
strcpy:
        push      rcx

        push      rdi
        mov       rdi, rsi
        call      strlen
        mov       rcx, rax
        pop       rdi

        rep       movsb

        pop       rcx
        ret

; =============================================================================
; function to copy string until newline from rsi into rdi, overwriting the newline itself with a null terminator
lncpy:
        push      rcx

        push      rdi
        mov       rdi, rsi
        call      lnlen
        mov       rcx, rax
        pop       rdi

        rep       movsb

        mov       Byte [rdi - 1], 0x0

        pop       rcx
        ret

