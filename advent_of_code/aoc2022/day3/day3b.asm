%include  'print.asm'

; function to cast a letter in rax (calling convention be damned) to its correct position in a map
map_char:
          cmp       rax, 97
          jle       uppercase
lowercase:
          sub       rax, 58
uppercase:
          sub       rax, 39
          ret

; function to zero out all maps 
; it hurts me a bit to make a function to zero out *a* map which would be better design
; this should be a macro for sure but I haven't figured out how to do those with jumps yet
zero_maps:
          push      rax
          xor       rax, rax
.zero_loop:
          mov       Byte [first_pack_map + rax], 0
          mov       Byte [second_pack_map + rax], 0
          mov       Byte [third_pack_map + rax], 0
          inc       rax
          cmp       rax, 52
          jne       .zero_loop
          pop       rax
          ret

; function to map a pack
map_pack:

          xor       rax, rax              ; read register
          xor       r8, r8
          xor       r9, r9                ; iterator
.rd_loop:
          mov       r10, rdx              ; file offset
          add       r10, r9
          mov       al, Byte [file_buf + r10]
          call      map_char
          mov       r8b, Byte [rdi+rax]
          inc       r8
          mov       Byte [rdi + rax], r8b
          inc       r9
          inc       r10                                 ; this looks superfluous, but is necessary to find the newline
          cmp       Byte [file_buf + r10], NEWLINE
          jne       .rd_loop

          mov       rax, r9
          inc       rax
          ret

; function to find the common element between three maps
find_common:

          xor       r8, r8
          xor       r9, r9
          xor       r10, r10
          xor       r11, r11                              ; iterator
.and_loop:
          mov       r8b, Byte [rdi + r11]
          mov       r9b, Byte [rsi + r11]
          mov       r10b, Byte [rdx + r11]
          inc       r11
          cmp       r8, 0
          je        .and_loop
          cmp       r9, 0
          je        .and_loop
          cmp       r10, 0
          je        .and_loop

; since we know there is always going to be a common element, we can be nasty and skip checking if we reached the end of the map (since we never will)
          mov       rax, r11
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
          FSIZE         equ 10500

          section   .bss
file_buf:
          resb      FSIZE

bytes_read:
          resq      1

bytes_processed:
          resq      1

sum:
          resq      1

first_pack_map:
          resb      52

second_pack_map:
          resb      52

third_pack_map:
          resb      52

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

; load three packs
          xor       rdx, rdx                    ; file buffer iterator
          mov       rsi, file_buf

loop:
; read three packs into their maps
          call      zero_maps
          mov       rdx, Qword [bytes_processed]
          mov       rdi, first_pack_map
          call      map_pack
          mov       rbx, Qword [bytes_processed]
          add       rbx, rax
          mov       Qword [bytes_processed], rbx

          mov       rdx, Qword [bytes_processed]
          mov       rdi, second_pack_map
          call      map_pack
          mov       rbx, Qword [bytes_processed]
          add       rbx, rax
          mov       Qword [bytes_processed], rbx

          mov       rdx, Qword [bytes_processed]
          mov       rdi, third_pack_map
          call      map_pack
          mov       rbx, Qword [bytes_processed]
          add       rbx, rax
          mov       Qword [bytes_processed], rbx
check:
; find the common item
          mov       rdi, first_pack_map
          mov       rsi, second_pack_map
          mov       rdx, third_pack_map
          call      find_common
          mov       r12, Qword [sum]
          add       r12, rax
          mov       Qword [sum], r12
cont:
          cmp       rbx, Qword [bytes_read]
          jne       loop


; print the sum
          mov       rdi, Qword [sum]
          call      uprintln

; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

