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
          FSIZE         equ 8500

          ARRAY_SZ      equ 100000000
          H_OFFSET_B    equ 0x10

          START         equ 10000000

          section   .bss

file_buf:
          resb      FSIZE

visited:
          resb      ARRAY_SZ

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
          add       r15, file_buf

; close the file
          mov       rax, SYS_CLOSE
          syscall

; === solve the problem ===

          mov       rcx, 0xA
          xor       rdx, rdx
          mov       rbx, file_buf
          dec       rbx

          mov       rdi, START                    ; head coordinates (higher bytes for x, lower bytes for y)
          mov       rsi, START                    ; tail coordinates
          mov       Byte [visited + rsi], 0x1     ; the tail has been where the tail starts

parse_cmd:
          inc       rbx
          cmp       rbx, r15
          jge       all_done                      ; we are all done

          mov       dl, byte [rbx]
          add       rbx, 2
          xor       r8, r8
          xor       rax, rax
atoi:
          push      rdx                           ; mul clobbers rdx
          mul       rcx
          pop       rdx
          mov       r8b, Byte [rbx]
          sub       r8, 0x30
          add       rax, r8
          inc       rbx                           ; this increment is enough, as the increment at the start of the loop will check if we're all done
          cmp       Byte [rbx], 0xA
          jne       atoi

          mov       rcx, rax                      ; use rcx as a counter for the next part, we need rax to check bools

; after the above, rdi and rsi should contain the (new) head and the tail coordinate respective, rdx the direction and rcx the number of steps to move

move_loop:
          call      move
          cmp       rax, 0x1
          jne       no_tail_move

          xor       rax, rax
          mov       al, Byte [visited + rsi]
          inc       rax
          mov       Byte [visited + rsi], al

no_tail_move:
          dec       rcx
          cmp       rcx, 0x0
          jne       move_loop

          jmp       parse_cmd

all_done:
          mov       rcx, ARRAY_SZ                      ; iterator
          xor       rdi, rdi                      ; counter (the sought sum)

count_tail_moves:
          cmp       Byte [visited + rcx], 0x0
          je        no_inc

          inc       rdi
no_inc:
          dec       rcx
          cmp       rcx, 0x0
          jl        count_tail_moves

          call      uprintln

; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0x0
          syscall

; ===
; function to move the head in rdi and possibly the tail in rsi one step. Rax contains a 1 if the tail was moved, a 0 otherwise.
move:
          xor       r13, r13
          cmp       rdx, 0x55
          je        .up
          cmp       rdx, 0x4c
          je        .left
          cmp       rdx, 0x44
          je        .down

          mov       r14, rdi                      ; save current position if we need to move the tail
.right:
          mov       r13, 0x1
          shl       r13, H_OFFSET_B
          add       rdi, r13

          call      adjacent
          cmp       rax, 0x1
          je        .move_done

          mov       rsi, r14                      ; move the tail to where we just were
          mov       r13, 0x1                      ; record that we did
          jmp       .move_done
.up:
          add       rdi, 0x1
          call      adjacent
          cmp       rax, 0x1
          je        .move_done

          mov       rsi, r14                      ; move the tail to where we just were
          mov       r13, 0x1                      ; record that we did
          jmp       .move_done
.down:
          sub       rdi, 0x1
          call      adjacent
          cmp       rax, 0x1
          je        .move_done

          mov       rsi, r14                      ; move the tail to where we just were
          mov       r13, 0x1                      ; record that we did
          jmp       .move_done
.left:
          mov       r13, 0x1
          shl       r13, H_OFFSET_B
          sub       rdi, r13

          call      adjacent
          cmp       rax, 0x1
          je        .move_done

          mov       rsi, r14                      ; move the tail to where we just were
          mov       r13, 0x1                      ; record that we did


.move_done:
          mov       rax, r13

          ret

; function to check if the tail in rsi is adjacent to the head in rdi (result in rax)
adjacent:
          xor       rax, rax
          mov       r8, rdi                       ; head_x
          mov       r9, rdi                       ; head_y
          mov       r10, rsi                      ; tail_x
          mov       r11, rsi                      ; tail_y

          shr       r8, H_OFFSET_B                ; extract the x coordinates
          shr       r10, H_OFFSET_B

          and       r9, 0xFF                      ; extract the y coordinates
          and       r11, 0xFF

          sub       r8, r10                       ; take the differences between the coordinates
          sub       r9, r11


;  abs(x) = (x xor y) - y  | where y = x >>> 63(64 bit implementation)
.abs:
          mov       r12, r8
          shr       r12, 0x3f
          xor       r8, r12
          sub       r8, r12

          mov       r12, r9
          shr       r12, 0x3f
          xor       r9, r12
          sub       r9, r12

; r8 = |head_x - tail_x| 
; r9 = |head_y - tail_y|

          cmp       r8, 0x1
          jg        .false
          cmp       r9, 0x1
          jg        .false

          mov       rax, 0x1

.false:
          ret

