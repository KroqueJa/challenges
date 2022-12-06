%include 'print.asm'
%include 'stack.asm'

; dirty function to pretty-print the stacks (kind of) - was implemented for debugging purposes
print_stacks:
          push      rax
          push      rcx
          push      rdx
          push      rdi
          push      rsi

          xor       rdx, rdx

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          add       rsi, 72
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          add       rsi, 144
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          add       rsi, 216
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          add       rsi, 288
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          add       rsi, 360
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          add       rsi, 432
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          add       rsi, 504
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          add       rsi, 576
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          mov       rax, 1
          mov       rdi, 1
          mov       rsi, stacks
          add       rsi, 648
          mov       dl, Byte [rsi]
          add       rsi, 1
          syscall
          call      br

          call      br

          pop       rsi
          pop       rdi
          pop       rdx
          pop       rcx
          pop       rax

          ret

; function to parse a line indicated in rdi into rax, rbx and rcx
; the instruction can then be read as "move from stack rax to stack rbx rcx times"
; rdx will contain the number of bytes read
parse_instruction:
          mov       r10, 10
          xor       rax, rax
          xor       rbx, rbx
          xor       rcx, rcx
          mov       r8,  5
atoi_loop:
          mul       r10
          add       al, Byte [rdi+r8]
          sub       rax, 48
          inc       r8
          cmp       Byte [rdi+r8], 32
          jne       atoi_loop

; after the atoi loop our only multi-digit number is in rax, so we switch the places of it and rcx
; rdi points to the space after the multi-digit number
          mov       rcx, rax
          add       r8,  6                                  ; jump 6 bytes past "from "
          mov       al,  Byte [rdi+r8]
          sub       rax, 49                                 ; stingily subtract 1 more than 48 to include decrementation into zero-indexed stacks rather than one-indexed
          add       r8,  5                                  ; jump 5 bytes past " to "
          mov       bl,  Byte [rdi+r8]
          sub       rbx, 49
          add       r8,  2

          mov       rdx, r8
          ret

; function to move the box indicated in rsi to rdi
move_box:
          push      rsi
          push      rdi
          push      rax

; check if the stack is empty - then we do nothing
          push      rdi
          mov       rdi, rsi
          call      bs_size
          cmp       rax, 0
          je        .done

; if not, move the box
          pop       rdi
          call      bs_pop
          mov       rsi, rax
          call      bs_push

.done:
          pop       rax
          pop       rdi
          pop       rsi
          ret
; moves a number of boxes according to part 2 (memcpy)
move_box_9k1:
; check if the stack is empty - then we do nothing
          push      rax
          push      rbx
          push      rcx
          push      rdx

          xor       rax, rax

          mov       al, Byte [rsi]
          cmp       rax, 0
          je        .done

; prepare the source and destination registers
          xor       rbx, rbx
          xor       rcx, rcx

          mov       bl, Byte [rsi]
          sub       rbx, rdx                                ; we are going to take rdx items, so rbx is now the offset of the first item to be taken

          mov       cl, Byte [rdi]                          ; for the destination register, this is the correct offset

          mov       al, Byte [rsi]
          sub       rax, rdx
          mov       Byte [rsi], al                          ; decrement the size of the source stack by rdx (the amount of items taken)

          mov       al, Byte [rdi]
          add       rax, rdx
          mov       Byte [rdi], al                          ; increment the size of the destination stack

.write_loop:
          mov       al, Byte [rsi + rbx + 1]
          mov       Byte [rdi + rcx + 1], al
          inc       rbx
          inc       rcx
          dec       rdx
          cmp       rdx, 0
          jne       .write_loop


.done:
          pop       rdx
          pop       rcx
          pop       rbx
          pop       rax
          ret


; macros
          SYS_READ      equ 0
          STDOUT        equ 1
          SYS_OPEN      equ 2
          O_RDONLY      equ 0
          SYS_EXIT      equ 60
          SYS_WRITE     equ 1
          NEWLINE       equ 10
          SYS_CLOSE     equ 3
          FSIZE         equ 11500
          STACKSIZE     equ 72                      ; 72 is the highest any stack can grow

          section   .bss
