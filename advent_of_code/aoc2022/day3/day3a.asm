%include  'print.asm'

; macro to cast a letter in rax (calling convention be damned) to its correct position in a map
map_char:
          cmp       rax, 97
          jle       uppercase
lowercase:
          sub       rax, 58
uppercase:
          sub       rax, 39

          ret

; function to zero out two maps
zero_maps:
          push      rax
          xor       rax, rax
.zero_loop:
          mov       Byte [left_item_map + rax], 0
          mov       Byte [right_item_map + rax], 0
          inc       rax
          cmp       rax, 52
          jne       .zero_loop
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
          FSIZE         equ 10500

          section   .bss
file_buf:
          resb      FSIZE

bytes_read:
          resq      1

pack_len:
          resb      1

half_len:
          resb      1

left_item_map:
          resb      52                      ; reserve space for two alphabets (uppercase and lowercase)

right_item_map:
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
          xor       rax, rax                  ; read register
          xor       rbx, rbx                  ; file buffer iterator
          xor       rcx, rcx                  ; pack iterator
          xor       rdi, rdi                  ; read register 2
          xor       rsi, rsi                  ; sum of priorities (the sought output)
pack_loop:
          inc       rax
          cmp       Byte [file_buf + rbx + rax], NEWLINE
          jne       pack_loop
; after the above loop, rax contains the index of a newline right before the next pack to be checked
          mov       [pack_len], al
          xor       rdx, rdx
          mov       r8, 2
          div       r8                       ; rax contains the index where the second compartment begins
          mov       [half_len], al
          xor       rax, rax
          xor       rcx, rcx
first_cmpt:
          mov       al, Byte [file_buf + rbx + rcx]
          call      map_char
; count the item into the left map
          mov       dil, Byte [left_item_map + rax]
          inc       rdi
          mov       Byte [left_item_map + rax], dil

          inc       rcx
          cmp       cl, Byte [half_len]
          jne       first_cmpt
second_cmpt:
          mov       al, Byte [file_buf + rbx + rcx]
          call      map_char
; count the item into the right map
          mov       dil, Byte [right_item_map+ rax]
          inc       rdi
          mov       Byte [right_item_map + rax], dil

          inc       rcx
          cmp       cl, Byte [pack_len]
          jne       second_cmpt

; all items have been counted
          xor       rax, rax
          xor       rcx, rcx
check_items:
          cmp       rcx, 52
          je        done
          mov       al, Byte [left_item_map + rcx]
          mov       dil, Byte [right_item_map + rcx]
          inc       rcx
          cmp       rax, 0
          je        check_items
          cmp       rdi, 0
          je        check_items
done:
          call      zero_maps
          add       rsi, rcx
          xor       rax, rax
          xor       r8, r8
          mov       r8b, Byte [pack_len]
          add       rbx, r8
          inc       rbx
          cmp       rbx, Qword [bytes_read]
          jl        pack_loop

          mov       rdi, rsi
          call      uprintln

; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

