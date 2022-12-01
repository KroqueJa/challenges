%include  'iolib.asm'

; macros
          SYS_READ      equ 0
          STDOUT        equ 1
          SYS_OPEN      equ 2
          O_RDONLY      equ 0
          SYS_EXIT      equ 60
          SYS_WRITE     equ 1
          NEWLINE       equ 10
          SYS_CLOSE     equ 3

          section   .bss
file_buf:
          resb      30000

buckets:
          resq      20                ; 20 is max width of bit fields

field_width:
          resq      1                 ; gotta start putting variables in memory

fields_num:
          resq      1                 ; is this overdoing it?


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
          mov       rdx, 30000
          syscall

          push      rax

          xor       rcx, rcx
count_loop:
          mov       al, Byte [file_buf + rcx]
          inc       rcx
          cmp       Byte [file_buf + rcx], 0xA
          jne       count_loop

          mov       [field_width], rcx

          pop       r8                                ; number of bytes read
          mov       rax, r8
          inc       rcx
          xor       rdx, rdx
          idiv      rcx
          mov       [fields_num], rax

          mov       rax, SYS_CLOSE
          syscall

          xor       rbx, rbx
          xor       rcx, rcx
          xor       rdx, rdx

loop:
          mov       al, Byte [file_buf + rbx + rcx]
          cmp       rax, 0xA
          je        skip
          add       [buckets + rdx], rax
          inc       rcx
          add       rdx, 8
          jne       loop
          jmp       done
skip:
          inc       rcx
          add       rbx, rcx
          cmp       rbx, r8
          je        done
          xor       rcx, rcx
          xor       rdx, rdx
          jmp       loop

done:
          xor       r12, r12                    ; we will try to construct the number in r12
          mov       rax, Qword [fields_num]
          xor       rdx, rdx
          div       2
          mov       r11, rax                    ; in r11 we store half the number of fields
          xor       rcx, rcx
          mov       rbx, Qword [field_width]

div_loop:
          mov       rax, Qword [buckets]
          xor       rdx, rdx
          mov       rsi, Qword [fields_num]
          div       rsi
          call      exit_0
