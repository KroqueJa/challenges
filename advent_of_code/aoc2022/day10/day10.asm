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

          DISPLAY_W     equ 40
          DISPLAY_H     equ 6

          section   .bss

file_buf:
          resb      FSIZE

bytes_read:
          resq      1

output_buf:
          resb      DISPLAY_W * DISPLAY_H

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

parse_loop:
          mov       r14, r15                                  ; update previous value of 'X'
          cmp       rbx, Qword [bytes_read]
          jge       done

          inc       rdi
          cmp       Byte [file_buf + rbx], 0x61             ; 'a'
          je        addx

noop:
          mov       r11, 0x1
          add       rbx, 0x5
          jmp       check

addx:
          mov       r11, 0x2
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
          add       r15, rax                                  ; add the new value to 'X'

check:
; === part 2 ===

set:
          push      rsi
          push      rdi

mod_loop:
          cmp       rdi, 40
          jl        mod_done
          sub       rdi, 40
          jmp       mod_loop

mod_done:

          mov       rsi, r15
          cmp       r11, 0x2
          cmove     rsi, r14

          mov       rdx, r11

          call      get_chars

          pop       rdi
          pop       rsi

          cmp       r11, 0x2
          jne       set_single_byte

set_two_bytes:
          bswap     eax                                       ; put the bytes in little endian order before writing them
          shr       rax, 0x10                                 ; shift the bytes right 16 bits
          mov       Word [output_buf + rdi - 2], ax           ; put two bytes into the correct place
          jmp       set_done

set_single_byte:
          mov       Byte [output_buf + rdi - 1], al

; === part 2 ===

set_done:
          cmp       rdi, rsi
          jl        parse_loop

          mov       rax, r15

          cmp       r11, 0x2
          cmove     rax, r14

          mul       rsi
          add       r8, rax

          add       rsi, 0x28                                 ; update the target cycle
          jmp       parse_loop

done:
          mov       rdi, r8
          call      uprintln

          call      br

          mov       rdi, output_buf
          call      display

          mov       rax, SYS_EXIT
          mov       rdi, 0x0
          syscall


; ===================================================================
; function to draw the output buffer in rdi
display:
          push      rax
          push      rdx
          push      rdi
          push      rsi
          push      r15

          mov       r15, rdi

          mov       rsi, r15
          mov       rdi, STDOUT
          mov       rax, SYS_WRITE
          mov       rdx, 0x28
          syscall
          call      br

          mov       rsi, r15
          add       rsi, 40
          mov       rdi, STDOUT
          mov       rax, SYS_WRITE
          mov       rdx, 0x28
          syscall
          call      br

          mov       rsi, r15
          add       rsi, 80
          mov       rdi, STDOUT
          mov       rax, SYS_WRITE
          mov       rdx, 0x28
          syscall
          call      br

          mov       rsi, r15
          add       rsi, 120
          mov       rdi, STDOUT
          mov       rax, SYS_WRITE
          mov       rdx, 0x28
          syscall
          call      br

          mov       rsi, r15
          add       rsi, 160
          mov       rdi, STDOUT
          mov       rax, SYS_WRITE
          mov       rdx, 0x28
          syscall
          call      br

          mov       rsi, r15
          add       rsi, 200
          mov       rdi, STDOUT
          mov       rax, SYS_WRITE
          mov       rdx, 0x28
          syscall
          call      br

          pop       r15
          pop       rsi
          pop       rdx
          pop       rdi
          pop       rsi
          ret


; ===================================================================
; function to produce one or two bytes in big endian order to be put into an output buffer
; inputs
; rdi: instruction number
; rsi: sprite position
; rdx: 1 or 2 (amount of bytes to get)
; outputs
; rax: one or two bytes for the output buffer (in big endian)

get_chars:

        push        rdi

        dec         rdi
        sub         rdi, rsi                        ; find difference between rdi and rsi

        cmp         rdi, 0xFFFFFFFFFFFFFFFF         ; check if the diff is -1
        jl          .dotdot                         ; if it is even less, return ..
        je          .dothash                        ; if it is exactly -1, return .#

        cmp         rdi, 0x2
        je          .hashdot

        cmp         rdi, 0x3
        jge         .dotdot

.hashhash:
        mov         rax, 0x2323
        jmp         .check

.hashdot:
        mov         rax, 0x232e
        jmp         .check

.dothash:
        mov         rax, 0x2e23
        jmp         .check

.dotdot:
        mov         rax, 0x2e2e

.check:
        cmp         rdx, 0x2
        je          .double

.single:
        and         rax, 0xFF                      ; throw away the leftmost byte

.double:

        pop         rdi
        ret


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
