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
          ASCII_CAPS    equ 97

          section   .bss
file_buf:
          resb      FSIZE

letter_counts:
          resb      27

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
          mov       rdi, file_buf

          xor       rax, rax
          xor       rbx, rbx
          xor       rdx, rdx
outer_loop:
          xor       rcx, rcx
loop:
          mov       al, Byte [rdi + rcx]
          sub       rax, ASCII_CAPS
          mov       bl, Byte [letter_counts + rax]
          inc       rbx
          mov       Byte [letter_counts + rax], bl
          inc       rcx
          cmp       rcx, 14
          jne       loop
window_finished:
          xor       rcx, rcx
          inc       rdi

check_loop:
          cmp       Byte [letter_counts + rcx], 0x1
          jg        dupe
          inc       rcx
          cmp       rcx, 26
          jne       check_loop
          jmp       done
dupe:
          xor       rcx, rcx
zro_loop:
          mov       Byte [letter_counts + rcx], 0x0
          inc       rcx
          cmp       rcx, 26
          jne       zro_loop

          jmp       outer_loop

done:
          sub       rdi, file_buf
          add       rdi, 13
          call      uprintln

; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

