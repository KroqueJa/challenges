%include 'print.asm'

; macros
          SYS_READ      equ 0
          STDOUT        equ 1
          SYS_OPEN      equ 2
          O_RDONLY      equ 0
          SYS_EXIT      equ 60
          SYS_WRITE     equ 1
          NEWLINE       equ 10
          SYS_CLOSE     equ 3
          FSIZE         equ 11500

          section   .bss
file_buf:
          resb      FSIZE

          section   .text
          global    _start

_start:

; read the filename from the command line
          pop       rcx
          pop       rdi
          pop       rdi

; open the input file
          mov       rax, SYS_OPEN
          mov       rsi, O_RDONLY
          mov       rdx, 0644o
          syscall

; read the file into the file_buffer
          mov       rdi, rax
          mov       rax, SYS_READ
          mov       rsi, file_buf
          mov       rdx, FSIZE
          syscall

; close the file
          mov       rax, SYS_CLOSE
          syscall

; solve the problem
          xor       rax, rax
          xor       rbx, rbx
          xor       rcx, rcx
          xor       rdx, rdx
          mov       rdi, file_buf
loop:
          mov       al, Byte [rdi]
          mov       bl, Byte [rdi+1]
          mov       cl, Byte [rdi+2]
          mov       dl, Byte [rdi+3]

          cmp       rcx, rdx
          je        jump_three
          cmp       rbx, rcx
          je        jump_two
          cmp       rbx, rdx
          je        jump_two
          cmp       rax, rbx
          je        jump_one
          cmp       rax, rcx
          je        jump_one
          cmp       rax, rdx
          je        jump_one
          jmp       done

jump_three:
          add       rdi, 3
          jmp       loop
jump_two:
          add       rdi, 2
          jmp       loop
jump_one:
          inc       rdi
          jmp       loop
done:
          sub       rdi, file_buf
          add       rdi, 4                  ; 3 because we're at the beginning of the interval, 1 because the problem is 1-indexed
          call      uprintln


; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

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
