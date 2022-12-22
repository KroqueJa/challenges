; function to print a newline
br:
          push      rdi
          push      rsi
          push      rax
          push      rcx
          push      rdx

          mov       rax, 0xA
          push      rax                               ; put a newline on the stack
          mov       rsi, rsp                          ; move the stack pointer to rsi
          mov       rax, 1                            ; SYS_PRINT
          mov       rdx, 1                            ; print 1 byte
          mov       rdi, 1                            ; STDOUT
          syscall

          pop       rax                               ; TODO: move stack pointer instead, but WITH PRECISION
          pop       rdx
          pop       rcx
          pop       rax
          pop       rsi
          pop       rdi
          ret

; function to print an unsigned integer and a newline
uprintln:
          call      uprint
          call      br
          ret

; function to print an unsigned integer
uprint:
          push      rdi
          push      rax
          push      rcx
          push      rdx
          push      rsi

          xor       r8, r8
          mov       rax, rdi
.rd_loop:
          inc       r8
          mov       rsi, 10
          xor       rdx, rdx
          idiv      rsi
          add       rdx, 48
          push      rdx

          cmp       rax, 0
          jne       .rd_loop

.prt_loop:
          mov       rsi, rsp
          mov       rdi, 1                            ; STDOUT
          mov       rax, 1                            ; SYS_PRINT
          mov       rdx, 1                            ; print 1 byte
          syscall
          pop       r9
          dec       r8
          cmp       r8, 0
          je        .prt_done
          jmp       .prt_loop

.prt_done:
          pop       rsi
          pop       rdx
          pop       rcx
          pop       rax
          pop       rdi
          ret
