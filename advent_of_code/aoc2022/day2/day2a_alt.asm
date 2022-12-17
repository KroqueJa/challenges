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
          sub       rcx, 0x4
loop:
          add       rcx, 0x4
          cmp       rcx, rsi
          je        done

          cmp       Byte [file_buf + rcx], 0x41
          je        rock
          cmp       Byte [file_buf + rcx], 0x42
          je        paper

scissors:
          cmp       Byte [file_buf + rcx + 0x2], 0x58
          je        win_rock
          cmp       Byte [file_buf + rcx + 0x2], 0x59
          je        lose_paper
          jmp       draw_scissors

paper:
          cmp       Byte [file_buf + rcx + 0x2], 0x58
          je        lose_rock
          cmp       Byte [file_buf + rcx + 0x2], 0x59
          je        draw_paper
          jmp       win_scissors

rock:
          cmp       Byte [file_buf + rcx + 0x2], 0x58
          je        draw_rock
          cmp       Byte [file_buf + rcx + 0x2], 0x59
          je        win_paper
          jmp       lose_scissors

win_rock:
          add       rdi, 0x7
          jmp       loop

draw_rock:
          add       rdi, 0x4
          jmp       loop

lose_rock:
          add       rdi, 0x1
          jmp       loop

win_paper:
          add       rdi, 0x8
          jmp       loop

draw_paper:
          add       rdi, 0x5
          jmp       loop

lose_paper:
          add       rdi, 0x2
          jmp       loop

win_scissors:
          add       rdi, 0x9
          jmp       loop

draw_scissors:
          add       rdi, 0x6
          jmp       loop

lose_scissors:
          add       rdi, 0x3
          jmp       loop


done:

          call      uprintln

          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

