; byte stacks (expand to qword stacks etc if necessary)

; function to put an item in rsi on a stack in rdi
bs_push:
          push      rax
          xor       rax, rax
          mov       al, Byte [rdi]                      ; current occupancy of stack
          mov       Byte [rdi + rax + 1], sil           ; put the item where it needs to go
          inc       rax                                 ; increment the item count
          mov       Byte [rdi], al                      ; write the new item count to the stack
          pop       rax
          ret

; function to pop an item from a stack in rsi into rax
bs_pop:
          push      rcx
          xor       rax, rax
          xor       rcx, rcx

          mov       cl, Byte [rsi]                      ; current occupancy of stack
          mov       al, Byte [rsi + rcx]                ; get the item
          dec       rcx                                 ; decrease the occupancy
          mov       Byte [rsi], cl                      ; update occupancy

          pop       rcx
          ret

; function to peek the top item on the stack
; note: works exactly like pop but does not decrease occupancy
bs_peek:
          push      rcx
          xor       rax, rax
          xor       rcx, rcx

          mov       cl, Byte [rsi]                      ; current occupancy of stack
          mov       al, Byte [rsi + rcx]                ; get the item
          mov       Byte [rsi], cl                      ; update occupancy

          pop       rcx
          ret

          ret

; function to get the size of a stack in rdi
bs_size:
          xor       rax, rax
          mov       al, Byte [rsi]
          ret

; function to print a stack in rdi
bs_print:
          push      rax
          push      rcx
          push      rdx
          push      rdi
          push      rsi

          xor       rdx, rdx

          mov       rax, 1                                ; SYS_WRITE
          mov       rsi, rdi                              ; source
          inc       rsi                                   ; +1
          mov       dl, Byte [rdi]                        ; number of bytes (start of stack)
          mov       rdi, 1                                ; STDOUT
          syscall

          pop       rsi
          pop       rdi
          pop       rdx
          pop       rcx
          pop       rax
          ret



