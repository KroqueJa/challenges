          SYS_WRITE equ 1
          SYS_EXIT  equ 60
          STDOUT    equ 1
          NEWLN     equ 10
          NULL      equ 0


; calculates the length of a string in rdi, and stores the result in rdx
strlen:

          mov       rdx, rdi

.next_char:
          cmp       byte [rdx], NULL
          jz        .count_done
          inc       rdx
          jmp       .next_char

.count_done:
          sub       rdx, rdi

          ret

; function just to print a newline
br:
          push      rax

          mov       rax, NEWLN
          push      rax

          mov       rdi, rsp
          call      sprint

          add       rsp, 8            ; increment the stack pointer to throw
                                      ; away the newline
          pop       rax

          ret

iprintln:
          call      iprint
          call      br
          ret

; prints a number residing in rdi
iprint:
          push      rdx
          push      rax
          push      rsi
          push      rbx

          mov       rbx, 0
          mov       rax, rdi

.div_loop:
          inc       rbx
          mov       rdx, 0            ; why do we need to empty rdx?
          mov       rsi, 10
          idiv      rsi
          add       rdx, 48
          push      rdx
          cmp       rax, 0
          jnz       .div_loop

.print_loop:
          dec       rbx
          mov       rdi, rsp
          call      sprint
          pop       rdi
          cmp       rbx, 0
          jnz       .print_loop

          pop       rbx
          pop       rsi
          pop       rax
          pop       rdx
          ret

sprintln:
          call      sprint
          call      br
          ret

; prints a string, whose pointer resides in rdi (according to the x86-64 calling convention)
sprint:

          push      rsi
          push      rax
          push      rdx

          call      strlen
          mov       rsi, rdi                ; move the string pointer to rax
                                            ; so we can strlen on it
          mov       rax, SYS_WRITE
          mov       rdi, STDOUT

          syscall                           ; invoke operating system to do the write

          pop       rdx
          pop       rax
          pop       rsi

          ret

exit_0:
          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

