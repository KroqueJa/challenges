
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

          cmp       rbx, 88
          je        lose
          cmp       rbx, 89
          je        draw

win:
          add       rdi, 6
          cmp       rax, 65
          je        i_played_paper
          cmp       rax, 66
          je        i_played_scissors
          jmp       i_played_rock
draw:
          add       rdi, 3

          cmp       rax, 65
          je        i_played_rock
          cmp       rax, 66
          je        i_played_paper
          jmp       i_played_scissors
lose:
          cmp       rax, 66
          je        i_played_rock
          cmp       rax, 67
          je        i_played_paper
i_played_scissors:
          add       rdi, 3
          jmp       done

i_played_paper:
          add       rdi, 2
          jmp       done

i_played_rock:
          inc       rdi

done:
          add       rcx, 4
          cmp       rcx, rsi
          jl        loop


          call      uprintln

          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall
