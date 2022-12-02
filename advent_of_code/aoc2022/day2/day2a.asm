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
          mov       rsi, rax

; close the file
          mov       rax, SYS_CLOSE
          syscall

; solve the problem
          xor       rax, rax                    ; read register
          xor       rbx, rbx                    ; read register
          xor       rdi, rdi                    ; the current score
          xor       rcx, rcx                    ; iterator

loop:
          mov       al, Byte [file_buf+rcx]
          mov       bl, Byte [file_buf+rcx+2]

          sub       rax, rbx
          add       rax, 25                     ; 0 is a draw, 1 or 4 is a win
          sub       rbx, 87                     ; the score for my choice

          cmp       rax, 2
          je        draw
          cmp       rax, 1
          jne       lose_maybe
win:
          add       rdi, 3
draw:
          add       rdi, 3
          jmp       lose
lose_maybe:
          cmp       rax, 4
          je        win
lose:
          add       rdi, rbx
          add       rcx, 4
          cmp       rcx, rsi
          jl        loop


          call      uprintln

          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

