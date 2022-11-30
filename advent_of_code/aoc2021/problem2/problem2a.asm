%include  'iolib.asm'

; define some useful macros to make the code more understandable
          SYS_READ      equ 0
          STDOUT        equ 1
          SYS_OPEN      equ 2
          O_RDONLY      equ 0
          SYS_EXIT      equ 60
          SYS_WRITE     equ 1
          NEWLINE       equ 10
          SYS_CLOSE     equ 3

          FSIZE         equ 10000

          section   .bss
file_buf:
          resb      FSIZE                         ; the input file is 9006 bytes

number_buf:
          resq      2555                          ; we could definitely be tighter with memory than using 64 bit integers

          section   .text
          global    _start

_start:

; read the filename from the command line
          pop       rcx
          pop       rdi
          pop       rdi                           ; rdi now points at the file name

; open the input file
          mov       rax, SYS_OPEN
          mov       rsi, O_RDONLY                 ; set the read-only flag
          mov       rdx, 0644o                    ; file permissions are a mystery to me

          syscall                                 ; after this syscall, the file address is in rax

; read the file into the file_buffer
          mov       rdi, rax
          mov       rax, SYS_READ
          mov       rsi, file_buf
          mov       rdx, FSIZE
          syscall

          mov       r12, rax                      ; rax holds the number of bytes read from the file; we keep track of this in r12

          mov       rax, SYS_CLOSE
          syscall                                 ; dutifully close the file

; try to solve the actual problem
          xor       rcx, rcx
          xor       rax, rax
          xor       r11, r11                      ; pos
          xor       r10, r10                      ; depth
loop:
          cmp       rcx, r12
          je        done
          mov       al, Byte [file_buf + rcx]
          cmp       rax, 102
          je        forward
          cmp       rax, 100
          je        down
          cmp       rax, 117
up:
          mov       al, Byte [file_buf + rcx + 3]
          sub       r10, rax
          add       r10, 48
          add       rcx, 5
          jmp       loop
down:
          mov       al, Byte [file_buf + rcx + 5] 
          add       r10, rax
          sub       r10, 48
          add       rcx, 7
          jmp       loop
forward:
          mov       al, Byte [file_buf + rcx + 8] 
          add       r11, rax
          sub       r11, 48
          add       rcx, 10
          jmp       loop
          sub       r11, 48

done:

          mov       rax, r10
          mul       r11
          mov       rdi, rax
          call      uprintln
          call      exit_0
