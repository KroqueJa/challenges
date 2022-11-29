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
          mov       r11, r12                      ; DEBUG

          mov       rax, SYS_CLOSE
          syscall                                 ; dutifully close the file

; parse all the read numbers into a buffer
          xor       rax,rax
          xor       rbx, rbx
          xor       rcx, rcx
          xor       r8, r8
          xor       r11, r11
          mov       rsi, 10

parse_loop:
          mov       bl, Byte [file_buf + rcx]
          inc       rcx
          cmp       rbx, 0xA
          je        load_num
          imul      rsi
          add       rax, rbx
          sub       rax, 48
          cmp       rcx, r12
          jne       parse_loop
load_num:
          mov       Qword [number_buf + r8], rax
          inc       r11
          xor       rax, rax
          add       r8, 8                         ; add 8 bytes to the number buffer counter
          cmp       rcx, r12
          jne       parse_loop
solve:
          mov       rcx, 8                        ; iterator
          xor       rdi, rdi                      ; output
          mov       rax, Qword [number_buf]
loop:
          mov       rbx, rax
          cmp       r11, 0
          je        done
          mov       rax, Qword [number_buf + rcx] ; current number
          add       rcx, 8
          dec       r11
          cmp       rax, rbx
          jle       loop
          inc       rdi
          jmp       loop

done:
          call      uprintln
          call      exit_0
