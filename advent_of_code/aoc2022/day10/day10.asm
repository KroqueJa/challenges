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
          xor       rbx, rbx                                ; input file iterator
          xor       r8, r8                                  ; our sum
          xor       rdi, rdi                                ; cycle enumerator
          mov       rsi, 0x14                               ; our first target cycle for part 1

          mov       r14, 0x1                                ; previous value of 'X' register (for when we land past a target cycle)
          mov       r15, 0x1                                ; our 'X' register (and sprite position)

; === part 2 ===


parse_loop:
          cmp       rbx, Qword [bytes_read]
          jge       done

          inc       rdi
          cmp       Byte [file_buf + rbx], 0x61             ; 'a'
          je        addx

noop:
          mov       r11, 0x0
          add       rbx, 0x5
          jmp       check

addx:
          mov       r11, 0x1
          inc       rdi
          xor       rax, rax
          mov       r12, 0xa
          add       rbx, 0x5
          xor       r13, r13
          cmp       Byte [file_buf + rbx], 0x2d               ; '-'
          jne       atoi
          mov       r13, 0x1
          inc       rbx

atoi:
          mul       r12
          add       al, Byte [file_buf + rbx]
          sub       rax, 0x30
          inc       rbx
          cmp       Byte [file_buf + rbx], 0xa
          jne       atoi

          inc       rbx

          cmp       r13, 0x1
          jne       update_x

          neg       rax

update_x:
          mov       r14, r15                                  ; update previous value of 'X'
          add       r15, rax                                  ; add the new value to 'X'

check:
          cmp       rdi, rsi
          jl        parse_loop

          mov       rax, r15

          cmp       r11, 0x1
          cmove     rax, r14

          mul       rsi
          add       r8, rax

          add       rsi, 0x28                                 ; update the target cycle
          jmp       parse_loop
done:
          mov       rdi, r8
          call      uprintln

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
