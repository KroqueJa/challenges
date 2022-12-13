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
          FSIZE         equ 9900

          WIDTH         equ 99
          LINES         equ 99

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

; store the amount of bytes read
          mov       r15, rax

; close the file
          mov       rax, SYS_CLOSE
          syscall

; === solve the problem ===
init:
          mov       rsi, file_buf
          add       rsi, WIDTH+1
          xor       rax, rax                        ; read register
          xor       rcx, rcx                        ; number of invisible trees
          xor       r13, r13                        ; max scenic score

; rather than see if a tree is visible, we're going to see if it is "covered"
; if it is covered in all directions, we count it
; any trees not counted are visible from some direction
loop:
; scenic scores for part 2
          xor       r8, r8
          xor       r9, r9
          xor       r10, r10
          xor       r11, r11

          xor       rbx, rbx                        ; count covered directions in rbx
          inc       rsi
          cmp       Byte [rsi + 1], 0xA
          jne       nonewline
          add       rsi, 3                          ; jump to the next inner tree
nonewline:
          mov       rax, rsi
          sub       rax, file_buf
          cmp       rax, r15
          jg        finished
          mov       al, Byte [rsi]

up:
          mov       rdx, rsi                        ; cast rdx upwards
up_loop:
          sub       rdx, WIDTH+1                    ; up one line
          cmp       rdx, file_buf                   ; compare with start of file buffer
          jl        down                            ; we're past the top line, go to next loop
          inc       r8                              ; increase the upward scenic score

          cmp       Byte [rdx], al                  ; is this byte bigger than the one we cast from (part 1)
          jge       up_covered
          jmp       up_loop

up_covered:
          inc       rbx

down:
          mov       rdx, rsi                        ; cast rdx downwards
down_loop:
          add       rdx, WIDTH+1                    ; down one line

          cmp       rdx, file_buf+WIDTH*LINES+WIDTH
          jg        left                            ; we're past the bottom line, go to next loop
          inc       r9                              ; increase downwards score

          cmp       Byte [rdx], al                  ; is this byte bigger than the one we cast from
          jge       down_covered
          jmp       down_loop

down_covered:
          inc       rbx

left:
          mov       rdx, rsi                        ; cast rdx left
left_loop:
          dec       rdx                             ; left one byte

          cmp       Byte [rdx], 0xA                 ; did we go back a full line?
          je        right                           ; we're past the left edge, go to next loop
          inc       r10                             ; increase score to the left

          cmp       Byte [rdx], al                  ; is this byte bigger than the one we cast from
          jge       left_covered
          jmp       left_loop

left_covered:
          inc       rbx

right:
          mov       rdx, rsi                        ; cast rdx right
right_loop:
          inc       rdx                             ; right one byte

          cmp       Byte [rdx], 0xA                 ; did we reach the end of the line?
          je        check                           ; we're past the right edge, all directions are checked
          inc       r11                             ; increase score to the right

          cmp       Byte [rdx], al                  ; is this byte bigger than the one we cast from
          jge       right_covered
          jmp       right_loop

right_covered:
          inc       rbx

check:
          mov       rax, r8
          mul       r9
          mul       r10
          mul       r11

          cmp       rax, r13
          jle       no_new_max
          mov       r13, rax

no_new_max:

          cmp       rbx, 0x4
          jne       not_covered
          inc       rcx

not_covered:
          jmp       loop

finished:

          mov       rdi, LINES*WIDTH
          sub       rdi, rcx
          call      uprintln

          mov       rdi, r13
          call      uprintln

; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall
