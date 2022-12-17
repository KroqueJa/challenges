%include 'print.asm'
%include 'rope.asm'

extern malloc, free

; macros
          SYS_READ      equ 0
          STDOUT        equ 1
          SYS_OPEN      equ 2
          O_RDONLY      equ 0
          SYS_EXIT      equ 60
          SYS_WRITE     equ 1
          NEWLINE       equ 10
          SYS_CLOSE     equ 3
          FSIZE         equ 8500

; our knot specification is
; 1 Qword address of parent
; 1 Dword x coordinate
; 1 Dword y coordinate
; 1 Dword prev_x
; 1 Dword prev_y
; 1 Qword address to child
; total size == 24 bytes

          PARENT        equ 0
          X             equ 8
          Y             equ 12
          CHILD         equ 16

          SIZEOF_KNOT   equ 24

; we will use a 3050 x 3050 grid as this is enough to hold the entire problem space

          W             equ 400
          H             equ 400

; finally, we will start on square 1500, 1500
          START_X       equ 200
          START_Y       equ 200

          section   .data
x_str:
          db        'x: '
y_str:
          db        'y: '

          section   .bss

file_buf:
          resb      FSIZE

bytes_read:
          resq      1

head:
          resq      1

last:
          resq      1

grid:
          resb      W * H

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

          xor       rax, rax
; read the amount of knots to create from the command line
          pop       rdi
          call      atoi
          push      rax                                   ; save the amount of knots for a sec

init:
; create the head knot
          mov       rdi, SIZEOF_KNOT
          call      malloc
          mov       Qword [head], rax                     ; save the pointer to the allocated memory in [head]
          xor       r12, r12                              ; r12 can keep track of our total

          mov       Dword [rax + X], START_X
          mov       Dword [rax + Y], START_Y

          mov       rdi, [head]

; create the chain of child knots
          pop       rsi                                   ; pop the amount of knots into rsi
          dec       rsi                                   ; decrement rsi as we've already created the head
          call      create_chain

; record the position of the last knot
          mov       rdi, [head]
          call      find_last
          mov       [last], rax

; start moving the head around
          xor       rbx, rbx
          xor       rcx, rcx
          xor       rsi, rsi

parse_loop:

          xor       rax, rax
          mov       sil, Byte [file_buf + rcx]              ; rsi now holds the direction to move
          add       rcx, 0x2

input_atoi:
          push      rcx
          push      rdx
          mov       rdx, 0xA
          mul       rdx
          pop       rdx
          pop       rcx
          mov       bl, Byte [file_buf + rcx]
          sub       rbx, 0x30
          add       rax, rbx
          inc       rcx
          cmp       Byte[file_buf + rcx], 0xA
          jne       input_atoi
          inc       rcx                                     ; rcx is now ready at the start of the next line

          mov       rdx, rax                                ; load rdx with the number of steps to move

move_loop:
          mov       rdi, [head]
          call      move

record_last:

          push      rdi
          push      rcx
          push      rdx

          mov       rdi, [last]
          xor       r8, r8
          xor       r9, r9
          mov       r8d, Dword [rdi + X]
          mov       r9d, Dword [rdi + Y]

          mov       rdi, grid
          mov       rax, r9
          mov       r10, W
          mul       r10
          add       rdi, rax
          add       rdi, r8

          cmp       Byte [rdi], 0x0
          jg        no_inc
          inc       Byte [rdi]

          inc       r12

no_inc:
          pop       rdx
          pop       rcx
          pop       rdi


          dec       rdx
          cmp       rdx, 0x0
          jne       move_loop

          cmp       rcx, [bytes_read]
          jl        parse_loop

          mov       rdi, r12
          call      uprintln

free_rope:
          mov       rdi, [head]
          call      destroy_rope


          mov       rdi, 0x0
          call      exit