file_buf:
          resb      FSIZE

bytes_read:
          resq      1

output_buf:
          resb      10

; this memory area represents a number of stacks
stacks:
          resb      200

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
          mov       Qword [bytes_read], rax
          mov       rdi, rax
; close the file
          mov       rax, SYS_CLOSE
          syscall

; solve the problem

; go through the first part of the input file
          mov       rdi, stacks
          xor       rsi, rsi                              ; read register
          xor       rbx, rbx                              ; line offset
          mov       rcx, 1                                ; column offset
          xor       rdx, rdx                              ; item counter
stacks_loop:
          mov       sil, Byte [file_buf + rbx + rcx]      ; line + column offsets = byte we want
          add       rbx, 36                               ; move rbx to point at the next line
          cmp       rsi, 32                               ; check if the box is "empty" ie a space
          je        stacks_loop                           ; if it is, keep searching downwards for a non-space
          cmp       rsi, 57
          jle       stack_done                            ; on the other hand, if we find a non-space that is '9' or less, we are done with this stack
          push      rsi                                   ; we now have a non-space in our possession (no stacks are empty in the input) so we push it to the stack
          inc       rdx
          jmp       stacks_loop

stack_done:
; push everything on the stack (which is backwards) onto the stack where we want it
push_loop:
          pop       rsi
          call      bs_push
          dec       rdx
          cmp       rdx,0
          jne       push_loop

; now all items are on our stack, and rbx is once more 0 (pointing to the first line of the input)
          add       rcx, 4                                ; increment the column pointer by 4 bytes
          cmp       rcx, 36
          jg        init_done                            ; if it points outside the line, we are done stacking boxes
          add       rdi, STACKSIZE                        ; move the stack pointer to the next stack
          xor       rbx, rbx                              ; move the line pointer back to line 0
          xor       rdx, rdx                              ; zero the item counter
          jmp       stacks_loop
init_done:

; the 9 stacks are full of boxes. Let's count lines until we reach the first input line.
          xor       rax, rax
          xor       rcx, rcx
skip_loop:
          mov       al, Byte [file_buf + rcx]
          inc       rcx
          cmp       rax, 109                              ; we are looking for the first instance of 'm'
          jne       skip_loop
          dec       rcx


          mov       r12, rcx                              ; r12 will hold our current file offset throughout


; we have found the start of the move instructions - start parsing them and moving boxes
parse_loop:
          mov       rdi, file_buf
          add       rdi, r12
          call      parse_instruction
          mov       r8, rax
          mov       r9, rbx
          mov       r10, rcx

; increase the number of processed bytes
          add       r12, rdx

; get the memory offsets and add them to the source and destination registers
          mov       rdi, stacks
          mov       rsi, stacks

          mov       rax, STACKSIZE
          mul       r8
          add       rsi, rax

          mov       rax, STACKSIZE
          mul       r9
          add       rdi, rax

; rdi now holds the correct memory pointer to move into, rsi the correct stack to move from and rcx the number of times to perform the move instruction
; note: we make no check that this number of boxes can be moved at all
move_loop:
          ;call      move_box                                         ; part 1
          ;dec       rcx                                              ; part 1
          mov       rdx, rcx                                          ; part 2
          call      move_box_9k1                                      ; part 2
          xor       rcx, rcx                                          ; part 2
          cmp       rcx, 0
          jne       move_loop

; when we are here, the instruction has been fully carried out
          cmp       r12, Qword [bytes_read]
          jl        parse_loop

          xor       rcx, rcx
          mov       rsi, stacks

print_loop:
          call      bs_pop
          mov       Byte [output_buf + rcx], al
          inc       rcx
          add       rsi, STACKSIZE
          cmp       rcx, 9
          jne       print_loop

          mov       Byte [output_buf + 9], NEWLINE

          mov       rax, SYS_WRITE
          mov       rdi, STDOUT
          mov       rsi, output_buf
          mov       rdx, 10

          syscall

; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

