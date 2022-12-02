%include  'print.asm'

; macros
          SYS_READ      equ 0
          STDOUT        equ 1
          SYS_OPEN      equ 2
          O_RDONLY      equ 0
          SYS_EXIT      equ 60
          SYS_WRITE     equ 1
          NEWLINE       equ 10
          SYS_CLOSE     equ 3
          FSIZE         equ 10500

          section   .bss
file_buf:
          resb      FSIZE

winners:
          resq      3

bytes_read:
          resq      1

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

; save the amount of bytes read
          mov       [bytes_read], rax

; close the file
          mov       rax, SYS_CLOSE
          syscall

; solve the problem
          xor       rax, rax
          xor       rbx, rbx
          xor       r9, r9                              ; r9 holds the current total value
          xor       r10, r10                            ; read register
          mov       rsi, 10
atoi_loop:
          mul       rsi
          mov       r10b, Byte [file_buf + rbx]
          add       rax, r10
          sub       rax, 48
          inc       rbx
          cmp       Byte [file_buf + rbx], NEWLINE
          jne       atoi_loop

          add       r9, rax
          xor       rax, rax
          inc       rbx
          cmp       Byte [file_buf + rbx], NEWLINE
          jne       atoi_loop

          cmp       Qword [winners+16], r9
          jge       next_elf
          cmp       Qword [winners+8], r9
          jge       new_third
          cmp       Qword [winners], r9
          jge       new_second
new_winner:
          push      Qword [winners]
          push      Qword [winners+8]
          mov       Qword [winners], r9
          pop       Qword [winners+16]
          pop       Qword [winners+8]
          jmp       next_elf
new_second:
          push      Qword [winners+8]
          mov       Qword [winners+8], r9
          pop       Qword [winners+16]
          jmp       next_elf
new_third:
          mov       Qword [winners+16], r9
next_elf:
          xor       r9, r9
          inc       rbx
          cmp       [bytes_read], rbx
          jne       atoi_loop

          mov       rdi, Qword [winners]
          add       rdi, Qword [winners+8]
          add       rdi, Qword [winners+16]
          call      uprintln

          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall
