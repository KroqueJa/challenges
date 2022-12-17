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
          FSIZE         equ 970

          section   .bss

file_buf:
          resb      FSIZE

cycles:
          resw      300

bytes_read:
          resq      1

          section   .text
          global    _start

_start:

io:
; read the filename from the command line
          pop       rcx
          pop       rsi
          pop       rsi

; read the file

          mov       rdi, file_buf
          call      read_file
          mov       Qword [bytes_read], rax

init:
          xor       rax, rax                          ; read register
          xor       rbx, rbx                          ; input file iterator (and cycle enumerator, if 1 is added to it)
          xor       rdx, rdx                          ; cycles iterator

          mov       r15, 0x1                          ; our 'X' register

parse_loop:
          cmp       Qword [bytes_read], rbx
          je        done



          cmp       Qword [file_buf + rbx], 0x61      ; 'a'
          jne       noop

          

noop:

done:


          mov       rax, SYS_EXIT
          mov       rdi, 0x0
          syscall





; ===================================================================
; function to open a file
; inputs
; rdi: buffer wherein to put the file contents
; rsi: pointer to file name
; outputs
; rax: number of bytes read
read_file:

          push        rdi
          push        rsi
          push        rdx

          push        rdi

; open the input file
          mov         rdi, rsi
          mov         rax, SYS_OPEN
          mov         rsi, O_RDONLY
          mov         rdx, 0644o
          syscall

; read the file into the file_buffer
          mov         rdi, rax
          mov         rax, SYS_READ
          pop         rsi
          mov         rdx, FSIZE
          syscall

          push        rax

; close the file
          mov         rax, SYS_CLOSE
          syscall

          pop         rax
          pop         rdx
          pop         rsi
          pop         rdi
          ret
