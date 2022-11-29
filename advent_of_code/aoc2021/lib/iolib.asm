; function to exit with exit code 0
exit_0:
          mov       rax, 60                         ; sys_exit
          mov       rdi, 0                          ; exit code 0
          syscall

; function to exit with error code
err:
          mov       rax, 60
          syscall

; function to print a newline
br:
          push      rdi
          push      rsi
          push      rax
          push      rdx

          mov       rax, 0xA
          push      rax                               ; put a newline on the stack
          mov       rsi, rsp                          ; move the stack pointer to rsi
          mov       rax, 1                            ; SYS_PRINT
          mov       rdx, 1                            ; print 1 byte
          mov       rdi, 1                            ; STDOUT
          syscall

          pop       rax
          pop       rax                               ; TODO: move stack pointer instead, but WITH PRECISION
          pop       rdx
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
          pop       rax
          pop       rdi
          ret

; function to parse an unsigned integer from text
atou:
          push      rbx
          push      rcx
          push      rsi

          xor       rax, rax
          xor       rbx, rbx
          xor       rcx, rcx
          mov       rsi, 10
.rd_loop:
          mov       bl, Byte [rdi+rcx]
          cmp       bl, 0x0
          je        .done
          sub       rbx, 48
          imul      rsi
          add       rax, rbx
          inc       rcx

          jmp       .rd_loop
.done:
          pop       rsi
          pop       rcx
          pop       rbx
          ret
