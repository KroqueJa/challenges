
; ===================================================================
; function to find a pointer to the tail of a rope
; inputs
; rdi: pointer to the head of the rope
; outputs
; rax: pointer to the tail
find_last:
          push      rdi
          cmp       Qword [rdi + CHILD], 0x0
          je        .is_last

.not_last:
          mov       rdi, [rdi + CHILD]
          call      find_last
          pop       rdi
          ret
.is_last:
          mov       rax, rdi
          pop       rdi
          ret

; ===================================================================
; function to find a pointer to the tail of a rope
; inputs
; rdi: pointer to the head of the rope
; outputs
; rax: pointer to the tail


; ===================================================================
; function to move a knot one step in a cardinal direction
; inputs
; rdi: pointer to the knot
; rsi: char indicating the direction ['U', 'L', 'D', 'R']
move:
          push      rdi
          push      rsi

          cmp       rsi, 0x55
          je        .up
          cmp       rsi, 0x4c
          je        .left
          cmp       rsi, 0x44
          je        .down

.right:
          inc       Dword [rdi + X]
          jmp       .move_done
.up:
          inc       Dword [rdi + Y]
          jmp       .move_done
.left:
          dec       Dword [rdi + X]
          jmp       .move_done
.down:
          dec       Dword [rdi + Y]
          jmp       .move_done

.move_done:
          call      drag                            ; drag will go through the children recursively and move them up if necessary (starting with the head)

          pop       rsi
          pop       rdi
          ret

; ===================================================================
; function to drag the child of a knot into place if it is not adjacent to its parent
; inputs
; rdi: the address of the parent knot
drag:
          push      rax
          push      rdi
          push      rsi

          mov       rsi, Qword [rdi + CHILD]

; if there is no child, the drag is done
          cmp       rsi, 0x0
          je        .drag_done

          xor       r8, r8
          xor       r9, r9
          xor       r10, r10
          xor       r11, r11
          mov       r8d, Dword [rdi + X]
          mov       r9d, Dword [rdi + Y]
          mov       r10d, Dword [rsi + X]
          mov       r11d, Dword [rsi + Y]

          sub       r8, r10                       ; r8 = delta_x
          sub       r9, r11                       ; r9 = delta_y

; clang style absolute value
.abs:
          mov       rax, r8
          neg       rax
          cmovl     rax, r8
          mov       r10, rax                      ; r10 = |head_x - tail_x|

          mov       rax, r9
          neg       rax
          cmovl     rax, r9
          mov       r11, rax                      ; r11 = |head_y - tail_y|

          cmp       r10, 0x1
          jg        .do_drag
          cmp       r11, 0x1
          jle       .drag_done                    ; the child is adjacent to the parent, nothing more needs to be dragged


.do_drag:
; divide the deltas by 2 if their absolute values are 2
          cmp       r10, 0x2
          jne       .no_half_x

          sar       r8, 0x1

.no_half_x:
          cmp       r11, 0x2
          jne       .apply_deltas

          sar       r9, 0x1

.apply_deltas:

          add       Dword [rsi + X], r8d
          add       Dword [rsi + Y], r9d

.drag_child:
          mov       rdi, rsi
          call      drag

.drag_done:

          pop       rsi
          pop       rdi
          pop       rax
          ret


; ===================================================================
; function to check if two knots are adjacent (including all 8 directions)
; inputs
; rdi: pointer to a knot
; rsi: pointer to another knot
; outputs
; rax: 1 if the two knots are adjacent, 0 otherwise
adjacent:
          xor       rax, rax
          xor       r8, r8
          xor       r9, r9
          xor       r10, r10
          xor       r11, r11
          mov       r8d, Dword [rdi + X]
          mov       r9d, Dword [rdi + Y]
          mov       r10d, Dword [rsi + X]
          mov       r11d, Dword [rsi + Y]

          sub       r8, r10                       ; delta_x
          sub       r9, r11                       ; delta_y

; clang style absolute value
.abs:
          mov       rax, r8
          neg       rax
          cmovl     rax, r8
          mov       r8, rax                       ; r8 = |head_x - tail_x|

          mov       rax, r9
          neg       rax
          cmovl     rax, r9
          mov       r9, rax                       ; r9 = |head_y - tail_y|

          xor       rax, rax

          cmp       r8, 0x1
          jg        .false
          cmp       r9, 0x1
          jg        .false

.true:
          mov       rax, 0x1

.false:
          ret

; ===================================================================
; function to create a chain of knots from a head knot
; inputs
; rdi: pointer to the head knot
; rsi: number of knots in the chain excluding the head knot
create_chain:

          push        rdi
          push        rsi
          push        rcx

          mov         rcx, rsi
.loop:
          call        create_child

          mov         rdi, [rdi + CHILD]
          dec         rcx
          cmp         rcx, 0x0
          jne         .loop

          pop         rcx
          pop         rsi
          pop         rdi

          ret


; ===================================================================
; function to create a child knot to a knot
; inputs
; rdi: pointer to the parent knot

create_child:
          push        rcx
          push        rdi
.alloc:
          mov         rdi, SIZEOF_KNOT
          call        malloc

.w_ptr_into_parent:
          pop         rdi
          mov         Qword [rdi + CHILD], rax

.w_ptr_into_child:
          mov         Qword [rax + PARENT], rdi

.w_coords_into_child:
          mov         r8d, Dword [rdi + X]
          mov         Dword [rax + X], r8d
          mov         r8d, Dword [rdi + Y]
          mov         Dword [rax + Y], r8d

          pop         rcx
          ret

; ===================================================================
; function to read a string of bytes into an unsigned integer
; inputs
; rdi: pointer to the start of the null-terminated file buffer
atoi:
          push        rcx

          mov         rcx, 0xA
          xor         r8, r8
          xor         r9, r9
          xor         rax, rax

.loop:
          mul         rcx
          mov         r8b, Byte [rdi + r9]
          sub         r8, 0x30
          add         rax, r8
          inc         r9
          cmp         Byte [rdi + r9], 0x0
          jne         .loop

          pop         rcx
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

; ===================================================================
; function to destroy all knots of a rope
; inputs
; rdi: the head of the rope

destroy_rope:

          cmp         Qword [rdi + CHILD], 0x0
          je          .no_destroy

          push        rdi
          mov         rdi, Qword [rdi + CHILD]
          call        destroy_rope
          pop         rdi

.no_destroy:

          call        free

          ret


; ===================================================================
; exit with the exit code in rdi
exit:
          mov         rax, SYS_EXIT
          syscall
